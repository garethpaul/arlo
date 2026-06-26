# Arlo Setup Guide Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use executing-plans to implement this plan task-by-task.

**Goal:** Replace Arlo's generated setup notes with source-backed empty-token setup, workspace, verification, and configured-mode boundaries without changing legacy application behavior.

**Architecture:** Preserve the Swift 3/iOS 9.3 application, vendored pods, project settings, and device matrix. Add fail-closed documentation contracts for prerequisites, CocoaPods workspace usage, the checked-in empty-token behavior, SDK-free gates, hosted coverage, and the explicit configured-token blocker; then retire only the completed README roadmap item.

**Tech Stack:** Markdown, POSIX shell contracts, GNU Make, Swift 3 source evidence, CocoaPods workspace metadata, GitHub Actions

---

## Status: Completed

### Task 1: Add The Documentation Contract

**Files:**
- Modify: `scripts/check-baseline.sh`
- Test: `scripts/check-baseline.sh`

**Step 1: Write the failing test**

Require distinct supported-baseline, setup, empty-token, configured-mode, and verification guidance, plus roadmap and change-history evidence.

**Step 2: Run test to verify it fails**

Run: `scripts/check-baseline.sh`

Expected: FAIL because the generated README does not yet contain the required setup boundary.

### Task 2: Write The Setup Guide

**Files:**
- Modify: `README.md`
- Modify: `VISION.md`
- Modify: `CHANGES.md`

**Step 1: Write minimal documentation**

Document the legacy toolchain evidence, `pod install`, workspace-only opening, the safe checked-in empty-token mode, the absence of a committed local token mechanism, canonical SDK-free commands, hosted coverage, and exact-commit device verification.

**Step 2: Run focused contracts**

Run: `scripts/check-baseline.sh`

Expected: PASS.

### Task 3: Prove Drift Fails Closed

**Files:**
- Test: `scripts/check-baseline.sh`

**Step 1: Apply hostile mutations**

Mutate the setup headings, workspace command, legacy versions, empty-token behavior, configured-mode blocker, canonical Make command, hosted coverage, device matrix, roadmap history, change history, and plan status.

**Step 2: Verify each mutation fails**

Run: `scripts/check-baseline.sh` after each mutation.

Expected: every mutation is rejected.

### Task 4: Run The Full Gate

**Files:**
- Verify: `Makefile`

**Step 1: Run repository and external gates**

Run: `/usr/bin/make check`

Run: `cd "$(mktemp -d)" && /usr/bin/make -f /absolute/path/to/Makefile check`

Expected: SDK-free source, policy, mutation, workflow, documentation, and Make authority gates pass from both invocation locations.

### Task 5: Commit And Ship

**Files:**
- Modify: `CHANGES.md`
- Modify: `docs/plans/2026-06-26-arlo-setup-guide.md`

**Step 1: Record exact validation**

Add final mutation, gate, hosted-check, review, and blocker evidence.

**Step 2: Commit**

```bash
git add README.md VISION.md CHANGES.md scripts/check-baseline.sh docs/plans/2026-06-26-arlo-setup-guide.md
git commit -m "docs: document Arlo setup boundaries"
```

## Results

- Replaced generated project inventory and ambiguous launch guidance with a
  source-backed legacy baseline, CocoaPods workspace setup, and verification
  guide.
- Documented the safe checked-in empty-token behavior and explicitly left
  configured voice mode blocked until an ignored local settings path exists.
- Rejected 19 hostile documentation mutations covering the toolchain,
  workspace, dependencies, token modes, verification layers, roadmap, history,
  and plan completion.
- Passed `/usr/bin/make check` from the checkout and an external working
  directory. The Linux host ran portable source, lifecycle, mutation, workflow,
  documentation, and Make authority gates; macOS Foundation and Xcode steps
  reported their documented platform skips.
