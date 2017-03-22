---
title: "Troubleshooting"
---

## I got an error while installing Convox

Look at the AWS [Cloudformation Management Console](https://console.aws.amazon.com/cloudformation/home?region=us-east-1) and look for CREATE_FAILED errors on the "Events" tab.

Open a [Github issue](https://github.com/convox/rack/issues/new) with any errors you see in these events.

## I get an error when I deploy my app to Convox

Run `convox logs --app convox` to inspect the Convox API logs for errors and `convox deploy` to try again.

## My app deployed but I can not access it

Run `convox apps info` to find the load balancer endpoints for your application.

Run `convox ps` to determine if your application is booting successfully.

Run `convox logs` to inspect your application logs and cluster events for problems placing your container, starting your app, or registering with the load balancer.

## My deployment seems stuck

When you deploy your app, CloudFormation will not complete an update until the ECS services stabilize. If there's a problem, eventually the update will time out and roll back.

However, when you know there is an issue, you can run the `convox apps cancel` command. This will trigger an immediate CloudFormation rollback so you can fix the problem and try another deployment.

To figure out what's going wrong, you can look at the app logs via `convox logs` to check for crashes. If none of the application processes are crashing, try looking at the ECS Events for the application services in your [AWS ECS console](https://console.aws.amazon.com/ecs/home).

Some other possible causes of issues could be:

- Not enough capacity in your cluster (you can turn on Rack autoscaling with `convox rack params set Autoscale=Yes`)
- The app backend is not binding to the container port specified in `docker-compose.yml`
- The app backend is listening on 127.0.0.1 rather than 0.0.0.0
- The app is taking longer than the default health check timeout to bind to the specified port. If necessary you can extend the health check timeout with labels: https://convox.com/docs/load-balancers/#health-check-options
