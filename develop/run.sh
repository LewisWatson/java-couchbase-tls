#!/usr/bin/env bash
#set -x #echo on

banner()
{
  echo "+------------------------------------------+"
  printf "|`tput bold` %-40s `tput sgr0`|\n" "$@"
  echo "|                                          |"
  printf "| %-40s |\n" "`date`"
  echo "+------------------------------------------+"
}

cd "${0%/*}"

banner "Generating couchbase server certificates"

./couchbase-cert/generate-server-certs.sh

banner "Spinning up couchbase"

docker-compose up couchbase --force-recreate --wait

until $(curl --output /dev/null --silent --head --fail http://127.0.0.1:8091); do
    printf '.'
    sleep 5
done

banner "Configuring couchbase server"

./configure-couchbase-server.sh

banner "Uploading couchbase server certs"

./couchbase-cert/load-certs-to-local-server.sh

banner "Generating client certificates"

./couchbase-cert/generate-client-certs.sh
./couchbase-cert/generate-client-certs-for-java.sh

banner "Building spring-boot-app"

cd ..
./gradlew build

banner "Spinning up rest of docker compose"

cd develop
docker-compose up -d --build

#banner "Follow logs for 1 minute"

#docker-compose logs --follow
