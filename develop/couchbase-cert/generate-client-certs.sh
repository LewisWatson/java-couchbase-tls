#!/bin/bash
# This script is based on instructions from
# https://docs.couchbase.com/server/6.6/manage/manage-security/configure-client-certificates.html#client-certificate-authorized-by-a-root-certificate

echo "1. Within the top-level directory created by generate-client-certs.sh, create and access a \
new working directory."

cd "${0%/*}"
cd servercertfiles
rm -rf clientcertfiles
mkdir clientcertfiles
cd clientcertfiles

echo "2. Create an extensions file for the use of all clients."

cat > client.ext <<EOF
basicConstraints = CA:FALSE
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer:always
extendedKeyUsage = clientAuth
keyUsage = digitalSignature
EOF

# This specifies a value of FALSE for CA, indicating that the client certificate will not have the
# ability to act as an authority for other certificates. Its extendedKeyUsage is specified as
# clientAuth, indicating that the certificate will be used for authenticating a client. It keyUsage
# is specified as digitalSignature, indicating that its public key is usable for data-origin
# authentication.
#
# This extensions file thus contains definitions judged appropriate for all clients. Further
# constraints can be added for individual clients, as necessary.

echo "3. Create a client private key."

openssl genrsa -out ./data.key 2048

# This creates the private key data.key.

echo "4. Generate the client-certificate signing-request."

openssl req -new -key ./data.key -out ./data.csr -subj "/CN=dev"

# The client’s private key, data.key is provided as input for the signing request. The Common Name
# provided as Subject for the certificate is specified as dev, which is the name of the
# server-defined user to be authenticated by the client. The output request-file, data.csr is saved
# in the current directory.

echo "5. skipping Optional, customize a client extensions file, to identify a username to be \
authenticated."

# As described in Specifying Usernames for Client-Certificate Authentication, a client certificate
# should contain a username, against which authentication can be performed on Couchbase Server.
# The server’s default handling assumes that the Subject Common Name specifies the username.
# However, a Subject Alternative Name might be used; either in addition, or as an alternative.
#
# The following subjectAltName statement allows an email address to be specified as the basis for
# the username.
#
# cp ./client.ext ./client.ext.tmp
#
# echo "subjectAltName = email:john.smith@mail.com" \
# >> ./client.ext.tmp
#
# If Couchbase Server is configured to search for an email address to be used as a username (as
# described in Specifying Usernames for Client-Certificate Authentication and Enable
# Client-Certificate Handling), the user john.smith will be submitted for authentication.
#
#If this extension is not added, and Couchbase Server client-certificate handling is left at its
# default, the Common Name (which was specified as clientuser, when the client-certificate
# signing-request was generated) will continue to be used as the username.

echo "6. Create the client certificate."

# In this example, the customized extensions file, client.ext.tmp, is used. However, if no email
# address or other Subject Alternative Name has been added, the generic client-extensions file,
# client.ext, can be used instead.

# NOTE: we have used the generic on in this script

openssl x509 -CA ../ca.pem -CAkey ../ca.key \
-CAcreateserial -days 365 -req -in ./data.csr \
-out ./data.pem -extfile ./client.ext

# The root certificate for the cluster, and its corresponding private key, ca.pem and ca.key are
# specified as inputs for certificate generation, so establishing the root certificate’s authority,
# within the client certificate. The output file, data.pem, is the client certificate, and is saved
# in clientcertfiles.
