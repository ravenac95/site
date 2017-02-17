---
title: Deploying with Buildpacks
author: Noah Zoschke
twitter: nzoschke
---

I'm excited to announce that Convox officially supports Heroku buildpacks.

Buildpacks are build scripts maintained over the years by language specialists at Heroku and in the open source community. 

Buildpacks are the best way to package apps that follow the 12 factor methods and haven't adopted Docker.

## Ghost App

First, clone an app. We'll use with the Ghost blogging platform. This app follows the 12 factor methods, so it should be easy to build and deploy.

```
$ git clone https://github.com/cobyism/ghost-on-heroku.git ghost-on-convox
$ cd ghost-on-convox
```

## Convox Init

Next, we'll use the `convox init` utility. This generates Docker configuration files that use the Heroku buildpacks correctly.

```
$ convox init
Updating convox/init... OK
Initializing a nodejs app
Writing entrypoint.sh... OK
Writing Dockerfile... OK
Writing .dockerignore... OK
Writing docker-compose.yml... OK

Try running `convox start`
```

## Convox Deploy

Now we're ready to deploy it:

```
$ convox deploy
Uploading: 5.64 KB / 5.47 KB [===========================] 103.16 % 0s
Starting build... OK

Step 1 : FROM heroku/cedar
...
Step 7 : RUN /tmp/heroku-buildpack-nodejs/bin/compile /app /tmp/cache
 ---> Running in 047365ea40b6

-----> Creating runtime environment
       
-----> Installing binaries
       engines.node (package.json):  ~0.12.0
       engines.npm (package.json):   unspecified (use default)

-----> Restoring cache
       Skipping cache restore (new runtime signature)

-----> Building dependencies
       Installing node modules (package.json)
    
       pg@6.1.2 node_modules/pg
       ├── packet-reader@0.2.0
       ├── pg-connection-string@0.1.3
       ├── buffer-writer@1.0.1
       ├── semver@4.3.2
       ├── pg-pool@1.6.0 (object-assign@4.1.0, generic-pool@2.4.2)
       ├── pg-types@1.11.0 (ap@0.2.0, postgres-bytea@1.0.0, postgres-date@1.0.3, postgres-array@1.0.2, postgres-interval@1.0.2)
       └── pgpass@1.0.1 (split@1.0.0)
       
      ...
-----> Build succeeded!
Successfully built edf5ca2de796

running: docker push 132866487567.dkr.ecr.us-east-1.amazonaws.com/dev-ghost-on-convox-hbljupmiyf:web.BBUGPAOVZZM
web.BBUGPAOVZZM: digest: sha256:2cde271e48b3b735fb15560924fdd850615eceebb3e4b2316cc646630eebc921 size: 2202

Release: RAMBBQNIXSY
Promoting RAMBBQNIXSY... UPDATING
```

We see that the build service uses the buildpack to package our application into a Docker image.

## Convox Env

Before the app will run, it needs a bit more configuration. The app environment variables are enumerated in `docker-compose.yml`:


```yaml
version: "2"
services:
  web:
    command: npm start --production
    environment:
    - PORT=4001
    - HEROKU_URL=https://YOURAPPNAME.herokuapp.com
    - S3_ACCESS_KEY_ID=
    - S3_ACCESS_SECRET_KEY=
    - S3_BUCKET_NAME=
    - S3_BUCKET_REGION=
    - S3_ASSET_HOST_URL=
    - PGSSLMODE=
```

The app needs to know its base URL. Let's use its ELB hostname for now.

```
$ convox apps info
Name       ghost-on-convox
Status     running
Release    RZWVBDWUPDB
Processes  database web
Endpoints  internal-ghost-on-convox-databa-DAL5SGR-i-1450741732.us-east-1.elb.amazonaws.com:5432 (database)
           ghost-on-convox-web-FF7DD5F-224923604.us-east-1.elb.amazonaws.com:443 (web)
           ghost-on-convox-web-FF7DD5F-224923604.us-east-1.elb.amazonaws.com:80 (web)


$ convox env set HEROKU_URL=ghost-on-convox-web-FF7DD5F-224923604.us-east-1.elb.amazonaws.com
Updating environment... OK
To deploy these changes run `convox releases promote RFWIVAEBSPI`

$ convox releases promote RFWIVAEBSPI
Promoting RFWIVAEBSPI... UPDATING
```

## Convox Resources

Finally we can add a production postgres database. We'll create one and give the app a new DATABASE_URL.

```
$ convox resources create postgres
Creating postgres-4328...

$ convox resources info postgres-4328
Name    postgres-4328
Status  running
Exports
  URL: postgres://postgres:***@dev-postgres-4328.cyzckls48pd3.us-east-1.rds.amazonaws.com:5432/app

$ convox env set DATABASE_URL=postgres://postgres:***@dev-postgres-4328.cyzckls48pd3.us-east-1.rds.amazonaws.com:5432/app
Updating environment... OK
To deploy these changes run `convox releases promote RWTRTXMWUSZ`

$ convox releases promote RFWIVAEBSPI
Promoting RWTRTXMWUSZ... UPDATING
```

## Conclusion



