# lazy_mpv

基于 [mpv](https://github.com/mpv-player/mpv) 的 Windows 便携播放器整合包（解压即用），内置 Python 运行环境、VapourSynth 滤镜链、着色器与 uosc 界面等完整配置。

## 说明

本仓库是个人使用的配置存档与定制版本，主要用于记录和同步自己的快捷键、滤镜、着色器等设置。

配置文件位于 `portable_config/` 目录，其中输入配置为 `input_uosc.conf`。文本文件统一使用 **UTF-8** 编码、**LF** 换行；`installer/*.bat` 因 Windows 命令行兼容性使用 ANSI/GBK 编码。

音量与静音状态由 `save_global_props` 跨会话记忆，保存在 `portable_config/saved-props.json`。该文件中的值会覆盖 `mpv.conf` 的 `volume` 设置；修改配置中的音量后，需按 `Ctrl+r` 清除记录（或删除该缓存文件）并重启 mpv，新值才会生效。

## 致谢

本项目完全来自并致谢 [hooke007/mpv_PlayKit](https://github.com/hooke007/mpv_PlayKit)。

感谢原作者 **hooke007** 长期维护这套优秀的 mpv 懒人包，提供了开箱即用的完整解决方案、详尽的中文文档与持续的更新。本仓库仅在其基础上做个人化调整，所有核心工作归功于原项目。

- 原项目主页：https://github.com/hooke007/mpv_PlayKit
- 文档 Wiki：https://github.com/hooke007/mpv_PlayKit/wiki

## Anime4K 着色器集成

本项目集成了 [Anime4K](https://github.com/bloc97/Anime4K) v4.x 动画着色器（49 个 glsl 文件），通过快捷键一键切换预设模式：

- Ctrl+Alt+1/2/3：Mode A/B/C（1080p/720p/480p 优化）
- Ctrl+Alt+4/5/6：Mode A+A/B+B/C+A（双重重建）
- Ctrl+5/6：单着色器开关（重建/放大）
- Ctrl+反引号：清空所有着色器

切换模式时 OSD 会显示"Anime4K: Mode X 已启动"提示。详细说明见 `portable_config/shaders/Anime4K/README.md`。

## 快捷键功能一览

以下列出 `input_uosc.conf` 中所有已映射的快捷键及其功能。`#!` 注释项为右键菜单中可见的条目；`#` 注释行表示未映射（可按需启用）。

### VF 滤镜（VapourSynth 补帧 & AI 处理）

| 快捷键 | 功能名 | 功能解释 |
|--------|--------|---------|
| `~` (Shift+反引号) | 清空滤镜 | 移除所有 VapourSynth 视频滤镜 |
| `!` (Shift+1) | 补帧 MVTools 快速 | 基于 MVTools 的光流补帧，速度快、质量中 |
| `@` (Shift+2) | 补帧 RIFE DX12 | 基于 RIFE 的 AI 补帧，DirectX12 后端 |
| `#` (Shift+3，键名 SHARP) | 补帧 DRBA DX12 | 基于 DRBA 的 AI 补帧，DirectX12 后端 |
| `$` (Shift+4) | 补帧 RIFE RTX | RIFE 补帧，NVIDIA TensorRT 后端（需 RTX 显卡 + DLC-vsNV，未随包提供） |
| `%` (Shift+5) | 补帧 DRBA RTX | DRBA 补帧，NVIDIA TensorRT 后端（需 RTX 显卡 + DLC-vsNV，未随包提供） |
| `^` (Shift+6) | 自定义AI UAI DX12 | 自定义 AI 画质处理，DirectX12 后端 |
| `&` (Shift+7) | 自定义AI UAI RTX | 自定义 AI 画质处理，NVIDIA TensorRT 后端（需 RTX 显卡 + DLC-vsNV，未随包提供） |

> `$` / `%` / `&` 依赖原项目的 DLC-vsNV 扩展（`vs/MEMC_RIFE_NV.vpy`、`vs/MEMC_DRBA_NV.vpy`、`vs/MIX_UAI_NV_TRT.vpy`）。本包未包含这三个文件，直接调用会失败；需要时请先按原项目文档安装 DLC。

### GLSL 着色器

| 快捷键 | 功能名 | 功能解释 |
|--------|--------|---------|
| `Ctrl+反引号` | 清空着色器 | 移除所有已加载的 GLSL 着色器 |
| `Ctrl+1` | Ani4Kv2 (LUMA) | Ani4K v2 ArtCNN，亮度通道放大 |
| `Ctrl+2` | AniSD (LUMA) | AniSD ArtCNN，亮度通道放大 |
| `Ctrl+3` | FSRCNNX (LUMA) | FSRCNNX x2，亮度通道放大 |
| `Ctrl+4` | NNEDI3 (LUMA) | NNEDI3 nns64，亮度通道放大 |
| `Ctrl+5` | A4K 重建 (MAIN) | Anime4K Restore_CNN_L，画质重建（带 OSD 提示） |
| `Ctrl+6` | A4K 放大 (MAIN) | Anime4K Upscale_GAN_x2_M，GAN 放大（带 OSD 提示） |
| `Ctrl+Alt+1` | Anime4K 模式A | 1080p 动画优化，完整着色器链（带 OSD 提示） |
| `Ctrl+Alt+2` | Anime4K 模式B | 720p 动画优化，柔和重建（带 OSD 提示） |
| `Ctrl+Alt+3` | Anime4K 模式C | 480p 动画优化，降噪放大（带 OSD 提示） |
| `Ctrl+Alt+4` | Anime4K 模式A+A | 双重重建增强（带 OSD 提示） |
| `Ctrl+Alt+5` | Anime4K 模式B+B | 双重重建增强（带 OSD 提示） |
| `Ctrl+Alt+6` | Anime4K 模式C+A | 降噪+重建组合（带 OSD 提示） |
| `Ctrl+7` | k7 Anime (MAIN) | k7 modernAnime ESRGAN 放大 |
| `Ctrl+8` | k7 Anime_DT (MAIN) | k7 modernAnime_DT ESRGAN 放大（暗调版） |
| `Ctrl+9` | QCOM (POSTKERNEL) | QCOM SGEDS 主缩放锐化 |
| `Ctrl+0` | 自适应锐化 (SCALED) | Adaptive Sharpen Lite，缩放后锐化 |

> Anime4K 模式使用 `Ctrl+Alt+数字` 而非 `Ctrl+Shift+数字`，因 mpv 中两者是同一物理键会冲突。详见 `portable_config/shaders/Anime4K/README.md`。

### 播放控制

| 快捷键 | 功能名 | 功能解释 |
|--------|--------|---------|
| `,` | 上一帧 | 后退一帧（逐帧查看） |
| `.` | 下一帧 | 前进一帧（逐帧查看） |
| `l` | AB循环 | 设置/清除 A-B 循环点 |
| `[` | 速度减档 | 在 2×/1.5×/1.2×/1× 间循环递减 |
| `]` | 速度加档 | 在 1×/1.2×/1.5×/2× 间循环递增 |
| `{` | 速度微减 | 速度 -0.1× |
| `}` | 速度微加 | 速度 +0.1× |
| `-` | 音量减 | 音量 -1 |
| `=` | 音量加 | 音量 +1 |
| `c` | 音频提前 | 音频延迟 -100ms（音频提前） |
| `v` | 音频延迟 | 音频延迟 +100ms |
| `z` | 字幕提前 | 字幕延迟 -100ms（字幕提前） |
| `x` | 字幕延迟 | 字幕延迟 +100ms |
| `Shift+BS` | 重置同步 | 重置音频与字幕延迟为 0 |

### 视频均衡器

| 快捷键 | 功能名 | 功能解释 |
|--------|--------|---------|
| `1` / `2` | 对比度 -/+ | 调整对比度 |
| `3` / `4` | 亮度 -/+ | 调整亮度/明度 |
| `5` / `6` | 伽马 -/+ | 调整伽马值 |
| `7` / `8` | 饱和度 -/+ | 调整饱和度/纯度 |
| `9` / `0` | 色相 -/+ | 调整色相 |
| `Ctrl+BS` | 重置均衡器 | 重置对比度/亮度/伽马/饱和度/色相为 0 |

### 截屏

| 快捷键 | 功能名 | 功能解释 |
|--------|--------|---------|
| `Ctrl+s` | 窗口截图（含字幕） | 截取缩放后的画面，包含字幕 |
| `Ctrl+S` | 窗口截图 | 截取原始窗口画面 |

### 工具

| 快捷键 | 功能名 | 功能解释 |
|--------|--------|---------|
| `Ctrl+i` | 按键绑定列表 | 打开 uosc 按键绑定查看菜单 |
| `I` | 统计信息 | 切换显示实时统计信息（帧率/分辨率/码率等） |
| `` ` `` | OSD命令行 | 打开 mpv 控制台/命令行 |
| `Ctrl+r` | 清除属性记录 | 清除 save_global_props 保存的属性值 |
| `g` 然后 `m` | select总菜单 | 打开 select 脚本的总菜单 |
| `g` 然后 `p` | select属性列表 | 打开 select 脚本的属性列表菜单 |

### 加载与退出

| 快捷键 | 功能名 | 功能解释 |
|--------|--------|---------|
| `Ctrl+Shift+v` | 加载剪贴板URL | 从剪贴板读取 URL 并加载播放 |
| `Ctrl+q` | 退出 | 退出 mpv |

### 画面操作

| 快捷键 | 功能名 | 功能解释 |
|--------|--------|---------|
| `BS` (退格键) | 重置画面 | 重置缩放、平移、对齐到默认 |
| `Alt`+鼠标左键拖拽 | 移动画面 | 拖拽平移视频画面 |
| `Alt`+滚轮 | 缩放画面 | 以鼠标位置为中心缩放 |

### 基本播放控制（鼠标/键盘/多媒体键）

| 快捷键 | 功能名 | 功能解释 |
|--------|--------|---------|
| `Space` | 暂停/播放 | 切换播放暂停 |
| `左/右方向键` | 快退/快进 5秒 | ±5 秒跳转 |
| `上/下方向键` | 精确跳转 1秒 | 暂停并 ±1 秒精确跳转 |
| `鼠标左键` | 暂停/播放 | 单击切换播放暂停 |
| `鼠标左键双击` | 全屏切换 | 双击切换全屏/窗口 |
| `鼠标右键` | uosc菜单 | 打开 uosc 右键菜单 |
| `Ctrl+鼠标右键` | 原生菜单 | 打开系统右键菜单 |
| `滚轮上/下` | 音量+/- | 调整音量 |
| `ESC` | 退出全屏 | 切换到窗口模式 |
| `ENTER` | 全屏 | 切换到全屏模式 |
| `Alt+ENTER` | 全屏切换 | 切换全屏/窗口 |
| `Ctrl+上/下` | 上/下一个文件 | uosc 跳转到播放列表上/下一个文件 |
| `鼠标侧键后退/前进` | 上/下一个文件 | 跳转上/下一个文件 |
| `小键盘 4/6` (NumLock灭) | 快退/快进 5秒 | ±5 秒跳转 |
| `小键盘 8/2` (NumLock灭) | 音量+/- | 调整音量 |
| `REWIND/FORWARD` | 快退/快进 30秒 | 多媒体键 ±30 秒 |
| `PREV/NEXT` | 上/下一个文件 | 多媒体键跳转文件 |
| `PLAY/PAUSE/PLAYPAUSE` | 播放控制 | 多媒体键播放/暂停 |
| `STOP` | 停止 | 多媒体键停止播放 |
| `POWER` | 退出 | 多媒体键退出 mpv |

## 许可

遵循原项目及 mpv 相关组件的许可证，详见 `LICENSE.txt` 与 `LICENSE.MD`。
