import { readFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

// Pi has no `Skill` tool, so the bootstrap says so explicitly rather than
// telling the model to "use the skill tool".
const BOOTSTRAP_MARKER = "what-have-i-done bootstrap for pi";

const extensionDir = dirname(fileURLToPath(import.meta.url));
const packageRoot = resolve(extensionDir, "../..");
const skillsDir = resolve(packageRoot, "skills");
const bootstrapPath = resolve(skillsDir, "using-what-have-i-done", "SKILL.md");

let cachedBootstrap: string | null | undefined;

export default function whatHaveIDonePiExtension(pi: ExtensionAPI) {
  let injectBootstrap = true;

  // Make Pi discover this package's skills.
  pi.on("resources_discover", async () => ({ skillPaths: [skillsDir] }));

  // Re-inject on session start and after compaction; stand down between turns.
  pi.on("session_start", async () => { injectBootstrap = true; });
  pi.on("session_compact", async () => { injectBootstrap = true; });
  pi.on("agent_end", async () => { injectBootstrap = false; });

  pi.on("context", async (event) => {
    if (!injectBootstrap) return;
    if (event.messages.some(messageContainsBootstrap)) return;
    const bootstrap = getBootstrapContent();
    if (!bootstrap) return;
    const bootstrapMessage = {
      role: "user" as const,
      content: [{ type: "text" as const, text: bootstrap }],
      timestamp: Date.now(),
    };
    const insertAt = firstNonCompactionSummaryIndex(event.messages);
    return {
      messages: [
        ...event.messages.slice(0, insertAt),
        bootstrapMessage,
        ...event.messages.slice(insertAt),
      ],
    };
  });
}

function stripFrontmatter(text: string): string {
  return text.startsWith("---") ? text.replace(/^---\n[\s\S]*?\n---\n/, "") : text;
}

function getBootstrapContent(): string | null {
  if (cachedBootstrap !== undefined) return cachedBootstrap;
  try {
    const body = stripFrontmatter(readFileSync(bootstrapPath, "utf8")).trim();
    cachedBootstrap = `<EXTREMELY_IMPORTANT>
${BOOTSTRAP_MARKER}
You have the what-have-i-done completion-integrity skills. The bootstrap below
is already loaded; do not try to load using-what-have-i-done again.

${body}

${piToolMapping()}
</EXTREMELY_IMPORTANT>`;
    return cachedBootstrap;
  } catch {
    cachedBootstrap = null;
    return null;
  }
}

// Keep this in sync with
// skills/using-what-have-i-done/references/pi-tools.md.
function piToolMapping(): string {
  return `## Pi tool mapping
Pi discovers skills natively but exposes no tool to load one. Here, reading a
skill's \`SKILL.md\` with \`read\` IS the sanctioned way to load it - not a
workaround. When the bootstrap says to invoke what-have-i-done, read
\`skills/what-have-i-done/SKILL.md\` and follow it.

Pi's tools are lowercase: \`read\`, \`write\`, \`edit\`, \`bash\`, plus optional
\`grep\`, \`find\`, \`ls\`. For the adversarial-self-review step, use an installed
subagent tool if one is available; otherwise switch hats and review in-session as
that skill describes, and say so in your report. Never fabricate a dispatch call.
Track the evidence ledger in an installed todo tool or a repo-local file.`;
}

function messageContainsBootstrap(message: unknown): boolean {
  const content = (message as { content?: unknown }).content;
  if (typeof content === "string") return content.includes(BOOTSTRAP_MARKER);
  if (!Array.isArray(content)) return false;
  return content.some(
    (part) =>
      part &&
      typeof part === "object" &&
      (part as { type?: unknown }).type === "text" &&
      typeof (part as { text?: unknown }).text === "string" &&
      (part as { text: string }).text.includes(BOOTSTRAP_MARKER)
  );
}

function firstNonCompactionSummaryIndex(messages: unknown[]): number {
  let index = 0;
  while ((messages[index] as { role?: unknown } | undefined)?.role === "compactionSummary") {
    index += 1;
  }
  return index;
}
