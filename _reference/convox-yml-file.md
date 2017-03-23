---
title: convox.yml File
---

`convox.yml` is a special file you can place in your project root directory to customize local development and deployment behavior.

It is composed of five keys: `balancers`, `services`, `tables`, `timers` and `profiles`.

<pre class="file yaml" title="convox.yml">
<a href="#balancers"><strong>balancers</strong></a>:
  <em style="color: green;">web-balancer</em>:
    80/http: http://my-web:5000
    443/https: http://my-web:5000
  redis:
    6379/tcp: tcp://redis:6379

<a href="#logs"><strong>logs</strong></a>:
  - syslog://papertrail.example.org:9833

<a href="#queues"><strong>queues</strong></a>: 
  workflows: 
    timeout: 20m

<a href="#services"><strong>services</strong></a>:
  my-web:
    build: .
    <a href="#command">command</a>: <bin/web.sh
    environment: 
      - DEVELOPMENT=true
      - KEY
    links: 
      - my-redis
    <a href="#scale">scale</a>:
      <a href="#count">count</a>: 2-10
      <a href="#cpu">cpu</a>: 1.0
      <a href="#ram">ram</a>: 512mb
      <a href="#down-up">down</a>: cpu<5%
      <a href="#down-up">up</a>: latency>100ms

  my-workflow:
    build: .
    <a href="#command">command</a>: bin/workflow.sh
    <a href="#scale">scale</a>:
      <a href="#count">count</a>: 2+
      <a href="#cpu">cpu</a>: 0.25
      <a href="#ram">ram</a>: 2gb
      <a href="#down-up">down</a>: queue.workflows.length<10
      <a href="#down-up">up</a>:
        - cpu>80%
        - queue.workflows.length>100/15m
        - web.latency>100ms

  my-redis:
    image: convox/redis
    <a href="#command">command</a>: redis-server /tmp/redis.conf

<a href="#tables"><strong>tables</strong></a>:
  authorizations:
    indexes:
      - type
      - user:type
  integrations:
    indexes:
      - type
      - organization:type
  memberships:
    indexes:
      - organization:user
  organizations:
    indexes:
      - name
      - plan
  racks:
    indexes:
      - organization:name
  users: 
    indexes:
      - email
<a href="#timers"><strong>timers</strong></a>:
  cleanup:
    schedule: */5 * * * ?
    service: web
    command: bin/cleanup
<a href="#profiles"><strong>profiles</strong></a>:
  production:
    services:
      database:
        image:
        resource: postgres
</pre>

## `balancers`

In the `balancers` section you can customize the load balancers that Convox places in front of each service with published ports.

<pre>
balancers:
  <em style="color: green;">web-balancer</em>:
    80/http: http://my-web:5000
    443/https: http://my-web:5000
  redis:
    6379/tcp: tcp://redis:6379
</pre>

The format is composed of five elements:

`PUBLIC_PORT`/`PUBLIC_SCHEME`: `BALANCER_SCHEME`://`SERVICE_NAME`:`CONTAINER_PORT`

For example:

    80/http: http://my-web:5000

In the example above, inbound `http` connections to your balancer on port `80` will be directed to a random container of the `my-web` service via `http` on port `5000`.

## `services`

This is the most important section of `convox.yml`. Its format is the same as that of the [`docker-compose.yml` `services` section](/docs/docker-compose-file/).

<div class="block-callout block-show-callout type-info" markdown="1">
<strong>Service Names</strong>

Please note that service names should not include underscores.

    services:
      foo_bar: # will not work

Dashed service names are allowed, e.g. `foo-bar`.
</div>

### `command`

See [Command](/docs/docker-compose-file/#command).

### `environment`

See [Environment](/docs/docker-compose-file/#environment).

### `links`

See [Links](/docs/docker-compose-file/#links).

### `scale`

The `scale` key allows you to customize autoscaling behavior.

#### `count`

`count` refers to the number of instances that a given service should have. It can be in any of the following forms:

- an **integer** (e.g. `5` = there should always be _at least 5 instances_)
- a **range** (e.g. `2-10` = there should always be _between 2 and 10 instances_)
- an **unbounded** range (e.g. `1+` = there should always be _at least one instance_)

#### `cpu`

#### `ram`

#### `down`, `up`

`down` and `up` define the conditions at which up or down scaling should occur, e.g.:

| **Example**                       | **Meaning**                                                                                                           |
| `cpu<5%`                          | The action should occur when CPU usage drops below 5%.                                                            |
| `web.latency>100ms`               | The action should occur when average latency of the `web` service increases above 100 milliseconds.               |
| `queue.workflows.length>100/15m`  | The action should occur when the length of the workflows queue has been higher than 100 for at least 15 minutes.  |


## `buckets`

TODO

## `ingress`

TODO

## `logs`

TODO

## `queues`

TODO

## `tables`

The `tables` key allows you to define database tables.

```
  authorizations:
    indexes:
      - type
      - user:type
```

## `timers`

Recurring, cron-like tasks can be defined with the `timers` key.

```
timers:
  cleanup:
    schedule: */5 * * * ?
    service: web
    command: bin/cleanup
```

For details, see [Scheduled Tasks](/docs/scheduled-tasks/).

## `profiles`

`profiles` allow you to define different environments, such as `production` and `development`. This is useful for making the app behave differently in production versus local development.

```yaml
profiles:
  production:
    services:
      my-redis:
        image:
        resource: postgres
```

`production` in the example above can be replaced with any name of your choice, such as `staging`, `preprod`, and so on.

The items will inherit from the definitions in the top-level `services` key. You only need to modify `profiles` to the extent you want to override the behavior defined in `services`.
