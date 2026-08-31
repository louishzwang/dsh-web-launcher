$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$launcherVersion = '2.0.0'
$packageName = '@deepseek-ai/dsh'
$registry = 'https://registry.npmjs.org'
$releasesApi = 'https://api.github.com/repos/deepseek-ai/deepseek-harness/releases?per_page=10'
$releaseTagPattern = '^dsh-v(?<version>[0-9]+\.[0-9]+\.[0-9]+(?:-[0-9A-Za-z.-]+)?(?:\+[0-9A-Za-z.-]+)?)$'
$allowedScripts = '@deepseek-ai/dsh-subprocess-local,koffi,node-pty,@google/genai,protobufjs'

function Get-DshCommand {
  $command = Get-Command dsh.cmd -ErrorAction SilentlyContinue
  if ($null -eq $command) { return $null }
  return $command.Source
}

function Get-DshVersion([string]$command) {
  if ([string]::IsNullOrWhiteSpace($command)) { return $null }
  $version = (& $command --version 2>$null | Select-Object -First 1)
  if ($null -eq $version) { return $null }
  return $version.Trim()
}

function Get-LatestGithubVersion {
  $headers = @{ 'User-Agent' = 'DSH-Web-Launcher' }
  $releases = Invoke-RestMethod -Uri $releasesApi -Headers $headers -TimeoutSec 8
  $release = @($releases) |
    Where-Object { -not $_.draft -and $_.tag_name -match $releaseTagPattern } |
    Select-Object -First 1
  if ($null -eq $release) { throw 'GitHub 中没有找到 DSH 发布版本' }
  return [regex]::Match($release.tag_name, $releaseTagPattern).Groups['version'].Value
}

function Update-DshIfNeeded {
  $dsh = Get-DshCommand
  $current = Get-DshVersion $dsh

  try {
    $target = Get-LatestGithubVersion
    $displayCurrent = if ($null -eq $current) { '未安装' } else { $current }
    Write-Host "当前版本：$displayCurrent"
    Write-Host "最新版本：$target"
    Write-Host
    if ($current -eq $target) {
      Write-Host '已是最新版本。'
      return $dsh
    }

    $npm = (Get-Command npm.cmd -ErrorAction Stop).Source
    $published = (& $npm view "$packageName@$target" version --json "--registry=$registry" 2>$null | Out-String).Trim().Trim('"')
    if ($published -ne $target) {
      Write-Host "发现新版本：$target"
      Write-Warning '该版本尚未同步到官方 npm，将继续使用当前版本。'
      return $dsh
    }

    Write-Host "发现新版本，正在更新到 $target..."
    & $npm install --global "--allow-scripts=$allowedScripts" "$packageName@$target" "--registry=$registry"
    if ($LASTEXITCODE -ne 0) {
      Write-Warning "新版本更新失败（退出码 $LASTEXITCODE），将继续使用当前版本。"
      return (Get-DshCommand)
    }

    $dsh = Get-DshCommand
    $installed = Get-DshVersion $dsh
    if ($installed -ne $target) { throw "更新后检测到的版本为 $installed，预期版本为 $target" }
    Write-Host "更新完成：$installed"
    return $dsh
  }
  catch {
    Write-Warning "暂时无法检查更新，将继续使用当前版本。原因：$($_.Exception.Message)"
    return $dsh
  }
}

Write-Host "DSH Web Launcher v$launcherVersion"
Write-Host
Write-Host '正在检查更新...'
Write-Host

$dshCommand = Update-DshIfNeeded
if ([string]::IsNullOrWhiteSpace($dshCommand)) {
  throw '未检测到 DSH，且无法自动完成安装。请检查网络连接以及 Node.js、npm 是否正常安装。'
}

Write-Host
Write-Host '正在启动 DSH Web，请稍后...'
& $dshCommand --profile web --port 3080
exit $LASTEXITCODE
