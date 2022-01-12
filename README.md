# Java Couchbase TLS

Demonstrates how to connect a Java application to a Couchbase server using TLS encryption and
certificate based authentication.

## Requirements

- Java Development Kit 11+
- Docker 20+

## Build & run

A shell script is provided that will:

- Generate server and client certificates
- Spin up a single node couchbase cluster using the generated server certificate
- Build and spin up a Java service to connect to couchbase using the generated client certificate

```shell
./develop/run.sh
```

## Issues

At time of writing the Java service is outputting warnings

```shell
spring-boot-app  | 
spring-boot-app  | 2022-01-12 13:55:42.786  WARN 1 --- [      cb-events] com.couchbase.endpoint                   : [com.couchbase.endpoint][EndpointConnectionFailedEvent][10s] Connect attempt 2 failed because of TimeoutException: Did not observe any item or terminal signal within 10000ms in 'source(MonoDefer)' (and no fallback has been configured) {"bucket":"data","circuitBreaker":"DISABLED","coreId":"0x78a02a1e00000001","remote":"couchbase:11207","type":"KV"}
spring-boot-app  | 
spring-boot-app  | java.util.concurrent.TimeoutException: Did not observe any item or terminal signal within 10000ms in 'source(MonoDefer)' (and no fallback has been configured)
spring-boot-app  |      at reactor.core.publisher.FluxTimeout$TimeoutMainSubscriber.handleTimeout(FluxTimeout.java:295) ~[reactor-core-3.4.13.jar!/:3.4.13]
spring-boot-app  |      at reactor.core.publisher.FluxTimeout$TimeoutMainSubscriber.doTimeout(FluxTimeout.java:280) ~[reactor-core-3.4.13.jar!/:3.4.13]
spring-boot-app  |      at reactor.core.publisher.FluxTimeout$TimeoutTimeoutSubscriber.onNext(FluxTimeout.java:419) ~[reactor-core-3.4.13.jar!/:3.4.13]
spring-boot-app  |      at reactor.core.publisher.FluxOnErrorResume$ResumeSubscriber.onNext(FluxOnErrorResume.java:79) ~[reactor-core-3.4.13.jar!/:3.4.13]
spring-boot-app  |      at reactor.core.publisher.MonoDelay$MonoDelayRunnable.propagateDelay(MonoDelay.java:271) ~[reactor-core-3.4.13.jar!/:3.4.13]
spring-boot-app  |      at reactor.core.publisher.MonoDelay$MonoDelayRunnable.run(MonoDelay.java:286) ~[reactor-core-3.4.13.jar!/:3.4.13]
spring-boot-app  |      at reactor.core.scheduler.SchedulerTask.call(SchedulerTask.java:68) ~[reactor-core-3.4.13.jar!/:3.4.13]
spring-boot-app  |      at reactor.core.scheduler.SchedulerTask.call(SchedulerTask.java:28) ~[reactor-core-3.4.13.jar!/:3.4.13]
spring-boot-app  |      at java.base/java.util.concurrent.FutureTask.run(FutureTask.java:264) ~[na:na]
spring-boot-app  |      at java.base/java.util.concurrent.ScheduledThreadPoolExecutor$ScheduledFutureTask.run(ScheduledThreadPoolExecutor.java:304) ~[na:na]
spring-boot-app  |      at java.base/java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1128) ~[na:na]
spring-boot-app  |      at java.base/java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:628) ~[na:na]
spring-boot-app  |      at java.base/java.lang.Thread.run(Thread.java:829) ~[na:na]
spring-boot-app  | 
```