---
title: "Docker Ignore File"
---

The .dockerignore file contains a list of patterns that tell Docker which files and directories to exclude from the build context. For a more in-depth explanation of the file's functionality and pattern syntax, see the official [.dockerignore file documentation](https://docs.docker.com/engine/reference/builder/#/dockerignore-file).

As a Convox user, you'll want to keep a few key points in mind when dealing with the .dockerignore file.

1. The .dockerignore file controls what makes it into your build. It is common to exclude large and sensitive files.
1. Don't put docker-compose.yml in .dockerignore. Your app can't be configured correctly without it in the build.
1. The [code sync feature](https://convox.com/docs/code-sync) of `convox start` will not sync files and directories listed in .dockerignore.

Note: the way Convox handles .dockerignore for the purposes of code sync is a bit different from how Docker Compose does it. Instead of looking for a `.dockerignore` file at the project root, Convox recursively checks the directory referenced by each `ADD` or `COPY` directive and its subdirectories. If the project root directory contains a `.dockerignore` but has not been `ADD`ed in the `Dockerfile`, that `.dockerignore` will be ignored.
