#!/bin/bash

sudo salt-key -L
echo ""
echo "To accept a key, type 'sudo salt-key -a <key>'"
echo "To accept all keys, type 'sudo salt-key -A'"
echo "To reject a key, type 'sudo salt-key -d <key>'"
echo "To reject all keys, type 'sudo salt-key -D'"
echo ""