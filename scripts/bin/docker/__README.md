# Docker scripts

## Images

### `docker-image-list` 

Lists all local images, in a pretty way. It displays the name, tag, hash, last
update, size and potential comment.

By passing an argument, we can filter on specific images, like
`docker-image-list ubuntu`.

Completion suggests all local images.

### `docker-image-pull`

Without arguments, it allows searching into the list of official docker images
to pull them. With arguments, it pulls the specific images.

Completion suggests all official images.

### `docker-image-build`

Build a new image from the local `Dockerfile` with the specified name (default
to name of the repository)

### `docker-image-remove`

Deletes local images. `docker-image-remove ubuntu alpine` will remove all
`docker` and `alpine` images.

If the image are not present, it will skip them. If there are several tags for
a given image, it will display the potential candidates and skip the deletion.

### `docker-image-exists`

Checks if a given image exists locally. Exits with 1 if not available, and 0 if
available.

Can be checked with image name (`docker-image-exists ubuntu`) or with a specific
tag (`docker-image-exists ubuntu:latest`).

### `docker-image-copy`

Copy an image under a new name.

### `docker-image-count`

Returns the count of how many images of a specific name we have (all tags). For
example if we have both `ubuntu:latest` and `ubuntu:20.04`, `docker-image-count
ubuntu` will output `2`.

### `docker-image-description`

Outputs the description of an official image. This is an internal function,
reading a cache file we are using to build the list of official images.

### `docker-image-name` and `docker-image-id`

Outputs the name of an image from its id, or the id from its name.

## Containers

### `docker-container-list`

Lists all local containers in a pretty way. It display their name and state
with color and icons. Also their base image and tag, hash and last status.

### `docker-container-remove`

Removes existing containers, specified by their names.

### `docker-container-exists`

Check if a given container exists. Exits with 1 if no, and with 0 if it exists.

### `docker-container-count`

Outputs the number of container based on a specific image we locally have. If no
tag is passed, it assumes `:latest`.

### `docker-container-is-running`

Check if the specified container is currently running or not.

### `docker-container-state`

Returns the specified container state. It exists with 1 if the container does
not exist. Possible values are `running`, `stopped`, etc

### `docker-container-name` and `docker-container-id`

Outputs the name of a container from its id, or the id from its name.

### `docker-container-image-name` and `docker-container-image-id`

Outputs the image name, or image id, of a given container

## Run

### `docker-run`

Run a specific image in a container. Acts as a clever wrapper around `docker
run`. Any flag passed to it will be passed to `docker run`. The container is
automatically discarded after the run.

Automatically picks a container name if no `--name` is passed. The default
name is `image_tag` (so `ubuntu:latest` runs as `ubuntu_latest`). If this name
is already taken, a random readable string is prepended.

### `docker-run-interactive`

Same as `docker-run`, but runs the image interactively.

