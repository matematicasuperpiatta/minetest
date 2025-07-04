#!/bin/bash

rm -f ./worlds/MATEMATICA_SUPERPIATTA/map.sqlite
cp ./mods/ms/raspberryjammod/ms_mcpipy/MATEMATICA_SUPERPIATTA/map.sqlite ./worlds/MATEMATICA_SUPERPIATTA/
./bin/minetestserver --world ./worlds/MATEMATICA_SUPERPIATTA/ --port 30000
