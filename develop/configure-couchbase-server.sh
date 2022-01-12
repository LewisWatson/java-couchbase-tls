#!/bin/bash
#set -x #echo on

# This script is based on instructions from
# - https://docs.couchbase.com/server/current/rest-api/rest-node-provisioning.html
# - https://docs.couchbase.com/server/current/manage/manage-buckets/create-bucket.html#create-bucket-with-the-rest-api

cd "${0%/*}"

## the following steps require a running cluster

echo "1. Enable Key Value, query, and index services"

curl  -u Administrator:password -v -X POST http://127.0.0.1:8091/node/controller/setupServices \
-d 'services=kv%2Cn1ql%2Cindex'

echo "2. Set memory quotas"

curl  -u Administrator:password -v -X POST http://127.0.0.1:8091/pools/default \
-d 'memoryQuota=256' \
-d 'indexMemoryQuota=256'

echo "3. Set admin credentials"

curl  -u Administrator:password -v -X POST http://127.0.0.1:8091/settings/web \
-d 'password=password&username=Administrator&port=SAME'

echo "3. Create data bucket"

curl -v -X POST http://Administrator:password@127.0.0.1:8091/pools/default/buckets \
-u Administrator:password \
-d name=data \
-d ramQuotaMB=256 \
-d durabilityMinLevel=majorityAndPersistActive

echo "4. Enable client certificate authentication"

echo -e '{"state": "enable", "prefixes": [{"path": "subject.cn", "prefix": "", "delimiter": ""}]}' \
| curl -v -X POST http://127.0.0.1:8091/settings/clientCertAuth \
--data-binary @- -u Administrator:password

echo "5. Create dev user with application access to data bucket"

curl -v -X PUT -u Administrator:password \
http://127.0.0.1:8091/settings/rbac/users/local/dev \
-d password=password \
-d roles=data_reader[data]