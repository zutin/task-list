#!/bin/bash

rm -f tmp/pids/server.pid

bin/setup --skip-server
bundle exec rails server -b 0.0.0.0 -p 3000
