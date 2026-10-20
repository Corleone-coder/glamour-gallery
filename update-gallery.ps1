# ============================================================
#  光影志 - 图库更新脚本
#  作用：扫描 photos 文件夹里的图片，自动重建 gallery-data.js
#  用法：把照片放进 photos 文件夹后，双击上级目录的「更新图库.bat」
#        （也可以直接右键本文件 -> 使用 PowerShell 运行）
# ============================================================

$ErrorActionPreference = 'Stop'

$root     = $PSScriptRoot
$photoDir = Join-Path $root 'photos'
$outFile  = Join-Path $root 'gallery-data.js'

# ---------- 系列定义（照片按文件名顺序轮流分配） ----------
$seriesDefs = @(
  @{ name = '暗夜丝绒'; en = 'DARK VELVET';    desc = '黑与光之间最短的距离。';
     captions = @(
       '黑色蕾丝掠过石板路，高跟鞋把夜色敲出坐标。',
       '她靠在石柱上，影子比身体更先抵达。',
       '聚光灯只借给她一平米，她还回一整面墙的暗。',
       '丝绒一样的夜，被她的轮廓轻轻划开。',
       '所有的黑，都在为她让位。' ) },
  @{ name = '都市霓虹'; en = 'URBAN NEON';     desc = '把城市夜景借来，当一次自己的追光。';
     captions = @(
       '栏杆之外，整座城市都在失焦。',
       '车流是地面上的银河，她只借一束光起飞。',
       '霓虹替她说了前半句，后半句交给风。',
       '午夜十二点，街道是她的影棚。',
       '把城市夜景借来，当一次自己的追光。' ) },
  @{ name = '复古名伶'; en = 'RETRO GLAMOUR';  desc = '旧时光的聚光灯，至今还亮着一盏。';
     captions = @(
       '旧时光的聚光灯，至今还亮着一盏。',
       '波点裙里吹出来的，是五十年代的风。',
       '黑蕾丝手套、红唇、一封没有寄出的信。',
       '她不是路过老照片，是从老照片里走出来。',
       '胶片慢了半拍，刚好留住她的眼波。' ) },
  @{ name = '纯白之息'; en = 'WHITE BREATH';   desc = '白色不是空，是所有颜色的呼吸。';
     captions = @(
       '白裙子的褶皱里，藏着上午十点的太阳。',
       '她蹲在花瓣中间，和春天签了一份停战协议。',
       '白色不是空，是所有颜色的呼吸。',
       '影棚很安静，能听见棉花糖融化。',
       '留白是她的语言。' ) },
  @{ name = '海屿微风'; en = 'SEA BREEZE';     desc = '裙摆和浪，共用同一种节奏。';
     captions = @(
       '海风把裙摆吹成一面帆，白沙是它的码头。',
       '礁石记住每一个踩过它的脚印，包括她的。',
       '浪来了又走，她比浪慢半拍。',
       '把草帽压低一点，就拥有了整个夏天。',
       '裙摆和浪，共用同一种节奏。' ) },
  @{ name = '蔷薇迷雾'; en = 'ROSE MIST';      desc = '粉色迷雾里，视线自动聚焦。';
     captions = @(
       '粉色是她的保护色，也是她的进攻色。',
       '一面粉色的墙，足够排练一场顶级的告别。',
       '雾气把阳光过滤成她的肤色。',
       '她走过的地方，玫瑰都开了。',
       '粉色迷雾里，视线自动聚焦。' ) }
)

# ---------- 工具函数 ----------
function Get-ImageSize([byte[]]$b) {
  # PNG
  if ($b.Length -gt 24 -and $b[0] -eq 0x89 -and $b[1] -eq 0x50) {
    $w = ($b[16]*16777216) + ($b[17]*65536) + ($b[18]*256) + $b[19]
    $h = ($b[20]*16777216) + ($b[21]*65536) + ($b[22]*256) + $b[23]
    return @{ w = $w; h = $h }
  }
  # JPEG
  $i = 2
  while ($i -lt $b.Length - 9) {
    if ($b[$i] -ne 0xFF) { $i++; continue }
    $m = $b[$i+1]
    if ($m -in 0xC0,0xC1,0xC2,0xC3,0xC5,0xC6,0xC7,0xC9,0xCA,0xCB,0xCD,0xCE,0xCF) {
      $h = ($b[$i+5]*256) + $b[$i+6]
      $w = ($b[$i+7]*256) + $b[$i+8]
      return @{ w = $w; h = $h }
    }
    if ($m -eq 0xD8 -or $m -eq 0xD9 -or ($m -ge 0xD0 -and $m -le 0xD7)) { $i += 2; continue }
    $len = ($b[$i+2]*256) + $b[$i+3]
    if ($len -le 0) { break }
    $i += 2 + $len
  }
  return @{ w = 0; h = 0 }
}

