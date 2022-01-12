#!/bin/bash
# This script is based on instructions from
# https://docs.couchbase.com/server/6.6/manage/manage-security/configure-server-certificates.html

echo "1. Create working directories"

cd "${0%/*}"
rm -rf servercertfiles
mkdir servercertfiles
cd servercertfiles
mkdir -p {public,private,requests}

echo "2. Create a private key for the cluster."

# A private key can be used to decrypt data previously encrypted by the corresponding public key.
# It can also be used to sign a message that is then sent by the client to the server; allowing the
# client’s identity to be verified by the server, using the client’s public key. In the key-creation
# sequence, the private key is created first. Then, the public key is created, being derived from
# the private key.

openssl genrsa -out ca.key 2048

echo "3. Create the certificate (that is, the file that will contain the public key) for the \
cluster."

# The certificate is intended to be self-signed, meaning that it will not be vouched for by any
# other authority. This means that it can be created directly, based on the existing private key
# ca.key, without assistance from a third party.

openssl req -new -x509 -days 3650 -sha256 -key ca.key -out ca.pem \
-subj "/CN=Couchbase Root CA"

# The x509 flag indicates that in this case, an x509 structure, rather than a request is to be
# generated. (By contrast, a request will need to be generated whenever the signature of a
# third-party authority is required: this is demonstrated below.) The days flag specifies the number
# of days for which the certificate should be active. The hashing algorithm to be used for
# digital-signature creation is specified as sha256. The private key file on which the certificate
# is to be based is specified as ca.key, and the output-certificate is named as ca.pem. The
# certificate’s issuer is specified to have the CN (Common Name) of Couchbase Root CA: as this name
# indicates, the certificate will be the root certificate for the Couchbase Server-cluster.

echo "4. Create a private key for the individual node."

# In addition to the root certificate and private key for the entire cluster, which are ca.pem and
# ca.key, a node certificate and private key must also be created. The node certificate, along with
# its corresponding node-private key, will reside on its own, corresponding node. When deployed,
# each node certificate must be named chain.pem, and each node private key pkey.key. Consequently,
# if the node certificates and private keys for multiple nodes are being prepared on a single
# system, the files should be given individual, distinctive names on creation; and then each
# deployed on its appropriate node as either chain.pem or pkey.key. This renaming procedure is
# indeed followed here for demonstration purposes, even though only a one-node cluster is involved.

openssl genrsa -out private/couchbase.default.svc.key 2048

echo "5. Create a certificate signing request for the node certificate."

# This step allows the materials required for certificate-creation to be passed to a third-party,
# who will digitally sign the certificate as part of its creation-process, and thereby confirm its
# validity. (In this demonstration, however, no actual third-party is involved: the certificate will
# be signed by means of the root private key, which is owned by the current user.)

openssl req -new -key private/couchbase.default.svc.key \
-out requests/couchbase.default.svc.csr -subj "/CN=Couchbase Server"
openssl req -noout -verify -in ./requests/couchbase.default.svc.csr

echo "6. Define certificate extensions for the node."
#
# Certificate extensions specify constraints on how a certificate is to be used. Extensions are
# submitted to the signing authority, along with the certificate signing request.
#
# For example, the certificate’s public key can be specified, by means of the keyUsage extension, to
# support digital signatures, but not to support key encipherment — or, the opposite can be
# specified; or, support of both digital signatures and key encipherment can be specified.
# Meanwhile, the subjectAltName extension can be used to specify the DNS name and IP address of the
# server on which the certificate resides; so that if the certificate is deployed in any other
# context, it becomes invalid.
#
# Certificate extensions can be defined in a file, whose pathname is then provided as a parameter to
# the openssl command used to create the certificate. Thus, such server-certificate extensions as
# are intended to be generic across all cluster-nodes might be written as follows:

cat > server.ext <<EOF
basicConstraints=CA:FALSE
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer:always
extendedKeyUsage=serverAuth
keyUsage = digitalSignature,keyEncipherment
EOF

# The value of extendedKeyUsage is specified as serverAuth, indicating that the certificate is to be
# used for server authentication. The values of keyUsage are digitalSignature, specifying that the
# certificate’s public key can be used in the verifying of information-origin; and keyEncipherment,
# specifying that the public key can be used in the encrypting of symmetric keys (through the
# exchange and use of which symmetrically encrypted communications between server and client can
# occur).

echo "7. Create a customized certificate extensions file, which adds per node constraints to the \
generic constraints already specified."

# This customized extensions file is to be used to authenticate a single node, whose DNS address is
# couchbase (the name of the docker compose service).
# Note that if the DNS naming-convention is used by the cluster, the node’s DNS name
# might be specified instead: for example, DNS:node2.cb.com. If the node is not identified
# appropriately in the certificate, authentication fails.
#
# The creation of the customized extensions file should occur once for each node, with each
# customized extensions file containing only those extensions that apply to the current node.

cp ./server.ext ./server.ext.tmp

echo "subjectAltName = DNS:couchbase" \
>> ./server.ext.tmp

echo "8. Create the node certificate, applying the certificate and digital signature of the \
appropriate authority, and the customized extensions file for the node, to the materials in the \
signing request."

# The file generated by this command, couchbase.default.svc.pem, is the node certificate. The root
# certificate and private key, ca.pem and ca.key, are specified as input values to the
# certificate-creation command. This ensures that the new certificate’s chain of trust includes the
# root certificate, ca.pem, and is digitally signed by ca.key; allowing that signature to be
# verified by means of the public key.

openssl x509 -CA ca.pem -CAkey ca.key -CAcreateserial -days 365 -req \
-in requests/couchbase.default.svc.csr \
-out public/couchbase.default.svc.pem \
-extfile server.ext.tmp

echo "9. Rename the node certificate and node private key."

# For deployment on the node, the node certificate must be renamed chain.pem; and the node private
# key renamed pkey.key.

cd ./public
mv couchbase.default.svc.pem chain.pem
cd ../private
mv couchbase.default.svc.key pkey.key
