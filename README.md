# my-skills

给 DeepSeek Harness 一类 agent 用的技能集合。每个技能都是纯 `SKILL.md`（可选 `references/`），不依赖网络、不依赖第三方库。

| 技能 | 一句话 |
|---|---|
| [`shot-exam`](skills/shot-exam/SKILL.md) | 把考试题截图转成结构化作答：题型识别、逐题答案 + 依据、末尾汇总行 |

## 安装

### Windows（PowerShell 5.1+）

```powershell
git clone https://github.com/<你的用户名>/my-skills.git "$env:USERPROFILE\my-skills"
cd "$env:USERPROFILE\my-skills"
.\install.ps1
```

已 clone 到任意位置时，直接在该目录运行 `.\install.ps1` 即可；默认用 **junction** 挂到 `~/.dsh/skills`，仓库里的改动立即生效。

- 装到别处：`.\install.ps1 -SkillsHome "D:\other\skills"`
- 复制而非链接：`.\install.ps1 -Copy`
- 卸载：`.\install.ps1 -Uninstall`

### macOS / Linux

```bash
git clone https://github.com/<你的用户名>/my-skills.git ~/my-skills
cd ~/my-skills
./install.sh
```

### 手动安装单个技能

```bash
git clone https://github.com/<你的用户名>/my-skills.git /tmp/my-skills
cp -R /tmp/my-skills/skills/shot-exam ~/.dsh/skills/
```

技能目录按以下顺序被发现（DSH 默认）：项目根的 `.dsh/skills` → 项目根的 `.agents/skills` → `~/.dsh/skills` → `~/.agents/skills`。**只扫一层**：必须是 `<根>/<技能名>/SKILL.md`。

## shot-exam 用法

把题目截图发过去，说一句"看看这几道题选什么"即可触发；也可以直接说技能名。

输出形态：

```
1. 答案：C
   依据：兰新高铁 1776 km，为目前一次性建成通车里程最长的高速铁路。

汇总：1-C 2-B 3-BCD 4-BC 5-错 6-错
```

它处理三件事：

1. **题型判定**：单选 / 不定项 / 判断，不定项只写一个算错。
2. **依据可检验**：公式、定义、年份、条文；不写"通常认为"。
3. **口径冲突**：教材与行业标准答案不一致时，给主答案并注明备选，而不是含糊过去。

细则见 [`references/rules.md`](skills/shot-exam/references/rules.md)。

## 仓库结构

```
my-skills/
├── skills/
│   └── shot-exam/
│       ├── SKILL.md          # 触发描述 + 工作流，加载器只读这一层
│       └── references/       # 按需读取的细则
├── tools/lint.mjs            # frontmatter 校验
├── install.ps1 / install.sh  # 一键挂载到技能目录
└── .github/workflows/lint.yml
```

## SKILL.md 规则（本仓库遵守）

| 字段 | 要求 |
|---|---|
| `name` | 必填，等于目录名，匹配 `^[a-z0-9]+(?:-[a-z0-9]+)*$` |
| `description` | 必填，**触发器的全部**；≤500 字符，触发词放前面 |
| `whenToUse` | 可选，不会进入目录，别把触发条件只写在这里 |
| `disable-model-invocation` | 可选布尔；写成 `disableModelInvocation` 会导致整个技能被丢弃 |
| 文件编码 | UTF-8 **无 BOM**，第一行必须是 `---` |

## 编码约定（踩过的坑）

这三种文件对 BOM 的要求**不一致**，混了就会静默失败：

| 文件 | 编码 | 原因 |
|---|---|---|
| `SKILL.md` / `*.md` | UTF-8 **无 BOM** | 加载器要求第一行严格等于 `---`，BOM 会让整个技能被丢弃 |
| `install.ps1` / `*.ps1` | UTF-8 **带 BOM** | PowerShell 5.1 读无 BOM 的 UTF-8 会按 GBK 解码，中文串末尾的引号被吞掉，导致后续代码全部失效且退出码仍为 0 |
| `install.sh` / `*.sh` | UTF-8 无 BOM + LF | BOM 会破坏 `#!/usr/bin/env bash` shebang |

验证方法：

```powershell
# 看前 3 个字节，EF BB BF 就是 BOM
$b = [System.IO.File]::ReadAllBytes('install.ps1'); ($b[0..2] | % { $_.ToString('X2') }) -join ' '
```

## 校验

```bash
node tools/lint.mjs skills
```

检查项：BOM、frontmatter 可解析、name 与目录一致、name 合法、description 长度、非法字段名、`references/` 等相对引用是否存在、正文行数上限。

## 已知限制

- 纯指令型技能，不含 OCR 脚本，识别依赖 agent 自身的视觉能力。
- 图片极度模糊时只能标注"无法辨认"，不会编造选项。
- 判分口径以题目所属课程为准，本仓库不背书任何单一教材。

## 许可

[MIT](LICENSE)
