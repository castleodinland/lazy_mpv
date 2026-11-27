# Anime4K 着色器集成说明

## 简介

[Anime4K](https://github.com/bloc97/Anime4K) 是一套专为动画优化的实时 GLSL 着色器，可在播放时进行画质恢复（Restore）、放大（Upscale）、降噪（Denoise）等处理。本项目集成了 Anime4K v4.x 的完整着色器集，并通过快捷键一键切换预设模式。

## 集成步骤（已完成）

### 1. 下载着色器

从 https://github.com/bloc97/Anime4K 克隆仓库（如访问困难可用代理 `http://127.0.0.1:7897`）：

```bash
git -c http.proxy=http://127.0.0.1:7897 -c https.proxy=http://127.0.0.1:7897 clone --depth 1 https://github.com/bloc97/Anime4K
```

### 2. 复制 glsl 文件

将 `glsl/` 下各子目录的 `.glsl` 文件**扁平复制**到 `portable_config/shaders/Anime4K/`：

```bash
cp Anime4K/glsl/*/*.glsl portable_config/shaders/Anime4K/
```

本目录共 49 个着色器文件，按功能分类（来源子目录）：

| 分类 | 说明 | 文件示例 |
|------|------|---------|
| Restore | 画质恢复（线重建） | `Anime4K_Restore_CNN_*.glsl`、`Anime4K_Clamp_Highlights.glsl` |
| Upscale | 放大（超分辨率） | `Anime4K_Upscale_CNN_x2_*.glsl`、`Anime4K_Upscale_GAN_x2_*.glsl` |
| Upscale+Denoise | 放大同时降噪 | `Anime4K_Upscale_Denoise_CNN_x2_*.glsl` |
| Denoise | 独立降噪 | `Anime4K_Denoise_Bilateral_*.glsl` |
| Deblur | 去模糊 | `Anime4K_Deblur_*.glsl` |
| Experimental-Effects | 实验效果（暗化/线条细化） | `Anime4K_Darken_*.glsl`、`Anime4K_Thin_*.glsl` |

### 3. 配置快捷键

在 `portable_config/input_uosc.conf` 中添加了以下绑定（基于官方 High-end 模板，路径适配本项目的 `Anime4K/` 子目录）：

## 按键绑定

> **重要**：mpv 中 `Ctrl+数字` 与 `Ctrl+Shift+数字` 实际是同一物理键（数字键的 keyname 在 mpv 中会被标准化为带 Shift 的版本），会导致绑定互相覆盖。因此模式绑定使用 `Ctrl+Alt+数字`（Alt 与 Shift 是不同 modifier，不冲突），单着色器保留原有的 `Ctrl+5/6`。

### 预设模式（一键切换，`set` 替换整个着色器链）

| 按键 | 模式 | 适用场景 | 着色器组合 |
|------|------|---------|-----------|
| `Ctrl+Alt+1` | Mode A (HQ) | 1080p 动画 | Clamp + Restore_CNN_VL + Upscale_CNN_x2_VL + AutoDownscale×2/×4 + Upscale_CNN_x2_M |
| `Ctrl+Alt+2` | Mode B (HQ) | 720p 动画 | Clamp + Restore_CNN_Soft_VL + Upscale_CNN_x2_VL + AutoDownscale×2/×4 + Upscale_CNN_x2_M |
| `Ctrl+Alt+3` | Mode C (HQ) | 480p 动画 | Clamp + Upscale_Denoise_CNN_x2_VL + AutoDownscale×2/×4 + Upscale_CNN_x2_M |
| `Ctrl+Alt+4` | Mode A+A (HQ) | 双重重建 | Mode A + Restore_CNN_M |
| `Ctrl+Alt+5` | Mode B+B (HQ) | 双重重建 | Mode B + Restore_CNN_Soft_M |
| `Ctrl+Alt+6` | Mode C+A (HQ) | 降噪+重建 | Mode C + Restore_CNN_M |

### 单着色器开关（`toggle`，可自由组合）

| 按键 | 着色器 | 说明 |
|------|--------|------|
| `Ctrl+5` | `Anime4K_Restore_CNN_L.glsl` | A4K 重建（单个，带 OSD 提示） |
| `Ctrl+6` | `Anime4K_Upscale_GAN_x2_M.glsl` | A4K 放大（单个，带 OSD 提示） |

### 清空

| 按键 | 功能 |
|------|------|
| `Ctrl+`` | 清空所有着色器 |

## OSD 启动提示

每个预设模式绑定都包含 `show-text` 命令，切换时会在屏幕上显示 5 秒提示，例如：

```
Anime4K: Mode A (HQ) 已启动 - 1080p优化
```

这样用户可以明确知道当前启用了哪个模式。

## 模式选择建议

- **Mode A**：适合高质量 1080p 动画源，线重建 + 放大
- **Mode B**：适合 720p 动画源，柔和线重建 + 放大
- **Mode C**：适合 480p 等低清动画源，降噪 + 放大
- **Mode A+A / B+B / C+A**：在基础模式上叠加二次重建，效果更强但 GPU 负载更高

> 预设基于官方 High-end 模板（VL/M 级模型），适合 GTX 1080 / RTX 2070 及以上 GPU。
> 低端 GPU 可参考官方 Low-end 模板改用 L/S 级模型。

## 测试验证

已通过端到端测试（mpv + lavfi 测试视频 + 模拟按键）：
- `Ctrl+Alt+1` → 成功加载 6 个 Mode A 着色器 ✓
- `Ctrl+`` → 成功清空所有着色器 ✓
- OSD 提示命令已嵌入绑定，实际播放时会显示 ✓

## 来源与许可

- 项目地址：https://github.com/bloc97/Anime4K
- 版本：v4.x（main 分支）
- 许可证：见仓库 LICENSE 文件
- mpv 集成文档：https://github.com/bloc97/Anime4K/blob/main/md/GLSL_Instructions_Windows_MPV.md
