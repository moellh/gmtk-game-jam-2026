# Info for AI Agent

## Game Jam Rules

See rules at [Game Jam Website](https://itch.io/jam/gmtk-jam-2026).
Don't create art or audio: Generative AI for creating art & audio is disallowed by the rules and leads to disqualification.

## Git Repo

The Git repo uses the [Scoped Commits](https://scopedcommits.com/) commit naming convention.
It is not enforced though strongly advised to, especially when auto-committing via an AI agent.
Basically, the commit message consists of `scope: description`.
Do not use [Conventional Commits](https://www.conventionalcommits.org) which usually prefix a `feat`, `fix`, `chore`, ...

## Branch Publishing

When working on a checked-out branch other than `main`, commit and push cohesive progress regularly so collaborators and deployments can see the current state.
Do not push branches created only for temporary worktrees. Integrate their changes into the intended persistent branch and push that branch instead.

Persistent non-`main` branches should regularly fetch `origin` and rebase onto an updated `origin/main` so they remain close to the integration branch.
After rebasing a published branch, validate it and push with `--force-with-lease`.
This update rule does not apply to branches created only for temporary worktrees.

When a persistent working branch reaches a coherent, validated milestone, periodically integrate that state into `main` and push `main` so the integration branch does not lag indefinitely.
Fetch first, preserve collaborators' remote changes, and do not integrate an incomplete or failing state.

## itch.io Page Kit

During active development, refresh `itch-page/` no more than once per hour unless the user explicitly requests an earlier refresh.
When refreshing, keep its HTML description, screenshots, cover, credits, and setup notes aligned with the current game.
Use real game captures and existing assets only; the generative-art and generative-audio prohibition also applies to itch.io page assets.

## Code Maintenance

When touching an area, briefly review adjacent older code for superseded paths, duplication, or unnecessary complexity.
Simplify only when behavior can be preserved and validated.
Avoid unrelated broad refactors.

Prefer self-explanatory names and structure.
Add brief comments for non-obvious intent, constraints, or workarounds, but do not narrate straightforward code.

## Maintaining This File

Agents may add to or modify this file as needed, but must not alter or remove either existing rule above: the prohibition on generative AI for art and audio, and the scoped commit naming convention.
