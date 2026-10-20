---
name: vinted-seller
description: Use when the user wants to sell books on Vinted from a folder of photos — "sell these books", "list this folder on Vinted", "vinted-seller <folder>". Groups the photos into one folder per item with parallel sub-agents, prices each item from Vinted searches, builds the listing files, and publishes them after the user approves a recap.
---

# Vinted Seller

## Overview

Turns a folder of loose book photos into published Vinted listings. Sub-agents
identify the books and price them in parallel. Nothing is published until the
user approves the recap.

The argument is the folder of photos. If it is empty, `"this"`, `"."` or
`"here"`, use the current working directory. The folder is the **root** below.

## Core Workflow

### Step 1 — Batch the photos

**Goal:** Split the photos into overlapping batches, one per sub-agent.

**Exit criterion:** `batches.json` exists in a scratch directory.

Create a scratch directory with `mktemp -d`. Never write scratch files in the
root. Then run:

```sh
vinted-photo-batch <root> > <scratch>/batches.json
```

`jq length` gives the batch count. Stop with a message if it is `0`.

### Step 2 — Identify the items

**Goal:** Group the photos of each batch into items, and identify every item.

**Exit criterion:** `<scratch>/groups-<n>.json` exists for every batch.

Send **one message** with one `Agent` call per batch, so all batches run in
parallel. Use the `general-purpose` subagent. Read `references/photo-agent.md`
for the brief. Fill in the root, the batch's photo names, and the output path
`<scratch>/groups-<n>.json`.

An unreadable ISBN stays empty. A group the agent cannot identify is `unsure`.

If a file is missing or is not valid JSON (`jq empty`), re-run that batch's
sub-agent once. Stop and report if it fails again.

### Step 3 — Merge and organize

**Goal:** Put every item in its own folder, and every unsure item in `Misc/`.

**Exit criterion:** `<scratch>/merged.json` and `<scratch>/folders.json` exist.

```sh
jq -s '.' <scratch>/groups-*.json | vinted-photo-merge > <scratch>/merged.json
vinted-photo-organize <root> < <scratch>/merged.json > <scratch>/folders.json
```

Entry `i` of `folders.json` is the folder of entry `i` of `merged.json`. Keep
that pairing for the next steps. Skip the entries with `unsure: true`: they sit
in `Misc/`, and get no listing.

### Step 4 — Search prices

**Goal:** Collect the asking prices of similar books, by ISBN then by title.

**Exit criterion:** Search rows are saved for every listing.

For each item that is not unsure, in `<scratch>/<i>/`:

- If the ISBN is not empty: `vinted-price-search "<isbn>" > isbn.json`
- Always: `vinted-price-search "<series> <number> <publisher>" > title.json`.
  Leave out the empty parts.

Run the searches one after the other. Vinted blocks parallel requests.

### Step 5 — Filter prices

**Goal:** Keep only the rows that match the item.

**Exit criterion:** `<scratch>/<i>/kept.json` exists for every listing.

Send **one message** with one `Agent` call per listing, so all listings run in
parallel. Use the `general-purpose` subagent. Read `references/price-agent.md`
for the brief. Fill in the item's identification and the paths of its rows.

### Step 6 — Compute the price and build the listing

**Goal:** Write a `listing.json` in the folder of every item.

**Exit criterion:** Every listing folder holds a `listing.json`.

For each listing, read `basis` and `rows` from its `kept.json`:

```sh
jq '.rows' kept.json | vinted-listing-price --basis <basis>
vinted-listing-build <folder> --series "<series>" --number "<number>" \
  --publisher "<publisher>" --isbn "<isbn>" --price <price> [--uncertain]
```

- Pass `--uncertain` when `isUncertain` is `true`.
- `vinted-listing-price` fails on an empty `rows`. Then use `--price 2` with
  `--uncertain`, and tell the user which listings had no price.
- The category defaults to Books & Media > Books > Fiction. Pass `--category`
  for a comic, a manga or an RPG book. The Vinted UI is in English, so keep the
  labels in English.
- Skip `--isbn` when the ISBN is empty. The builder falls back to zeros.

### Step 7 — Recap and approval

**Goal:** Show what will be published, and get the user's approval.

**Exit criterion:** The user approved the recap in plain words.

Run `vinted-listing-recap <root>` and show the output. Add the number of items
in `Misc/`. Then stop and ask for approval. Do not publish on silence, on a
vague answer, or because an earlier run was approved.

If the user changes a price or a title, edit the `listing.json` and show the
recap again.

### Step 8 — Publish

**Goal:** Post every draft listing, and record the URLs.

**Exit criterion:** `vinted-listing-publish` finished, or the user was told
which listing failed.

For a first run on a new folder, try one listing first:

```sh
vinted-listing-create "<folder>/listing.json" --dry-run
```

Open the saved screenshot and check that the form matches the listing. If the
dry-run fails or the form is wrong, stop, report the error, and do not publish.
Then run `vinted-listing-publish <root>`. The first failure stops the batch.
Re-running is safe: published listings are skipped. If it fails because the
session expired, ask the user to run `vinted-login`, then re-run.

## Common Rationalizations

| Rationalization                                     | Reality                                                                    |
| --------------------------------------------------- | -------------------------------------------------------------------------- |
| "The recap looks fine, I'll publish to save a turn" | Publishing is public and slow to undo. Wait for the user's approval.       |
| "One sub-agent can handle every batch in a loop"    | Batches are independent. Send them in one message so they run in parallel. |
| "I'm fairly sure about this unclear book"           | Mark it `unsure`. It goes to `Misc/` and the user decides.                 |
| "I'll guess the ISBN from memory"                   | A wrong ISBN is worse than none. Leave it empty and let it fall to zeros.  |
| "I'll run the price searches in parallel too"       | Vinted blocks bursts of searches. Run them one after the other.            |
| "I'll put the scratch files next to the photos"     | The root holds listings only. Use the `mktemp -d` scratch directory.       |

## Checklist

- [ ] Photos batched, `batches.json` has at least one batch
- [ ] One photo sub-agent per batch, sent in a single message
- [ ] Every `groups-<n>.json` is valid JSON
- [ ] Unsure items sit in `Misc/` and have no `listing.json`
- [ ] One price sub-agent per listing, sent in a single message
- [ ] Every non-unsure folder holds a `listing.json`
- [ ] Recap shown, uncertain prices visible
- [ ] User approved the recap before `vinted-listing-publish` ran
