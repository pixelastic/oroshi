## What to build

Read the Node version from the workspace's `.nvmrc` at invocation time and use
it to select (or build) the correct image. If no `.nvmrc` is found, fall back
to `lts`.

The image tag becomes `claude-sandbox:claude{CLAUDE_VERSION}-node{NODE_VERSION}`
— for example `claude-sandbox:claude1.2.3-node18` or
`claude-sandbox:claude1.2.3-nodelts`.

Each Claude+Node combination is a distinct image. Upgrading Claude produces a
new image without invalidating existing Node-versioned images.

The `--build` flag (from issue-05) also respects the workspace's `.nvmrc` when
`--workspace` is provided, so the correct Node version is baked into the
rebuilt image.

## Acceptance criteria

- [ ] Bats test written and failing before implementation begins
- [ ] A workspace with `.nvmrc: 18` causes the image `claude-sandbox:claudeX.Y.Z-node18` to be used
- [ ] A workspace without `.nvmrc` uses `claude-sandbox:claudeX.Y.Z-nodelts`
- [ ] `node --version` inside the container matches the `.nvmrc` value
- [ ] Two workspaces with different `.nvmrc` values produce two distinct cached images
- [ ] Bats test passes

## Blocked by

- issue-05-image-build