function JsonStr([string]$s) {
  if ($null -eq $s) { return '""' }
  $t = $s.Replace('\', '\\').Replace('"', "'")
  return '"' + $t + '"'
}

function CleanTitle([string]$name, [int]$index) {
  $t = [System.IO.Path]::GetFileNameWithoutExtension($name)
  $t = $t -replace '-by-.+$', ''
  $t = $t -replace '^(IMG|DSC|MV|photo|PHOTO|image|IMAGE|截图|QQ图片)[\-_ ]?', ''
  $t = $t -replace '[\(\)\[\]\{\}]', ' '
  $t = $t -replace '[_\-]+', ' '
  $t = $t.Trim()
  if ($t.Length -lt 2 -or $t -match '^\d+$') { $t = '写真 No.' + ('{0:d2}' -f ($index + 1)) }
  if ($t.Length -gt 16) { $t = $t.Substring(0, 16) }
  return $t
}

# ---------- 扫描照片 ----------
if (-not (Test-Path $photoDir)) {
  New-Item -ItemType Directory -Path $photoDir | Out-Null
  Write-Host ''
  Write-Host '  [提示] photos 文件夹不存在，已自动创建。' -ForegroundColor Yellow
  Write-Host '  请把照片放进 photos 文件夹后再次运行本脚本。' -ForegroundColor Yellow
  Write-Host ''
}

$exts  = @('.jpg', '.jpeg', '.png', '.webp', '.gif', '.bmp', '.jfif', '.tif', '.tiff')
$files = Get-ChildItem -Path $photoDir -File |
         Where-Object { $exts -contains $_.Extension.ToLower() } |
         Sort-Object Name

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add('// ============================================================')
$lines.Add('//  本文件由「更新图库.bat」自动生成，请勿手动改动结构')
$lines.Add('//  增删 photos 文件夹里的照片后，重新双击「更新图库.bat」即可刷新')
$lines.Add('// ============================================================')
$lines.Add('window.GALLERY_READY = true;')
$lines.Add('window.GALLERY_DATA = {')
$lines.Add('  "site": {')
$lines.Add('    "title": "光影志",')
$lines.Add('    "titleEn": "GLAMOUR GALLERY",')
$lines.Add('    "vol": "VOL.01",')
$lines.Add('    "year": "2026",')
$lines.Add('    "tagline": "一场关于光与注视的暗房展览 —— 十二帧风格肖像，六组主题系列。"')
$lines.Add('  },')
$lines.Add('  "series": [')

$seriesEntries = New-Object System.Collections.Generic.List[string]
for ($k = 0; $k -lt $seriesDefs.Count; $k++) {
  $sd = $seriesDefs[$k]
  $seriesEntries.Add(('    { "key": "s' + ($k + 1) + '", "name": ' + (JsonStr $sd.name) + ', "en": "' + $sd.en + '", "desc": ' + (JsonStr $sd.desc) + ' }'))
}
$lines.Add(($seriesEntries -join ",`n"))
$lines.Add('  ],')
$lines.Add('  "photos": [')

$photoEntries = New-Object System.Collections.Generic.List[string]
$i = 0
foreach ($f in $files) {
  $bytes = [System.IO.File]::ReadAllBytes($f.FullName)
  $sz    = Get-ImageSize $bytes
  $s     = $seriesDefs[$i % $seriesDefs.Count]
  $cap   = $s.captions[$i % $s.captions.Count]
  $title = CleanTitle $f.Name $i
  $credit = ''
  if ($f.BaseName -match '-by-(.+)$') { $credit = '@' + $Matches[1] }
  $num   = '{0:d2}' -f ($i + 1)
  $photoEntries.Add(('    { "file": "photos/' + $f.Name + '", "title": ' + (JsonStr $title) + ', "num": "' + $num + '", "series": "s' + (($i % $seriesDefs.Count) + 1) + '", "caption": ' + (JsonStr $cap) + ', "w": ' + $sz.w + ', "h": ' + $sz.h + ', "credit": ' + (JsonStr $credit) + ' }'))
  $i++
}
$lines.Add(($photoEntries -join ",`n"))
$lines.Add('  ]')
$lines.Add('};')
$lines.Add('')

[System.IO.File]::WriteAllText($outFile, ($lines -join "`r`n"), (New-Object System.Text.UTF8Encoding($false)))

Write-Host ''
if ($files.Count -gt 0) {
  Write-Host ('  [完成] 已扫描到 ' + $files.Count + ' 张照片，列表已更新。') -ForegroundColor Green
} else {
  Write-Host '  [完成] photos 文件夹里还没有图片，网站会显示空状态提示。' -ForegroundColor Yellow
}
Write-Host '  文件位置：gallery-data.js' -ForegroundColor DarkGray
Write-Host ''
