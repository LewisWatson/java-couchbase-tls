FROM gcr.io/distroless/java:11
ARG JAVA_OPTS
ENV JAVA_OPTS=$JAVA_OPTS
COPY build/libs/couchbase-tls-example*.jar service.jar
CMD ["service.jar"]