cp minetest.conf.ms minetest.conf
git clone --depth=1 -b 1.9.0mt8 https://github.com/minetest/irrlicht lib/irrlichtmt
git clone https://gitlab.com/leonardoguidoni/ms-shared.git mods/ms
cd mods/ms/raspberryjammod || exit
git clone https://gitlab.com/stemblocks/ms-mcpipy.git ms_mcpipy
cd ms_mcpipy || exit
mkdir ../../../../worlds
cp -r MATEMATICA_SUPERPIATTA ../../../../worlds
cd ../../../../
git clone https://github.com/minetest/minetest_game.git games/minetest_game
cd games/minetest_game || exit
git checkout bff7596364814e17f992f88a723a62957b29e69c
cd ../../ || exit
cp game.conf.ms games/minetest_game/game.conf
cp minetestgame.conf.ms games/minetest_game/minetest.conf
cd games/minetest_game/mods/ || exit
rm -rf beds binoculars boats bones bucket butterflies carts creative doors dungeon_lot env_sounds fireflies keysmap
rm -rf mtg_craftguide screwdriver sethome sfinv spawn vessels walls weather xpanes
cd ../../../ || exit

# COMPILING
cmake . -DRUN_IN_PLACE=TRUE -DBUILD_SERVER=TRUE -DBUILD_CLIENT=FALSE
make -j 1
python3 scr_change_settings.py

