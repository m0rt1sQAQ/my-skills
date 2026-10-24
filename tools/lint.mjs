#!/usr/bin/env node
// 校验 skills/<name>/SKILL.md 是否符合 DSH 技能加载器的硬性要求。
// 用法：node tools/lint.mjs [skillsDir]
import { readFileSync, readdirSync, statSync, existsSync } from 'node:fs';
import { join } from 'node:path';

const root = process.argv[2] ?? 'skills';
const MAX_DESC = 500;
const problems = [];
const fail = (m) => problems.push(m);

function parseFrontmatter(text) {
  const m = /^---\r?\n([\s\S]*?)\r?\n---\r?\n/.exec(text);
  if (!m) return null;
  const out = {};
  let key = null;
  for (const raw of m[1].split(/\r?\n/)) {
    const kv = /^([A-Za-z][\w-]*):\s*(.*)$/.exec(raw);
    if (kv) {
      key = kv[1];
      const v = kv[2].trim();
      out[key] = v === '|' || v === '>' ? '' : v.replace(/^['"]|['"]$/g, '');
      continue;
    }
    if (key && /^\s+\S/.test(raw)) out[key] = (out[key] ? out[key] + ' ' : '') + raw.trim();
  }
  return out;
}

if (!existsSync(root)) {
  console.error('missing skills dir: ' + root);
  process.exit(1);
}

const names = readdirSync(root).filter((d) => statSync(join(root, d)).isDirectory());
if (names.length === 0) fail('skills 目录为空');

for (const dir of names) {
  const path = join(root, dir);
  const file = join(path, 'SKILL.md');
  if (!existsSync(file)) {
    fail(dir + ': 缺少 SKILL.md');
    continue;
  }
  let text = readFileSync(file, 'utf8');
  if (text.charCodeAt(0) === 0xfeff) {
    fail(dir + ': 文件带 UTF-8 BOM，加载器会解析不到 frontmatter');
    text = text.slice(1);
  }

  const fm = parseFrontmatter(text);
  if (!fm) {
    fail(dir + ': 缺少合法 frontmatter（第一行必须是 ---）');
    continue;
  }

  if (!fm.name) fail(dir + ': 缺少 name');
  else if (fm.name !== dir) fail(dir + ': name "' + fm.name + '" 与目录名不一致');
  else if (!/^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(fm.name)) fail(dir + ': name 必须是 kebab-case');

  if (!fm.description) fail(dir + ': 缺少 description');
  else if ([...fm.description].length > MAX_DESC)
    fail(dir + ': description 超过 ' + MAX_DESC + ' 字符，会被目录截断');

  for (const bad of ['disableModelInvocation', 'modelInvocable', 'userInvocable', 'when_to_use']) {
    if (bad in fm) fail(dir + ': 字段名非法 "' + bad + '"');
  }

  for (const ref of text.matchAll(/(?:\(|`|\s)((?:references|scripts|assets)\/[\w./-]+)/g)) {
    if (!existsSync(join(path, ref[1]))) fail(dir + ': 引用不存在 → ' + ref[1]);
  }

  const lines = text.split(/\r?\n/).length;
  if (lines > 800) fail(dir + ': 正文 ' + lines + ' 行，建议拆分到 references/');
}

if (problems.length) {
  console.error('✗ ' + problems.length + ' 个问题');
  for (const p of problems) console.error(' - ' + p);
  process.exit(1);
}
console.log('✓ ' + names.length + ' 个技能通过检查');
