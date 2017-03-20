---
title: "Logs"
order: 600
---

You can view the live logs for a Convox application using `convox logs`:

```
$ convox logs
2016-04-12 19:45:00 i-0234d285 example-app/web:RSPZQWVWGOP : 10.0.1.242 - - [12/Apr/2016:19:45:00 +0000] "GET / HTTP/1.1" 200 70 "-" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2623.112 Safari/537.36"
2016-04-12 19:45:00 i-0234d285 example-app/web:RSPZQWVWGOP : 10.0.1.242 - - [12 Apr/2016:19:45:00 +0000] "GET / HTTP/1.0" 200 70 0.0019
2017-03-24T21:34:06Z [CFM] resource="WoprECSTaskDefinition" status="DELETE_IN_PROGRESS" reason=""
2017-03-24T21:34:08Z [ECS] service="legit-cv-soulshake-net-ServiceWopr-1TNE86TXRESN5" task="46a3ea28-4868-4620-b43c-5e4af6732219" status="STOPPED" container="wopr"
2017-03-24T21:34:09Z [ECS] service="legit-cv-soulshake-net-ServiceWopr-1TNE86TXRESN5" task="46a3ea28-4868-4620-b43c-5e4af6732219" status="RUNNING" container="wopr"
2017-03-24T21:34:11Z [CFM] resource="WoprECSTaskDefinition" status="DELETE_COMPLETE" reason=""
2017-03-24T21:34:11Z [CFM] resource="legit-cv-soulshake-net" status="UPDATE_COMPLETE" reason=""
```

Relevant AWS events from CloudFormation and ECS are denoted `[CFM]` and `[ECS]`.

### Additional Options

<table>
  <tr><th>Option</th><th>Description</th></tr>
  <tr><td><code>--follow=<b><i>false</i></b></code></td><td>Return a finite set of logs. Useful for reporting.</td></tr>
  <tr><td><code>--filter=<b><i>'web "GET /"'</i></b></code></td><td>Return only the logs that match all the filters. Filters are case sensitive and non-alphanumeric terms must be inside double quotes.</td></tr>
  <tr><td><code>--since=<b><i>20m</i></b></code></td><td>Return logs starting this duration ago. Values are a duration like <code>10m</code> or <code>48h</code>.</td></tr>
</table>

You can tie all these together to generate a report from the logs from a single container over the last 2 days:

```
$ convox ps
ID            NAME  RELEASE      SIZE  STARTED     COMMAND
310481bf223f  web   RSPZQWVWGOP  256   2 days ago  bin/web
5e3c8576b942  web   RSPZQWVWGOP  256   2 days ago  bin/web

$ convox logs --filter=5e3c8576b942 --follow=false --since=48h
2016-04-25T21:02:17Z agent:0.68/i-07a8209a Starting web process 5e3c8576b942
2016-04-25T21:02:18Z web:RSPZQWVWGOP/5e3c8576b942 AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 172.17.0.4. Set the 'ServerName' directive globally to suppress this message
2016-04-25T21:02:18Z web:RSPZQWVWGOP/5e3c8576b942 [Mon Apr 25 21:02:18.191234 2016] [mpm_event:notice] [pid 1:tid 140438897768320] AH00489: Apache/2.4.20 (Unix) configured -- resuming normal operations
2016-04-25T21:02:18Z web:RSPZQWVWGOP/5e3c8576b942 [Mon Apr 25 21:02:18.192039 2016] [core:notice] [pid 1:tid 140438897768320] AH00094: Command line: 'httpd -D FOREGROUND'
2016-04-25T21:12:02Z web:RSPZQWVWGOP/5e3c8576b942 10.0.3.243 - - [25/Apr/2016:21:12:02 +0000] "GET / HTTP/1.1" 200 226
...
```

### Rack Logs

You can view the logs for a Convox Rack itself using the `convox rack logs` command:

```
$ convox rack logs
2017-03-24T21:59:56Z [CFM] resource="LaunchConfiguration" status="UPDATE_IN_PROGRESS" reason="Resource creation Initiated"
2017-03-24T21:59:56Z [CFM] resource="LaunchConfiguration" status="UPDATE_COMPLETE" reason=""
2017-03-24T21:59:57Z web:20170322201601/0b92eed79c1d ns=provider.aws at=fetchLogs start=1490392796065 events=0 state=success end=1490392796066 elapsed=225.020
2017-03-24T22:00:04Z [CFM] resource="Instances" status="UPDATE_IN_PROGRESS" reason=""
2017-03-24T22:16:15Z web:20170322201601/e378ddb167fd who="EC2/ASG" what="Terminating EC2 instance: i-02ce4f07da10a5333" why="At 2017-03-24T22:14:38Z a user request update of AutoScalingGroup constraints to min: 3, max: 1000, desired: 3 changing the desired capacity from 4 to 3.  At 2017-03-24T22:15:02Z an instance was taken out of service in response to a difference between desired and actual capacity, shrinking the capacity from 4 to 3.  At 2017-03-24T22:15:02Z instance i-02ce4f07da10a5333 was selected for termination."
```

Relevant AWS events from CloudFormation and ECS are denoted `[CFM]` and `[ECS]`.

You can use filters to understand Rack operations like what webhooks were sent:

```
$ convox rack logs --filter=EventSend --follow=false --since=1h
2016-09-19T05:28:22Z web:20160916121812/560705a6c103 aws EventSend msg="{\"action\":\"release:create\",\"status\":\"success\",\"data\":{\"app\":\"site-staging\",\"id\":\"RGZFEZWCLJY\"},\"timestamp\":\"2016-09-19T05:28:22.939075154Z\"}"
2016-09-19T05:29:42Z web:20160916121812/1a7fc4c6d61b aws EventSend msg="{\"action\":\"rack:update\",\"status\":\"success\",\"data\":{\"count\":\"5\"},\"timestamp\":\"2016-09-19T05:29:42.46924934Z\"}"
2016-09-19T05:30:26Z web:20160916121812/560705a6c103 aws EventSend msg="{\"action\":\"build:create\",\"status\":\"success\",\"data\":{\"app\":\"site-staging\",\"id\":\"BLRICHJXPCV\"},\"timestamp\":\"2016-09-19T05:30:26.007917831Z\"}"
```
