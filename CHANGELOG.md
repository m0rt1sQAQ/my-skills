# Changelog

本项目遵循 [Semantic Versioning](https://semver.org/lang/zh-CN/)。

## [0.1.0] - 2026-10-24

### Added

- `shot-exam` 技能：题目截图 → 结构化作答（单选 / 不定项 / 判断），逐题答案 + 可检验依据 + 末尾汇总行。
- `references/rules.md`：题型识别关键词、依据合格标准、口径冲突处理、学科常见陷阱、置信度与汇总规范。
- `tools/lint.mjs`：校验 BOM、frontmatter、name 一致性、description 长度、非法字段名与相对引用。
- `install.ps1` / `install.sh`：junction / 软链一键挂载到 `~/.dsh/skills`。
- GitHub Actions：push 与 PR 自动跑 frontmatter 校验。
