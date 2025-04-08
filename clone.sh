#!/bin/bash

source ./versions.env

git clone --depth=1 -b 1.9.0mt8 https://github.com/minetest/irrlicht lib/irrlichtmt
git clone -b "${checkout_ms_shared:-"develop"}" https://gitlab.com/leonardoguidoni/ms-shared.git mods/ms
git clone -b "${checkout_ms_mcpipy:-"develop"}" https://gitlab.com/stemblocks/ms-mcpipy.git mods/ms/raspberryjammod/ms_mcpipy
git clone -b "${checkout_minetest_game:-"bff7596364814e17f992f88a723a62957b29e69c"}" https://github.com/minetest/minetest_game.git games/minetest_game

mkdir worlds
cp -r mods/ms/raspberryjammod/ms_mcpipy/MATEMATICA_SUPERPIATTA worlds
cd games/minetest_game/mods/ || exit
rm -rf beds binoculars boats bones bucket butterflies carts doors dungeon_lot env_sounds fireflies keysmap \
       mtg_craftguide screwdriver sethome spawn vessels walls weather xpanes
cd ../../../ || exit
