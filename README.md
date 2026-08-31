# DSH Web Launcher

适用于 Windows 的轻量 DSH Web 启动器。双击即可自动检查 DeepSeek Harness 更新，并使用独立的 `web` profile 启动浏览器界面。

> 本项目是社区启动脚本，并非 DeepSeek 官方项目。DeepSeek、DeepSeek Harness 及相关图标的权利归其各自所有者。

## 快速开始

### 1. 安装运行环境

安装 [Node.js LTS](https://nodejs.org/)，并确认 Windows Terminal 或命令提示符可以运行：

```powershell
node --version
npm.cmd --version
```

### 2. 获取启动器

从本仓库的 [Releases](https://github.com/louishzwang/dsh-web-launcher/releases) 下载并解压，或者使用 Git：

```powershell
git clone https://github.com/louishzwang/dsh-web-launcher.git
```

### 3. 启动

双击 `dsh-web-launcher.bat`。首次运行时，如果尚未安装 DSH，启动器会从官方 npm registry 自动安装最新的 GitHub 发布版本；服务就绪后由 DSH 打开浏览器。

也可以从希望作为工作目录的文件夹启动：

```powershell
& "C:\path\to\dsh-web-launcher.bat"
```

DSH Web 默认监听 `127.0.0.1:3080`，并使用一次性启动 token 完成本地浏览器认证。

## Windows Terminal（可选）

在 Windows Terminal 设置中新增 Profile：

- **名称**：`DSH Web Launcher`
- **命令行**：选择解压目录中的 `dsh-web-launcher.bat`
- **启动目录**：选择希望 DSH 使用的工作目录
- **图标**：可选择仓库中的 `deepseek-harness.ico`

启动目录决定 DSH 默认操作的工作区，建议不要设置为整个系统盘。

## 启动行为

每次启动时，脚本会：

1. 从 DeepSeek Harness 官方 GitHub Releases 查找最新的非草稿 `dsh-v*` SemVer 版本。
2. 本机版本相同：直接启动。
3. 官方 npm registry 存在完全相同的版本：全局更新 `@deepseek-ai/dsh` 后启动。
4. 断网、查询超时、npm 尚未同步或更新失败：保留并启动当前可用版本。
5. 运行 `dsh.cmd --profile web --port 3080`。

GitHub 已发布但 npm 尚未同步时，启动器不会尝试源码构建，也不会覆盖当前版本。

## Profile 隔离

- DSH Web：`%USERPROFILE%\.dsh\profiles\web`
- 启动器只指定 `--profile web`，不会修改其他 profile。

## 安全说明

- 更新仅查询 `api.github.com/deepseek-ai/deepseek-harness`，并仅从官方 npm registry 安装固定包名 `@deepseek-ai/dsh@<精确版本>`。
- 安装 DSH 会执行该官方 npm 包明确允许的安装脚本，并修改当前 npm 配置的全局包目录。
- Web 服务默认只绑定 `127.0.0.1`；不要把带 `?token=...` 的启动地址分享给其他人。
- 启动器本身不会收集或上传工作区、账号、API Key 或 DSH profile。
- `.gitignore` 已排除常见环境变量文件、私钥、凭据、依赖和编辑器本地配置，但公开提交前仍应检查 `git diff --cached`。

## 常见问题

### 无法检查更新

如果本机已经安装 DSH，启动器会显示警告并继续启动当前版本。首次运行且尚未安装 DSH 时，需要恢复 GitHub 和 npm 网络访问。

### 找不到 Node.js、npm 或 dsh.cmd

重新安装 Node.js LTS，关闭并重新打开终端后再运行启动器。首次安装 DSH 需要 `npm.cmd` 可用。

### 端口 3080 被占用

关闭已有的 DSH Web 实例或占用该端口的程序，然后重新启动。

## 项目文件

- `dsh-web-launcher.bat`：双击及 Windows Terminal 入口
- `dsh-web.ps1`：版本检查、失败回退和 DSH Web 启动逻辑
- `deepseek-harness.ico`：可选的 Windows Terminal 图标
- `LICENSE`：MIT License

## 维护验证

修改后至少检查 PowerShell 语法、GitHub 版本解析、无网络回退和 `web` profile 启动。更新逻辑只保留在 `dsh-web.ps1` 中。
