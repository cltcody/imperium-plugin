#!/usr/bin/env node
// PR/branch digest — the "which of my branches needs me right now" board.
// Sweeps OPEN PRs (gh CLI) across one or more repos, plus local branches with
// no PR yet, classifies each into a bucket, and writes a scannable digest.
//
// General-purpose (imperium plugin script) — not tied to any one project.
// Works on whichever repo(s) you point it at; defaults to the current
// working directory when run with no --repo flags.
//
// Deliberately does NOT try to read Claude Code session state — sessions are
// ephemeral and the harness doesn't expose that to a standalone script. PRs
// and branches are the durable proxy: in a typical branch-per-session
// workflow, "which PRs need me" answers "which sessions need me" closely
// enough to be useful without inventing a second source of truth.
//
//   node pr-digest.mjs                          # sweep the current directory's repo
//   node pr-digest.mjs --repo ~/code/app-a --repo ~/code/app-b   # sweep multiple repos
//   node pr-digest.mjs --json                   # machine-readable (for a scheduled routine)
//   node pr-digest.mjs --out ~/digest.md         # write the rendered digest to a specific path
//
// Buckets:
//   🔴 Needs you now   — CI failed, changes requested, or a merge conflict
//   🟢 Ready to merge  — all checks green, no blocking review state
//   🟡 In flight       — CI still running, or awaiting someone else's review
//   ⚪ No PR yet        — local branch with commits ahead of main, nothing opened
//   🧹 Safe to delete  — local branch whose PR already merged/closed
//
// Auth: uses GH_TOKEN/GITHUB_TOKEN if set, else falls back to `gh auth token`.
// Requires the GitHub CLI installed and authenticated.

import { execSync } from 'node:child_process';
import { mkdirSync, writeFileSync } from 'node:fs';
import { dirname, basename, resolve, join } from 'node:path';
import { homedir } from 'node:os';
import { fileURLToPath } from 'node:url';

function sh(cmd, cwd) {
  return execSync(cmd, { encoding: 'utf8', cwd }).trim();
}

function ghToken() {
  if (process.env.GH_TOKEN) return process.env.GH_TOKEN;
  if (process.env.GITHUB_TOKEN) return process.env.GITHUB_TOKEN;
  try {
    return sh('gh auth token');
  } catch {
    throw new Error(
      'No GitHub token. Set GH_TOKEN, or authenticate the GitHub CLI with `gh auth login`.',
    );
  }
}

function currentUser() {
  const raw = sh(`gh api user --header "Authorization: token ${ghToken()}"`);
  return JSON.parse(raw).login;
}

function fetchOpenPRs(author, repoPath) {
  const fields =
    'number,title,headRefName,createdAt,updatedAt,isDraft,reviewDecision,statusCheckRollup,mergeable,url';
  const raw = sh(`gh pr list --author ${author} --state open --json ${fields}`, repoPath);
  return JSON.parse(raw);
}

/** headRefName -> most-recent PR state, across ALL states (open/closed/merged). */
function fetchAllPrHeadStates(author, repoPath) {
  const raw = sh(
    `gh pr list --author ${author} --state all --json headRefName,state --limit 500`,
    repoPath,
  );
  const map = new Map();
  for (const pr of JSON.parse(raw)) map.set(pr.headRefName, pr.state);
  return map;
}

/** Roll up a PR's check runs into a single status: 'failing' | 'pending' | 'passing' | 'none'. */
function ciStatus(pr) {
  const checks = pr.statusCheckRollup ?? [];
  if (checks.length === 0) return 'none';
  if (checks.some((c) => c.conclusion === 'FAILURE' || c.conclusion === 'CANCELLED'))
    return 'failing';
  if (checks.some((c) => c.status === 'IN_PROGRESS' || c.status === 'QUEUED')) return 'pending';
  if (checks.every((c) => c.conclusion === 'SUCCESS')) return 'passing';
  return 'pending';
}

function classify(pr) {
  const ci = ciStatus(pr);
  if (pr.mergeable === 'CONFLICTING') return { bucket: 'blocked', reason: 'merge conflict' };
  if (pr.reviewDecision === 'CHANGES_REQUESTED')
    return { bucket: 'blocked', reason: 'changes requested' };
  if (ci === 'failing') return { bucket: 'blocked', reason: 'CI failing' };
  if (ci === 'pending') return { bucket: 'inflight', reason: 'CI running' };
  if (pr.reviewDecision === 'REVIEW_REQUIRED')
    return { bucket: 'inflight', reason: 'awaiting review' };
  if (ci === 'passing') return { bucket: 'ready', reason: 'all checks green' };
  return { bucket: 'inflight', reason: 'no checks configured' };
}

function fetchDanglingBranches(mainBranch, allPrHeadStates, repoPath) {
  // Local branches with commits ahead of main and NO PR in any state
  // (open/closed/merged) — work that exists but was never surfaced.
  //
  // Deliberately does NOT rely on `git rev-list`/merge-base ancestry to
  // detect "already merged": a squash-merge (the common convention on most
  // repos, incl. GitHub's default suggestion) creates a brand-new commit on
  // main, so the original branch's commits are never ancestors of main even
  // though the work landed. Checking GitHub's PR history (any state) per
  // branch instead — a branch with a MERGED or CLOSED PR is
  // stale-but-safe-to-delete, not "no PR yet."
  try {
    const raw = sh(`git for-each-ref --format='%(refname:short)' refs/heads/`, repoPath);
    const branches = raw.split('\n').filter((b) => b && b !== mainBranch);
    const dangling = [];
    const staleMerged = [];
    for (const b of branches) {
      const prState = allPrHeadStates.get(b);
      if (prState === 'MERGED' || prState === 'CLOSED') {
        staleMerged.push({ branch: b, prState });
        continue;
      }
      if (prState === 'OPEN') continue; // already covered by the main PR buckets
      try {
        const ahead = sh(`git rev-list --count ${mainBranch}..${b}`, repoPath);
        if (Number(ahead) > 0) dangling.push({ branch: b, ahead: Number(ahead) });
      } catch {
        // branch may not have a common ancestor locally fetched — skip
      }
    }
    return { dangling, staleMerged };
  } catch {
    return { dangling: [], staleMerged: [] };
  }
}

