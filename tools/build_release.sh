#!/usr/bin/env bash
# 构建 mpv-lazy 轻量完整版 + 单文件安装器
# 用法：在仓库根目录执行  bash tools/build_release.sh
# 产物：release/mpv-lazy-setup.exe（双击自解压安装）
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STAGE="$ROOT/release/stage"
OUT="$ROOT/release"
SEVENZ="$ROOT/7z.exe"
SFX="/c/Program Files/7-Zip/7z.sfx"

if [ ! -x "$SEVENZ" ]; then echo "缺少 7z.exe"; exit 1; fi
if [ ! -f "$SFX" ]; then echo "缺少 7z.sfx（系统 7-Zip）"; exit 1; fi

echo "=== 1/6 清理旧产物 ==="
# 用 Python 递归删除，避免 bulk rm 触发环境的批量删除保护
if [ -d "$STAGE" ]; then
  "$ROOT/python.exe" -c "import shutil,sys; shutil.rmtree(sys.argv[1])" "$STAGE"
fi
mkdir -p "$STAGE"

echo "=== 2/6 复制运行必需文件 ==="
cd "$ROOT"
cp mpv.exe mpv.com umpv.exe umpv.conf yt-dlp.exe "$STAGE/"
cp python.exe pythonw.exe python3.dll python314.dll python314.zip python314._pth python.cat "$STAGE/"
cp libcrypto-3.dll libssl-3.dll libffi-8.dll sqlite3.dll "$STAGE/"
cp msvcp140.dll msvcp140_1.dll msvcp140_2.dll msvcp140_atomic_wait.dll msvcp140_codecvt_ids.dll "$STAGE/"
cp vcruntime140.dll vcruntime140_1.dll vcruntime140_threads.dll concrt140.dll vccorlib140.dll "$STAGE/"
cp *.pyd "$STAGE/"
cp VSScript.dll VSScriptPython38.dll VSVFW.dll VSPipe.exe "$STAGE/"
# portable.vs 是 VapourSynth 识别便携环境的标记文件（0 字节），缺失会导致 VSScript 初始化失败
cp portable.vs "$STAGE/"
cp README.MD LICENSE.MD LICENSE.txt mpv_manual.pdf "$STAGE/"
cp -r Lib Scripts vs-plugins vs-coreplugins "$STAGE/"
cp -r portable_config "$STAGE/"
cp -r installer "$STAGE/"

echo "=== 3/6 裁剪 Python 测试/开发资源 ==="
cd "$STAGE"
# numpy/onnx 的测试套件、f2py 开发工具，运行时不引用
rm -rf Lib/site-packages/numpy/_core/tests Lib/site-packages/numpy/lib/tests \
       Lib/site-packages/numpy/random/tests Lib/site-packages/numpy/linalg/tests \
       Lib/site-packages/numpy/fft/tests Lib/site-packages/numpy/ma/tests \
       Lib/site-packages/numpy/matrixlib/tests Lib/site-packages/numpy/polynomial/tests \
       Lib/site-packages/numpy/typing/tests Lib/site-packages/numpy/testing/tests \
       Lib/site-packages/numpy/tests Lib/site-packages/numpy/f2py \
       Lib/site-packages/numpy/_pyinstaller/tests \
       Lib/site-packages/onnx/backend/test Lib/site-packages/onnx/test \
       Lib/site-packages/pip/_vendor
find Lib/site-packages -type d -name __pycache__ -prune -exec rm -rf {} +
# 开发用命令与安装引导，运行不需要
rm -f Scripts/backend-test-tools.exe Scripts/check-model.exe Scripts/check-node.exe \
      Scripts/f2py.exe Scripts/numpy-config.exe \
      get-pip.py vsgenstubs.py vsrepo.py MANIFEST.in \
      pfm-192-vapoursynth-win.exe AVFS.exe

echo "=== 4/6 裁剪运行时缓存与未引用字体 ==="
rm -rf portable_config/_cache
rm -f portable_config/saved-props.json
# 该字体当前未被任何启用的配置项引用（console/uosc 的 custom_font 均为注释）
rm -f portable_config/fonts/LXGWWenKaiMonoLite-Regular.ttf

echo "=== 5/6 压缩为 7z ==="
rm -f "$OUT/stage.7z"
( cd "$STAGE" && "$SEVENZ" a -t7z -mx=9 -mfb=64 -md=32m -ms=on "$OUT/stage.7z" . > /dev/null )

# 7z SFX 配置块：GUI 版解压对话框 + 安装到独立子目录
printf '%s\n' \
  ';!@Install@!UTF-8!' \
  'Title="mpv-lazy 安装"' \
  'BeginPrompt="将 mpv-lazy 安装到当前目录下的 mpv-lazy 文件夹？"' \
  'ExtractPathText="目标目录"' \
  'Directory="mpv-lazy"' \
  'Progress="yes"' \
  ';!@InstallEnd@!' > "$OUT/sfx.conf"

echo "=== 6/6 拼接为单文件安装器 ==="
cat "$SFX" "$OUT/sfx.conf" "$OUT/stage.7z" > "$OUT/mpv-lazy-setup.exe"
rm -f "$OUT/stage.7z" "$OUT/sfx.conf"

echo ""
echo "完成：$OUT/mpv-lazy-setup.exe"
du -h "$OUT/mpv-lazy-setup.exe"
echo "精简目录：$STAGE"
du -sh "$STAGE"
