#!/bin/bash

curl -X DELETE "https://api.cloudflare.com/client/v4/zones/${CF_ZONEID_JAMESHALENET}/purge_cache" \
     -H "X-Auth-Email: ${CF_EMAIL}" \
     -H "X-Auth-Key: ${CF_API_KEY}" \
     -H "Content-Type: application/json" \
     --data '{"purge_everything":true}'

echo "Cloudflare cache purged."
