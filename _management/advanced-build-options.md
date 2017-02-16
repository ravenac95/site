---
title: "Advanced Build Options"
order: 500
---

By default, `convox build` processes run in a Rack just like other application processes. This is designed to handle a normal number of builds at a minimal cost. Builds use spare capacity on a Rack instance, and will autoscale the Rack up and then back down if any addition build capacity is needed.

Convox offers advanced options that can improve the speed, throughput and security of builds.

### Build Artifact Caching

App language dependency management tools like [Ruby's Bundler](http://bundler.io/) and [Python PIP](https://pypi.python.org/pypi/pip) take care to reuse packages that have already been built and installed.

Docker builds, however, are stateless and implement their own [image caching](https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/#/build-cache) which ends up having to rebuild all dependencies on any `Gemfile` change.

Convox offers a convention to get the optimal dependency management behavior.

After a `convox build`, any files in `/var/cache/build` are extracted and saved to an archive in S3. At the beginning of the next `convox build`, this archive is downloaded and extracted to a `.cache/` directory in the app source code.

You can then instruct Docker to use the artifacts from the last build and update them for the next build by:

```Dockerfile
COPY Gemfile      /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
COPY .cache/build/gems /var/cache/build/gems
RUN bundle install --path /var/cache/build/gems
```

This convention is also usable with Buildpacks:

```Dockerfile
RUN cd /tmp && git clone https://github.com/heroku/heroku-buildpack-ruby
COPY . /app
COPY .cache/build/gems /var/cache/build/gems
RUN /tmp/heroku-buildpack-ruby/bin/compile /app /var/cache/build/gems
```

### Dedicated Build Instance

If you'd like to segregate builds from apps, you can configure a dedicated build instance with the Rack `BuildInstance` parameter:

```
$ convox rack params set BuildInstance=c4.large
```

This will guarantee that:

* Builds get dedicated CPU and memory resources
* Builds do not affect app performance
* Builds do not affect app instance security
* A single Docker image cache is shared among every build

This option offers the best performance for very CPU or memory intensive builds. It also helps with compliance and system auditing requirements by moving all build operations off of application servers.

You will incur the cost of running a dedicated build instance 24/7.

### Dedicated Build Rack

You can also isolate builds on the Rack level.

This is the best option for teams with a very high volume of builds.