#!/bin/bash
banner()
{
  echo "+------------------------------------------+"
  printf "| %-40s |\n" "`date`"
  echo "|                                          |"
  printf "|`tput bold` %-40s `tput sgr0`|\n" "$@"
  echo "+------------------------------------------+"
}
cd "${0%/*}"
banner "Generating Server Certs"
./generate-server-certs.sh
banner "Generating Client Certs"
./generate-client-certs.sh
banner "Generating Client Certs for Java"
./generate-client-certs-for-java.sh
banner "Fin."
