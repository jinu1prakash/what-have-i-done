// Behavior tests for the OpenCode plugin, using a fake harness surface.
//
// The plugin has two jobs: register the skills directory, and inject the
// bootstrap into the first user message exactly once. The transform runs on
// every agent step, so "exactly once" is the load-bearing property.

import assert from 'node:assert/strict';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const here = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(here, '..');

const { WhatHaveIDonePlugin } = await import(
  path.join(repoRoot, '.opencode/plugins/what-have-i-done.js')
);

const results = [];
const check = (name, fn) => {
  try {
    fn();
    results.push(['pass', name]);
  } catch (err) {
    results.push(['fail', `${name}: ${err.message}`]);
  }
};

const plugin = await WhatHaveIDonePlugin();

// --- config hook: skills directory registration ---------------------------

const config = {};
await plugin.config(config);

check('config hook registers the skills directory', () => {
  assert.ok(Array.isArray(config.skills?.paths), 'skills.paths not created');
  assert.equal(config.skills.paths.length, 1);
  assert.equal(config.skills.paths[0], path.join(repoRoot, 'skills'));
});

check('config hook is idempotent', async () => {
  const before = config.skills.paths.length;
  plugin.config(config);
  assert.equal(config.skills.paths.length, before, 'duplicated the skills path');
});

check('config hook preserves existing paths', async () => {
  const other = { skills: { paths: ['/somewhere/else'] } };
  await plugin.config(other);
  assert.deepEqual(other.skills.paths, ['/somewhere/else', path.join(repoRoot, 'skills')]);
});

// --- message transform: bootstrap injection --------------------------------

const transform = plugin['experimental.chat.messages.transform'];
const makeSession = () => ({
  messages: [
    { info: { role: 'user' }, parts: [{ type: 'text', text: 'do the thing' }] },
  ],
});

const session = makeSession();
await transform({}, session);
const injected = session.messages[0].parts[0].text;

check('injects the bootstrap into the first user message', () => {
  assert.equal(session.messages[0].parts.length, 2);
  assert.match(injected, /<EXTREMELY_IMPORTANT>/);
});

check('injected bootstrap contains the skill body', () => {
  assert.match(injected, /Completion is a gate, not a feeling/);
});

check('injected bootstrap has YAML frontmatter stripped', () => {
  assert.ok(
    !injected.includes('description: Use when starting any conversation'),
    'frontmatter leaked into the injected message'
  );
});

check('injected bootstrap carries the OpenCode tool mapping', () => {
  assert.match(injected, /OpenCode tool mapping/);
  assert.match(injected, /subagent_type: "general"/);
});

check('original user text is preserved after the bootstrap', () => {
  assert.equal(session.messages[0].parts[1].text, 'do the thing');
});

// The transform fires on every agent step; a second call must be a no-op.
await transform({}, session);
await transform({}, session);
check('dedup guard prevents repeat injection', () => {
  assert.equal(session.messages[0].parts.length, 2);
});

check('no-op on an empty message list', async () => {
  const empty = { messages: [] };
  await transform({}, empty);
  assert.deepEqual(empty.messages, []);
});

check('no-op when there is no user message', async () => {
  const noUser = {
    messages: [{ info: { role: 'assistant' }, parts: [{ type: 'text', text: 'hi' }] }],
  };
  transform({}, noUser);
  assert.equal(noUser.messages[0].parts.length, 1);
});

// --- the tool mapping is duplicated on purpose; keep the copies honest -------
//
// The plugin injects the mapping inline rather than trusting the reference file
// to be read, and INSTALL.md repeats it for humans. Three copies drift silently
// unless something checks. CLAUDE.md documents the rule; this enforces it.

import fs from 'node:fs';

// Only the mapping tables count -- prose elsewhere in these files mentions
// backticked words like `config` that are not tool names.
const toolsInTable = (file) => {
  const text = fs.readFileSync(path.join(repoRoot, file), 'utf8');
  const rows = text.split('\n').filter((l) => l.startsWith('|'));
  return [...new Set([...rows.join('\n').matchAll(/`([a-z_]+)`/g)].map((m) => m[1]))].sort();
};

const renderedMapping = injected.split('OpenCode tool mapping')[1] ?? '';

// The invariant that matters is directional: nothing documented in the
// reference may be missing from what the plugin actually injects. The injected
// text is what the model sees; the reference is only read on request.
const assertNoneMissing = (label, tools) => {
  const missing = tools.filter((t) => !renderedMapping.includes(`\`${t}\``));
  assert.deepEqual(missing, [], `${label} documents tools the plugin never injects: ${missing.join(', ')}`);
};

check('plugin injects every tool in references/opencode-tools.md', () => {
  const tools = toolsInTable('skills/using-what-have-i-done/references/opencode-tools.md');
  assert.ok(tools.length >= 8, `expected a populated mapping table, got ${tools.length} entries`);
  assertNoneMissing('references/opencode-tools.md', tools);
});

check('plugin injects every tool in .opencode/INSTALL.md', () => {
  const tools = toolsInTable('.opencode/INSTALL.md');
  assert.ok(tools.length >= 8, `expected a populated mapping table, got ${tools.length} entries`);
  assertNoneMissing('.opencode/INSTALL.md', tools);
});

// --- report ----------------------------------------------------------------

let failed = 0;
for (const [status, name] of results) {
  if (status === 'pass') {
    console.log(`    \x1b[32m·\x1b[0m ${name}`);
  } else {
    console.log(`    \x1b[31m✗\x1b[0m ${name}`);
    failed += 1;
  }
}
process.exit(failed === 0 ? 0 : 1);
