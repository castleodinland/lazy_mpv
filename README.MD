# lazy_mpv

基于 [mpv](https://github.com/mpv-player/mpv) 的 Windows 便携播放器整合包（解压即用），内置 Python 运行环境、VapourSynth 滤镜链、着色器与 uosc 界面等完整配置。

## 说明

本仓库是个人使用的配置存档与定制版本，主要用于记录和同步自己的快捷键、滤镜、着色器等设置。

配置文件位于 `portable_config/` 目录，其中输入配置为 `input_uosc.conf`。文本文件统一使用 **UTF-8** 编码、**LF** 换行。

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

## 许可

遵循原项目及 mpv 相关组件的许可证，详见 `LICENSE.txt` 与 `LICENSE.MD`。