function ageDays(iso) {
  return Math.floor((Date.now() - new Date(iso).getTime()) / 86_400_000);
}

/** Sweep a single repo: open PRs (classified) + dangling/stale-merged local branches. */
function sweepRepo(repoPath, user) {
  const prs = fetchOpenPRs(user, repoPath);
  const classified = prs.map((pr) => ({ ...pr, ...classify(pr), repo: basename(repoPath) }));

  const mainBranch = (() => {
    try {
      return sh('git symbolic-ref refs/remotes/origin/HEAD', repoPath).replace(
        'refs/remotes/origin/',
        '',
      );
    } catch {
      return 'main';
    }
  })();
  const allPrHeadStates = fetchAllPrHeadStates(user, repoPath);
  const { dangling, staleMerged } = fetchDanglingBranches(mainBranch, allPrHeadStates, repoPath);

  return {
    repo: basename(repoPath),
    repoPath,
    classified,
    dangling: dangling.map((d) => ({ ...d, repo: basename(repoPath), mainBranch })),
    staleMerged: staleMerged.map((d) => ({ ...d, repo: basename(repoPath) })),
  };
}

function parseArgs(argv) {
  const repos = [];
  let asJson = false;
  let outPath = null;
  for (let i = 0; i < argv.length; i++) {
    if (argv[i] === '--repo') repos.push(resolve(argv[++i]));
    else if (argv[i] === '--json') asJson = true;
    else if (argv[i] === '--out') outPath = argv[++i];
  }
  if (repos.length === 0) repos.push(process.cwd());
  return { repos, asJson, outPath };
}

function main() {
  const { repos, asJson, outPath } = parseArgs(process.argv.slice(2));
  const user = currentUser();
  const sweeps = repos.map((r) => sweepRepo(r, user));
  const multiRepo = sweeps.length > 1;

  const allClassified = sweeps.flatMap((s) => s.classified);
  const allDangling = sweeps.flatMap((s) => s.dangling);
  const allStaleMerged = sweeps.flatMap((s) => s.staleMerged);

  const buckets = {
    blocked: allClassified.filter((p) => p.bucket === 'blocked'),
    ready: allClassified.filter((p) => p.bucket === 'ready'),
    inflight: allClassified.filter((p) => p.bucket === 'inflight'),
  };

  if (asJson) {
    console.log(
      JSON.stringify(
        { user, repos: repos.map((r) => basename(r)), buckets, dangling: allDangling, staleMerged: allStaleMerged },
        null,
        2,
      ),
    );
    return;
  }

  const lines = [];
  lines.push(`# PR Digest — ${user}`);
  lines.push('');
  lines.push(
    `> ${allClassified.length} open PR(s) across ${repos.length} repo(s) · generated ${new Date().toISOString()}`,
  );
  lines.push('');

  const label = (item) => (multiRepo ? `[${item.repo}] ` : '');

  const section = (title, items, renderer) => {
    lines.push(`## ${title} (${items.length})`);
    lines.push('');
    if (items.length === 0) {
      lines.push('_none_');
    } else {
      for (const item of items) lines.push(renderer(item));
    }
    lines.push('');
  };

  section(
    '🔴 Needs you now',
    buckets.blocked,
    (p) =>
      `- ${label(p)}[#${p.number}](${p.url}) ${p.title} — **${p.reason}**, opened ${ageDays(p.createdAt)}d ago`,
  );
  section(
    '🟢 Ready to merge',
    buckets.ready,
    (p) => `- ${label(p)}[#${p.number}](${p.url}) ${p.title} — all checks green`,
  );
  section(
    '🟡 In flight',
    buckets.inflight,
    (p) => `- ${label(p)}[#${p.number}](${p.url}) ${p.title} — ${p.reason}`,
  );
  section(
    '⚪ No PR yet',
    allDangling,
    (d) => `- ${label(d)}\`${d.branch}\` — ${d.ahead} commit(s) ahead of ${d.mainBranch}, no PR opened`,
  );
  if (allStaleMerged.length > 0) {
    section(
      '🧹 Local branches safe to delete',
      allStaleMerged,
      (d) =>
        `- ${label(d)}\`${d.branch}\` — PR ${d.prState.toLowerCase()}, local copy just needs \`git branch -D ${d.branch}\``,
    );
  }

  const rendered = lines.join('\n');
  console.log(rendered);

  const finalOutPath = outPath
    ? resolve(outPath)
    : join(homedir(), '.claude', 'imperium', 'digests', 'pr-digest.md');
  mkdirSync(dirname(finalOutPath), { recursive: true });
  writeFileSync(finalOutPath, rendered.trimEnd() + '\n', 'utf8');
  console.error(`\nWritten → ${finalOutPath}`);
}

if (process.argv[1] && fileURLToPath(import.meta.url) === process.argv[1]) {
  try {
    main();
  } catch (err) {
    console.error(`pr-digest failed: ${err.message}`);
    process.exit(1);
  }
}

export { classify, ciStatus, parseArgs };
