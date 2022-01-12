#!/bin/bash
#set -x #echo on

# This script is based on instructions from
# https://docs.couchbase.com/server/6.6/manage/manage-security/configure-server-certificates.html

cd "${0%/*}"
cd servercertfiles

## the following steps require a running cluster


echo "10. Deploy the node certificate and node private key."
echo "See docker-compose.yaml"

# These are deployed by being moved to the inbox directory of the server, and made executable. The
# inbox directory must be created by the administrator. Proceed as follows:

#cd ..
#sudo mkdir /opt/couchbase/var/lib/couchbase/inbox/
#sudo cp ./public/chain.pem /opt/couchbase/var/lib/couchbase/inbox/chain.pem
#sudo cp ./private/pkey.key /opt/couchbase/var/lib/couchbase/inbox/pkey.key

echo "11. Upload the root certificate for the cluster"

curl -X POST --data-binary "@./ca.pem" \
http://Administrator:password@127.0.0.1:8091/controller/uploadClusterCA

# The root certificate is now activated for the entire cluster, and ready for use. This can be
# verified by means of Couchbase Web Console: access the Security screen, by means of the Security
# tab in the left-hand navigation bar. Then, left-click on the Root Certificate tab, located on the
# upper, horizontal navigation bar.

echo ""
echo "12. Reload the node certificate from disk, for the current node:"

curl -X POST \
http://Administrator:password@127.0.0.1:8091/node/controller/reloadCertificate

# The node certificate is now activated for the current node. Note that when, as is typical, the
# cluster contains more than one node, this step must be performed on each node of the cluster, with
# each individual IP address thereby specified in turn.
