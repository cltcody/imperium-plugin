import { test } from 'node:test';
import assert from 'node:assert/strict';
import { classify, ciStatus, parseArgs } from '../pr-digest.mjs';

function pr(overrides = {}) {
  return {
    mergeable: 'MERGEABLE',
    reviewDecision: '',
    statusCheckRollup: [],
    ...overrides,
  };
}

function check(overrides = {}) {
  return { status: 'COMPLETED', conclusion: 'SUCCESS', ...overrides };
}

test('ciStatus: no checks configured -> none', () => {
  assert.equal(ciStatus(pr({ statusCheckRollup: [] })), 'none');
});

test('ciStatus: any failing/cancelled check -> failing', () => {
  assert.equal(
    ciStatus(pr({ statusCheckRollup: [check(), check({ conclusion: 'FAILURE' })] })),
    'failing',
  );
  assert.equal(
    ciStatus(pr({ statusCheckRollup: [check({ conclusion: 'CANCELLED' })] })),
    'failing',
  );
});

test('ciStatus: any in-progress/queued (and none failing) -> pending', () => {
  assert.equal(
    ciStatus(
      pr({ statusCheckRollup: [check(), check({ status: 'IN_PROGRESS', conclusion: '' })] }),
    ),
    'pending',
  );
});

test('ciStatus: all succeeded -> passing', () => {
  assert.equal(ciStatus(pr({ statusCheckRollup: [check(), check()] })), 'passing');
});

test('classify: merge conflict wins over everything else (blocked)', () => {
  const result = classify(
    pr({ mergeable: 'CONFLICTING', statusCheckRollup: [check()], reviewDecision: 'APPROVED' }),
  );
  assert.equal(result.bucket, 'blocked');
  assert.match(result.reason, /conflict/);
});

test('classify: changes requested -> blocked, even with green CI', () => {
  const result = classify(
    pr({ reviewDecision: 'CHANGES_REQUESTED', statusCheckRollup: [check()] }),
  );
  assert.equal(result.bucket, 'blocked');
});

test('classify: failing CI -> blocked', () => {
  const result = classify(pr({ statusCheckRollup: [check({ conclusion: 'FAILURE' })] }));
  assert.equal(result.bucket, 'blocked');
  assert.match(result.reason, /CI failing/);
});

test('classify: CI still running -> inflight, not blocked', () => {
  const result = classify(
    pr({ statusCheckRollup: [check({ status: 'IN_PROGRESS', conclusion: '' })] }),
  );
  assert.equal(result.bucket, 'inflight');
});

test('classify: awaiting review with green CI -> inflight', () => {
  const result = classify(pr({ reviewDecision: 'REVIEW_REQUIRED', statusCheckRollup: [check()] }));
  assert.equal(result.bucket, 'inflight');
});

test('classify: all green, no blocking review state -> ready', () => {
  const result = classify(pr({ statusCheckRollup: [check(), check()] }));
  assert.equal(result.bucket, 'ready');
});

test('classify always returns a bucket for any combination of inputs', () => {
  const combos = [
    pr({ statusCheckRollup: [] }),
    pr({ reviewDecision: 'APPROVED', statusCheckRollup: [check()] }),
    pr({ mergeable: 'UNKNOWN', statusCheckRollup: [check()] }),
  ];
  for (const c of combos) {
    const result = classify(c);
    assert.ok(['blocked', 'ready', 'inflight'].includes(result.bucket));
  }
});

test('parseArgs: no --repo -> defaults to cwd', () => {
  const { repos, asJson, outPath } = parseArgs([]);
  assert.deepEqual(repos, [process.cwd()]);
  assert.equal(asJson, false);
  assert.equal(outPath, null);
});

test('parseArgs: multiple --repo flags accumulate, resolved to absolute paths', () => {
  const { repos } = parseArgs(['--repo', '.', '--repo', '..']);
  assert.equal(repos.length, 2);
  assert.ok(repos.every((r) => r.startsWith('/')));
});

test('parseArgs: --json and --out are parsed', () => {
  const { asJson, outPath } = parseArgs(['--json', '--out', '/tmp/x.md']);
  assert.equal(asJson, true);
  assert.equal(outPath, '/tmp/x.md');
});
