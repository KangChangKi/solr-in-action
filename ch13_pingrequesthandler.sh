#!/bin/bash

SRC_DIR="$(pwd)"

pushd . 2>&1 >/dev/null

if [[ ! -f "test_ping.jar" ]]; then
    mvn clean compile
    cd target/classes
    jar cfv test_ping.jar sia/ch13/ClusterStateAwarePingRequestHandler.class
    mv test_ping.jar ../..
    cd ../..
fi

cd /usr/local/solr
if [[ ! -d "common_lib" ]]; then
    mkdir common_lib
fi
cp "$SRC_DIR/test_ping.jar" "common_lib"

echo <<EOF
1. Put this into solrconfig.xml:
<requestHandler name="/admin/ping2" class="sia.ch13.ClusterStateAwarePingRequestHandler">
    <lst name="invariants">
      <str name="q">id:0</str>
      <bool name="distrib">false</bool>
    </lst>
    <lst name="defaults">
      <str name="echoParams">all</str>
    </lst>
  </requestHandler>

2. Upload configuration file on ZooKeeper:
./zk_upconfig.sh /usr/local/solr/shard1/solr/logmill/conf logmill

3. Reload the collection with admin API:
http://localhost:8983/solr/admin/collections?action=RELOAD&name=logmill

4. Test ping request:
http://localhost:8983/solr/logmill/admin/ping2?wt=json

EOF
fi

popd 2>&1 >/dev/null
exit 0
