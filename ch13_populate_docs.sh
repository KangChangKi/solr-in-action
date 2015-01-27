#!/bin/bash

if [[ ! -f "solr-in-action.jar" ]]; then
	mvn clean package
fi

java -jar solr-in-action.jar indexlog -log=example-docs/ch13/solr.log
exit 0
