# 项目长期记忆：mpv-lazy

- 配置目录为 `portable_config/`，mpv 主体在仓库根目录（`mpv.exe`）。
- 输入配置文件是 `input_uosc.conf`（不是标准 `input.conf`），由 `mpv.conf` 中 `input-conf = "~~/input_uosc.conf"` 指定。
- `mpv.conf` 设置了 `input-builtin-bindings = no`，即所有按键绑定仅由 `input_uosc.conf` 决定，无内置默认绑定。
- 文本文件约定 UTF-8 编码、LF 换行（已设 `core.autocrlf false`）。
