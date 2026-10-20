<div align="center">

# 光影志 · Glamour Gallery

**一个开箱即用的静态写真集 / 摄影作品集网站模板**

把照片丢进 `photos/`，双击一个 bat，就能得到一个带筛选、灯箱、明暗主题的完整画廊。

纯静态 · 零依赖 · 无需服务器 · 可直接部署到 GitHub Pages

</div>

![首页预览](docs/preview-hero.jpg)

## 特性

- **六组主题系列**：暗夜丝绒 / 都市霓虹 / 复古名伶 / 纯白之息 / 海屿微风 / 蔷薇迷雾，支持标签筛选
- **瀑布流影集**：按图片真实宽高比排布，横竖混排也不乱
- **灯箱浏览**：键盘 `←` `→` 切换、`Esc` 关闭、底部缩略图直达、移动端左右滑动
- **明暗双主题**：右下角 TWEAKS 面板切换，选择记忆在本地
- **一键更新**：`更新图库.bat` 自动扫描 `photos/`，重建图片清单
- **响应式**：桌面 3 列 / 平板 2 列 / 手机 2 列（超窄屏 1 列）
- **纯静态**：无框架、无构建步骤、无外部 JS 依赖，双击 `index.html` 即可浏览

## 预览

**系列页**

![系列页](docs/preview-series.jpg)

**影集页**

![影集页](docs/preview-gallery.jpg)

<p align="center">
  <img src="docs/preview-mobile.jpg" width="320" alt="移动端预览">
</p>

## 快速开始

### Windows

1. 把照片复制进 `photos/` 文件夹（支持 jpg / jpeg / png / webp / gif / bmp）
2. 双击根目录的 **`更新图库.bat`**
3. 浏览器打开 `index.html`

### macOS / Linux

需要安装 PowerShell 7（`pwsh`）：

```bash
pwsh ./update-gallery.ps1
open index.html        # Linux 用 xdg-open
```

也可以跳过脚本，手动编辑 `gallery-data.js` 添加图片条目。

## 目录结构

```
glamour-gallery/
├─ index.html            网站（单文件，内联 CSS / JS）
├─ gallery-data.js       图片清单：标题 / 文案 / 系列 / 尺寸
├─ photos/               照片文件夹（把图放这里）
├─ update-gallery.ps1    扫描脚本（读取图片尺寸、生成清单）
├─ 更新图库.bat           Windows 双击入口
└─ docs/                 README 预览图
```

## 自定义

### 1. 标题与文案

编辑 `gallery-data.js` 中的 `photos` 数组：

```js
{
  "file": "photos/img-01.jpg",   // 图片相对路径
  "title": "丝绒步态",            // 卡片与灯箱标题
  "num": "01",                    // 序号（可留空自动生成）
  "series": "s1",                 // 所属系列 key
  "caption": "黑色蕾丝掠过石板路……", // 灯箱文案
  "w": 1200, "h": 1500,           // 原图宽高，用于占位比例，可填 0
  "credit": "@alipazani"          // 摄影署名
}
```

> 注意：重新运行 `更新图库.bat` 会覆盖这个文件，所以自定义请在最后一步做。

### 2. 系列名称与文案池

编辑 `update-gallery.ps1` 顶部的 `$seriesDefs`：系列名、英文名、描述、以及自动分配用的文案池。修改后重新运行脚本生效；也可以直接改 `gallery-data.js` 里的 `series` 数组。

### 3. 自动识别摄影署名

文件名里带 `-by-` 即可自动提取署名：

```
海边写真-by-小林.jpg  →  标题「海边写真」，署名「@小林」
```

### 4. 站点标题

修改 `gallery-data.js` 的 `site` 字段（标题、英文名、卷号、标语），或直接改 `index.html` 里 `window.DEMO_DATA.site` 的默认值。

## 部署

### GitHub Pages

1. 仓库 **Settings → Pages**
2. Source 选择 `Deploy from a branch`
3. 分支选 `main`，目录选 `/ (root)`，保存
4. 稍等一分钟，访问 `https://<用户名>.github.io/<仓库名>/`

### 其他静态托管

整个文件夹直接拖进 Vercel / Netlify / Cloudflare Pages 即可，无需构建命令和输出目录配置。

## 兼容性

- 现代浏览器（Chrome / Edge / Safari / Firefox 近两年版本）
- 直接双击本地打开（`file://`）也能正常运行，无需本地服务器
- 字体通过 Google Fonts 加载，失败时自动回退到系统衬线字体

## 图片与版权

- 仓库内 `photos/` 的 12 张示例照片来自 [Pexels](https://www.pexels.com/)，遵循 Pexels License，可免费使用
- 替换成自己的照片时，请确认你拥有相应的版权与肖像授权

## License

代码以 MIT 协议开源；示例图片版权归原作者所有，遵循 Pexels License。
