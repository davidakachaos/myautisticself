#!/usr/bin/env bash
 zoneid=`cat .cloudflare_zone`
 key=`cat .cloudflare_key`
 curl -s -X POST "https://api.cloudflare.com/client/v4/zones/{$zoneid}/purge_cache" \
   -H "X-Auth-Email: davidakachaos0@gmail.com" \
   -H "X-Auth-Key: {$key}" \
   -H "Content-Type: application/json" \
   --data '{"files":["https://myautisticself.nl/"]}'
