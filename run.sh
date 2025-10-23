#!/bin/bash

rm -f ./worlds/MATEMATICA_SUPERPIATTA/map.sqlite
cp ./mods/ms/raspberryjammod/ms_mcpipy/MATEMATICA_SUPERPIATTA/map.sqlite ./worlds/MATEMATICA_SUPERPIATTA/
screen -S MEDIA_SERVER -X quit
screen -dmS MEDIA_SERVER bash -c 'python3 media_server.py; exec bash'
./bin/minetestserver --world ./worlds/MATEMATICA_SUPERPIATTA/ --port 30000