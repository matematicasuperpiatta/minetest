#!/bin/bash

source ./versions.env

git clone https://gitlab.com/leonardoguidoni/ms-shared.git mods/ms
cd mods/ms/raspberryjammod || exit
git clone https://gitlab.com/stemblocks/ms-mcpipy.git ms_mcpipy
cd ms_mcpipy || exit
mkdir ../../../../worlds
cp -r MATEMATICA_SUPERPIATTA ../../../../worlds
cd ../../../../
