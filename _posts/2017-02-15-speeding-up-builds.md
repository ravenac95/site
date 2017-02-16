---
title: Speeding Up Builds
author: Noah Zoschke
twitter: nzoschke
---

Nothing kills developer flow more than slow builds.

When a build takes only a few seconds it's impossible to lose focus on getting the patch out to production.

If a build takes 5 minutes, it can interrupt the release process just as much as when someone interrupts you for a conversation.

Adding a continuous delivery pipeline doesn't really solve the slow build problem. The interruption is still there, and the timeline might get even worse if the CD pipeline is backed up with other slow builds.

[https://imgs.xkcd.com/comics/compiling.png]

So how fast can we get builds?

## Discourse Rails Project Baseline

Let's start with the latest version of Ruby and Bundler, and the open-source [Discourse](https://github.com/discourse/discourse) message board built with Ruby on Rails.

On a fresh checkout it takes almost 3.5 minutes to build all the Ruby Gems.

```sh
$ ruby -v
ruby 2.3.2p217 (2016-11-15 revision 56796) [x86_64-darwin16]
$ bundle -v
Bundler version 1.14.4

$ git clone https://github.com/discourse/discourse && cd discourse

$ time bundle install --path vendor/bundle
Fetching version metadata from https://rubygems.org/..
Fetching dependency metadata from https://rubygems.org/.
Installing rake 11.2.2
Installing i18n 0.7.0
Installing json 1.8.6 with native extensions
...
Installing spork-rails 4.0.0
Bundle complete! 94 Gemfile dependencies, 175 gems now installed.
Bundled gems are installed into ./vendor/bundle.

real  3m26.618s
```

## Discourse Docker Baseline

Discourse also maintains a [Discourse Docker](https://github.com/discourse/discourse_docker) project with some Dockerfile recipes.

On a factory default Docker it takes 

```sh
$ docker -v
Docker version 1.13.1, build 092cba3

$ docker pull discourse/base:1.3.10
...
Status: Downloaded newer image for discourse/base:1.3.10


$ git clone https://github.com/discourse/discourse_docker && cd discourse_docker

$ time docker build image/discourse/
Step 1/3 : FROM discourse/base:1.3.10
Step 2/3 : MAINTAINER Sam Saffron "https://twitter.com/samsaffron"
Step 3/3 : RUN ... git clone https://github.com/discourse/discourse.git && cd discourse && bundle install ...
Fetching gem metadata from https://rubygems.org/.............
Fetching version metadata from https://rubygems.org/...
Fetching dependency metadata from https://rubygems.org/..
Installing rake 11.2.2
Installing i18n 0.7.0
Installing json 1.8.6 with native extensions
...
Installing spork-rails 4.0.0
Bundle complete! 94 Gemfile dependencies, 168 gems now installed.
Gems in the group development were not installed.
Bundled gems are installed into ./vendor/bundle.
...
Successfully built 8bdb40d44e37

real  2m59.310s
```