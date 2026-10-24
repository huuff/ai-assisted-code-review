---
name: ai-assisted-code-review
description: Review a PR together with the user: they read and judge the code, the agent investigates on demand and applies small fixes directly on the branch.
disable-model-invocation: true
---

# AI-assisted code review

The user is the reviewer. The agent is the investigator and the hands: it answers questions
about the diff with evidence, and applies minor fixes on the branch so the author never has to
be asked for them.

## Orient phase

Runs once when the skill is invoked, before the user asks anything. Its output is a short
summary of the main things to watch out for in this PR: what changed and why, the compatibility
and deployment sweep below, and anything that looks risky at a glance. Short means the user can
read it before opening the diff.

1. `git diff master...HEAD --stat` and `git log master..HEAD --oneline`: what changed and how it was staged.
2. Read the PR description / linked issue if reachable (`gh` may be sandboxed; then rely on commit messages).
3. Run the compatibility and deployment sweep.
4. Start a running ledger for the wrap-up: findings the user raised, answers given, fixes applied,
   a **todo list** for things noticed but deferred because something else was in progress, and
   **future steps and notes to the author**: tips the user wants passed on without acting on them
   in this review (typically a final review where the user changes things and merges).

## Compatibility and deployment sweep

Done in the orient phase and redone after every change made on the branch. Complete when every
item below has an explicit answer, including "none".

- **DTOs / wire contracts**: every changed type that crosses a process boundary (HTTP DTOs, AMQP
  messages, shared-crate models, Helm values, env vars). For each: backwards compatible or not,
  and in which direction (old producer → new consumer, new producer → old consumer).
- **Database**: new or changed migrations, the tables and columns they touch, whether they are
  reversible, whether they lock or rewrite large tables, and whether the old binary can still run
  against the migrated schema (rollback safety).
- **Redeployments**: every deployable crate that must ship, with the reason: directly changed,
  compiles in a changed shared crate, or must move in lockstep with a contract change. Include
  deploy order when a contract is not backwards compatible.
- **Config and secrets**: new env vars, chart values, sops secrets that must exist before the
  deploy.

## Answering a question about the diff

The user asks things like "what does this PR use X for?", "why was Y removed?", "is Z still called?".

- Answer with the exact consumer(s) as `file:line`, and what the thing is for. Scope is what the user asked: no padding with unaffected code.
- Say whether the code is **new**, **moved**, or **changed** relative to master. Moved code is the common case in refactor PRs and needs no re-review of its internals.
- Verify by reading the code, never by inferring from names. Grep the diff first, then follow consumers outside the diff.
- Lead with the one-sentence answer, then the evidence.

## Making changes

Minor changes (naming, a missed import, a doc line, a dead branch, convention fixes) are made directly on the PR branch instead of being handed back to the author. Everything else is reported to the user as a finding and they decide.

- Load the `rust` / `nice-code` / `testing` / `hexarch` skills as the change requires.
- Run the targeted check after the change (`cargo clippy -p <crate> --all-features --all-targets -- -D warnings`, the affected tests).
- Record every applied fix in the ledger as a note written for the author, in the words you would
  use in a PR comment: the **big picture** in one or two sentences (the decision and the reason
  behind it), caveats the author must know (workarounds, trade-offs
  accepted), follow-up work if any, and the commit hash once it is committed. The mechanics that
  follow from the decision (renames, moved tests, rewired call sites) are visible in the diff and
  stay out of the note. The wrap-up turns these notes into a message the user can send as-is, so
  the author learns what changed without a request-for-changes round-trip.
- Mechanical changes (renames, a derive replacing a hand-written impl, moving a type, import
  fixes) are committed straight away once the checks pass, one commit per change. Anything that
  changes behaviour or design waits for the user's explicit "commit"; before that commit, re-read
  the ledger note for the change and ask whether the rationale and author note still hold, since
  the approach often moves between dictation and commit and the note goes to the author verbatim.
- When reporting a commit, give its hash and the lines added versus removed
  (`git show --shortstat`).
- **Housekeeping** stays out of the author message: merging master into the branch, and the
  minimal fixes the branch needs to stay green after it (a stale snapshot, an import, the
  lockfile). Commit it, list it in the ledger under housekeeping so the wrap-up skips it, and
  move on. The author message covers changes to the author's work only.

## Todo list

When something comes up mid-change that is worth fixing but not now (a type in the wrong place, a
name, a missing test), add it to the ledger's todo list as the problem only: file and a one-line
reason, no solution. The solution is the user's call when the item is picked up; a suggestion made
in chat is not a decision. Carry on with the current change. Before the wrap-up, go through the
list with the user; whatever stays open goes to the author as a finding.

## Wrap-up

Only after the todo list has been worked through. Then produce one thing: a message for the
author, ready to send, with every change made on their branch (from the ledger notes), the open
code findings left from the todo list, and the future steps and notes section: follow-up tasks,
refactors and projects that grow out of this PR, plus the tips collected during the review.
Compatibility and deployment caveats are the reviewer's, delivered in the orient summary; they
do not go to the author.

## Editing this skill

Read `RATIONALE.md` first; it records why the skill is structured this way. It is written by the user and is not edited without their approval.
