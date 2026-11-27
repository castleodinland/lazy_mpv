"""构建 mpv-lazy 轻量完整版 + 7z 单文件安装器。

跨 Windows / Ubuntu 共用：本地 build_release.bat 与 GitHub Actions 都调用本脚本。
产物：release/mpv-lazy-setup.exe
用法：python tools/build_release.py
"""

import datetime
import glob
import os
import shutil
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
STAGE = os.path.join(ROOT, "release", "stage")
OUT = os.path.join(ROOT, "release")
SFX = os.path.join(ROOT, "tools", "7z.sfx")
ARCHIVE = os.path.join(OUT, "stage.7z")
SETUP = os.path.join(OUT, "mpv-lazy-setup.exe")
CONF = os.path.join(OUT, "sfx.conf")


def find_7z():
    """Windows 用仓库自带 7z.exe；Ubuntu 用 PATH 中的 7z（p7zip-full）。"""
    if os.name == "nt":
        local = os.path.join(ROOT, "7z.exe")
        if os.path.isfile(local):
            return local
        return "7z.exe"
    return "7z"


def step(n, text):
    print(f"=== {n}/6 {text} ===", flush=True)


def copy(src, dst):
    """复制单个文件到目标目录（保留原文件名）。"""
    shutil.copy2(src, dst)


def main():
    sevenz = find_7z()
    if not os.path.isfile(SFX):
        sys.exit(f"缺少 SFX 模块：{SFX}")

    step(1, "清理旧产物")
    if os.path.isdir(STAGE):
        shutil.rmtree(STAGE)
    os.makedirs(STAGE, exist_ok=True)
    for f in (ARCHIVE, CONF, SETUP):
        if os.path.exists(f):
            os.remove(f)

    step(2, "复制运行必需文件")
    single = [
        "mpv.exe", "mpv.com", "umpv.exe", "umpv.conf", "yt-dlp.exe",
        "python.exe", "pythonw.exe", "python3.dll", "python314.dll",
        "python314.zip", "python314._pth", "python.cat",
        "libcrypto-3.dll", "libssl-3.dll", "libffi-8.dll", "sqlite3.dll",
        "msvcp140.dll", "msvcp140_1.dll", "msvcp140_2.dll",
        "msvcp140_atomic_wait.dll", "msvcp140_codecvt_ids.dll",
        "vcruntime140.dll", "vcruntime140_1.dll", "vcruntime140_threads.dll",
        "concrt140.dll", "vccorlib140.dll",
        "VSScript.dll", "VSScriptPython38.dll", "VSVFW.dll", "VSPipe.exe",
        # 0 字节标记文件：缺失会导致 VSScript 初始化失败
        "portable.vs",
        "README.MD", "LICENSE.MD", "LICENSE.txt", "mpv_manual.pdf",
    ]
    for name in single:
        copy(os.path.join(ROOT, name), STAGE)
    for pattern in ("*.pyd",):
        for f in glob.glob(os.path.join(ROOT, pattern)):
            copy(f, STAGE)
    for d in ("Lib", "Scripts", "vs-plugins", "vs-coreplugins",
              "portable_config", "installer"):
        shutil.copytree(os.path.join(ROOT, d), os.path.join(STAGE, d))

    step(3, "裁剪 Python 测试/开发资源")
    drop_dirs = [
        "Lib/site-packages/numpy/_core/tests",
        "Lib/site-packages/numpy/lib/tests",
        "Lib/site-packages/numpy/random/tests",
        "Lib/site-packages/numpy/linalg/tests",
        "Lib/site-packages/numpy/fft/tests",
        "Lib/site-packages/numpy/ma/tests",
        "Lib/site-packages/numpy/matrixlib/tests",
        "Lib/site-packages/numpy/polynomial/tests",
        "Lib/site-packages/numpy/typing/tests",
        "Lib/site-packages/numpy/testing/tests",
        "Lib/site-packages/numpy/tests",
        "Lib/site-packages/numpy/f2py",
        "Lib/site-packages/numpy/_pyinstaller/tests",
        "Lib/site-packages/onnx/backend/test",
        "Lib/site-packages/onnx/test",
        "Lib/site-packages/pip/_vendor",
    ]
    for rel in drop_dirs:
        shutil.rmtree(os.path.join(STAGE, rel), ignore_errors=True)
    for root, dirs, _ in os.walk(STAGE, topdown=False):
        for d in dirs:
            if d == "__pycache__":
                shutil.rmtree(os.path.join(root, d), ignore_errors=True)
    drop_files = [
        "Scripts/backend-test-tools.exe", "Scripts/check-model.exe",
        "Scripts/check-node.exe", "Scripts/f2py.exe",
        "Scripts/numpy-config.exe", "get-pip.py", "vsgenstubs.py",
        "vsrepo.py", "MANIFEST.in", "pfm-192-vapoursynth-win.exe", "AVFS.exe",
    ]
    for rel in drop_files:
        p = os.path.join(STAGE, rel)
        if os.path.exists(p):
            os.remove(p)

    step(4, "裁剪运行时缓存与未引用字体")
    shutil.rmtree(os.path.join(STAGE, "portable_config", "_cache"), ignore_errors=True)
    for rel in ("portable_config/saved-props.json",
                "portable_config/fonts/LXGWWenKaiMonoLite-Regular.ttf"):
        p = os.path.join(STAGE, rel)
        if os.path.exists(p):
            os.remove(p)

    step(5, "压缩为 7z")
    subprocess.run(
        [sevenz, "a", "-t7z", "-mx=9", "-mfb=64", "-md=32m", "-ms=on",
         ARCHIVE, "."],
        cwd=STAGE, check=True, stdout=subprocess.DEVNULL,
    )

    # 7z SFX 配置块：GUI 解压对话框 + 安装到独立子目录
    conf_text = (
        ";!@Install@!UTF-8!\n"
        'Title="mpv-lazy 安装"\n'
        'BeginPrompt="将 mpv-lazy 安装到当前目录下的 mpv-lazy 文件夹？"\n'
        'ExtractPathText="目标目录"\n'
        'Directory="mpv-lazy"\n'
        'Progress="yes"\n'
        ";!@InstallEnd@!\n"
    )
    with open(CONF, "w", encoding="utf-8", newline="\n") as f:
        f.write(conf_text)

    step(6, "拼接为单文件安装器")
    with open(SETUP, "wb") as out:
        for part in (SFX, CONF, ARCHIVE):
            with open(part, "rb") as f:
                shutil.copyfileobj(f, out)
    os.remove(ARCHIVE)
    os.remove(CONF)

    size_mb = os.path.getsize(SETUP) / 1048576
    tag = "release-" + datetime.datetime.now().strftime("%Y%m%d-%H%M")
    print("", flush=True)
    print(f"完成：{SETUP} ({size_mb:.1f} MB)", flush=True)
    print(f"建议版本号：{tag}", flush=True)
    # 供 GitHub Actions 读取
    with open(os.path.join(OUT, "tag.txt"), "w", encoding="ascii") as f:
        f.write(tag)


if __name__ == "__main__":
    main()
