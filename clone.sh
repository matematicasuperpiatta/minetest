#!/bin/bash

source ./versions.env

# clone and checkouts
git clone --depth=1 -b 1.9.0mt8 https://github.com/minetest/irrlicht lib/irrlichtmt

git clone https://gitlab.com/leonardoguidoni/ms-shared.git mods/ms
cd mods/ms && git checkout "${checkout_ms_shared:-"develop"}" && cd ../../

git clone https://gitlab.com/stemblocks/ms-mcpipy.git mods/ms/raspberryjammod/ms_mcpipy
cd mods/ms/raspberryjammod/ms_mcpipy && git checkout "${checkout_ms_mcpipy:-"develop"}" && cd ../../../../

git clone https://github.com/minetest/minetest_game.git games/minetest_game
cd games/minetest_game && git checkout "${checkout_minetest_game:-"bff7596364814e17f992f88a723a62957b29e69c"}" && cd ../../

# copies and deletions
mkdir worlds
cp -r mods/ms/raspberryjammod/ms_mcpipy/MATEMATICA_SUPERPIATTA worlds
cd games/minetest_game/mods/ || exit
rm -rf beds binoculars boats bones bucket butterflies carts doors dungeon_lot env_sounds fireflies keysmap \
       mtg_craftguide screwdriver sethome spawn vessels walls weather xpanes
cd ../../../ || exit
