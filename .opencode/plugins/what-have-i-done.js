/**
 * What Have I Done plugin for OpenCode.
 *
 * Two jobs:
 *   1. Register this package's skills directory so OpenCode discovers the
 *      skills without symlinks.
 *   2. Inject the `using-what-have-i-done` bootstrap into the first user message
 *      of each session, so the completion gate actually fires. Without this the
 *      skills sit on disk and are never invoked.
 */
import path from 'path';
import fs from 'fs';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const packageRoot = path.resolve(__dirname, '../..');
const skillsDir = path.resolve(packageRoot, 'skills');
const bootstrapPath = path.resolve(skillsDir, 'using-what-have-i-done', 'SKILL.md');

// The transform below runs on every agent step, so the bootstrap is read once
// and cached. undefined = not loaded yet, null = file missing.
let _bootstrapCache;

// Keep this in sync with skills/using-what-have-i-done/references/opencode-tools.md
// and .opencode/INSTALL.md.
const TOOL_MAPPING = `## OpenCode tool mapping
Skills name actions, not tools. On OpenCode:
- Read a file -> \`read\`
- Create, edit, or delete a file -> \`apply_patch\`
- Run a shell command -> \`bash\`
- Search file contents / find files by name -> \`grep\`, \`glob\`
- Fetch a URL -> \`webfetch\`
- Invoke a skill -> OpenCode's native \`skill\` tool
- Dispatch a subagent (\`Subagent (general-purpose):\` template) -> \`task\` with \`subagent_type: "general"\`
- Create or update todos -> \`todowrite\``;

const stripFrontmatter = (text) =>
  text.startsWith('---') ? text.replace(/^---\n[\s\S]*?\n---\n/, '') : text;

const getBootstrapContent = () => {
  if (_bootstrapCache !== undefined) return _bootstrapCache;
  let body;
  try {
    body = stripFrontmatter(fs.readFileSync(bootstrapPath, 'utf8')).trim();
  } catch {
    _bootstrapCache = null;
    return null;
  }
  _bootstrapCache = `<EXTREMELY_IMPORTANT>
You have the what-have-i-done completion-integrity skills. The
using-what-have-i-done bootstrap below is ALREADY LOADED - do not use the skill
tool to load it again. Use the skill tool for every other skill.

${body}

${TOOL_MAPPING}
</EXTREMELY_IMPORTANT>`;
  return _bootstrapCache;
};

export const WhatHaveIDonePlugin = async () => {
  return {
    // Make OpenCode discover this package's skills without manual symlinks.
    config: async (config) => {
      config.skills = config.skills || {};
      config.skills.paths = config.skills.paths || [];
      if (!config.skills.paths.includes(skillsDir)) {
        config.skills.paths.push(skillsDir);
      }
    },
    // Inject the bootstrap into the first user message of each session. This
    // fires on every agent step, so the dedup guard below is load-bearing.
    'experimental.chat.messages.transform': async (_input, output) => {
      const bootstrap = getBootstrapContent();
      if (!bootstrap || !output.messages.length) return;
      const firstUser = output.messages.find((m) => m.info.role === 'user');
      if (!firstUser || !firstUser.parts.length) return;
      const alreadyInjected = firstUser.parts.some(
        (p) => p.type === 'text' && p.text.includes('<EXTREMELY_IMPORTANT>')
      );
      if (alreadyInjected) return;
      const ref = firstUser.parts[0];
      firstUser.parts.unshift({ ...ref, type: 'text', text: bootstrap });
    },
  };
};
