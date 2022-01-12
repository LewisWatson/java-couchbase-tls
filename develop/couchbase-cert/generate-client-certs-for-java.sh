#!/bin/bash
# This script is based on instructions from
# https://docs.couchbase.com/server/6.6/manage/manage-security/configure-client-certificates.html#cert_auth_for_java_client

echo "1. Access the main working directory created by generate-server-certs.sh and \
generate-client-certs.sh, and create and access a new working directory for the Java client \
certificate to be created."

cd "${0%/*}"
cd servercertfiles
rm -rf javaclient
mkdir javaclient
cd javaclient

echo "2. Define two environment variables: one for the name of the keystore to be created, another \
for its password."

export KEYSTORE_FILE=my.keystore
export STOREPASS=storepass

echo "3. skipping installation of keytool utility, assuming already installed"

# sudo apt install openjdk-9-jre-headless

echo "4. Generate the keystore."

# Note that the password you specify for the alias, by means of the --keypass flag, must be
# identical to the password you specify for the keystore, by means of the --storepass flag. In this
# case, both passwords are specified as ${STOREPASS}; which resolves to storepass.

keytool -genkey -keyalg RSA -alias selfsigned \
-keystore ${KEYSTORE_FILE} -storepass ${STOREPASS} -validity 360 \
-keysize 2048 -noprompt  -dname "CN=clientuser, OU=People, O=MyCompany, \
L=None, S=None, C=UA" -keypass ${STOREPASS}

# Note that the Common Name for the certificate is specified as clientuser, which is the username
# established on Couchbase Server, whose role-assignment is supportive of reading and writing data
# to the data bucket.

echo "5. Generate the certificate signing-request"

keytool -certreq -alias selfsigned -keyalg RSA -file my.csr \
-keystore ${KEYSTORE_FILE} -storepass ${STOREPASS} -noprompt

# This creates the signing-request file, my.csr.
#
# Note that in this example, although only the Common Name is being used to establish the identity
# of the user seeking authorization, one or more Subject Alternative Names could also be added. For
# example, by adding -ext "san=email:john.smith@mail.com" to the certificate signing-request used in
# the current step, the email-address john.smith@mail.com could be established as the basis for an
# alternative username to be submitted for authentication. See Specifying Usernames for
# Client-Certificate Authentication, for more information.

echo "6. Generate the client certificate, signing it with the root private key, and thereby \
establishing the root certificate’s authority"

openssl x509 -req -in my.csr -CA ../ca.pem \
-CAkey ../ca.key -CAcreateserial -out clientcert.pem -days 365

echo "7. Add the root certificate to the keystore"

keytool -import -trustcacerts -file ../ca.pem \
-alias root -keystore ${KEYSTORE_FILE} -storepass ${STOREPASS} -noprompt

echo "8. Add the client certificate to the keystore"

keytool -import -keystore ${KEYSTORE_FILE} -file clientcert.pem \
-alias selfsigned -storepass ${STOREPASS} -noprompt