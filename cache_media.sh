#!/bin/bash
#
# Costruisce media/ : una copia di ogni file multimediale, rinominata con il suo
# sha1, piu' l'indice index.mth. La cartella viene poi caricata su S3 e servita
# al client come remote media server.
#
# Estensioni accettate dal client (ms_client/src/client/client.cpp, Client::loadMedia):
#   immagini    .png .jpg .bmp .tga .pcx .ppm .psd .wal .rgb
#   suoni       .ogg
#   modelli     .x .b3d .md2 .obj
#   traduzioni  .tr
# NB: .jpeg NON e' fra queste (il client riconosce solo .jpg): raccoglierlo
#     significherebbe pubblicare su S3 file che nessun client puo' caricare.

set -uo pipefail

MEDIA_EXT=( png jpg bmp tga pcx ppm psd wal rgb ogg x b3d md2 obj tr )

# Espressione find con le estensioni raggruppate.
# Il raggruppamento con \( \) e' necessario: -a lega piu' stretto di -o, quindi
# "find -type f -name A -o -name B" viene letto come "(-type f -a -name A) -o -name B"
# e per tutte le estensioni dopo la prima il filtro -type f non si applica.
FIND_EXPR=()
for e in "${MEDIA_EXT[@]}"; do
	[ ${#FIND_EXPR[@]} -gt 0 ] && FIND_EXPR+=( -o )
	FIND_EXPR+=( -iname "*.${e}" )
done

total=0
copied=0
dups=0

collect_from () {
	if [ ! -d "$1" ]; then
		echo "Skipping (not found): $1"
		return 0
	fi
	echo "Processing media from: $1"
	local n=0 c=0 d=0
	while IFS= read -r -d '' f; do
		hash=$(openssl dgst -sha1 <"$f" | awk '{print $NF}')
		n=$((n + 1))
		if [ -e "media/$hash" ]; then
			d=$((d + 1))
		else
			c=$((c + 1))
		fi
		cp -- "$f" "media/$hash"
	done < <(find -L "$1" -type f \( "${FIND_EXPR[@]}" \) -print0)
	echo "  $n file, $c contenuti nuovi, $d duplicati collassati"
	total=$((total + n))
	copied=$((copied + c))
	dups=$((dups + d))
}

mkdir -p media/
# Change this 'collect_from' or add more lines of 'collect_from', the script will recursively
# search for files with extensions of Minetest media in this folder.
# This is an example to be run in a game folder, but you can change this to anything to catch
# all textures that a server uses.
collect_from mods/
# Example for MineClone2 (they put textures in textures/ now)
collect_from worlds/
collect_from games/

printf "Creating index.mth... "
printf "MTHS\x00\x01" > media/index.mth
# -not -name index.mth evita di includere l'indice in se stesso.
# sort rende l'output deterministico: rigenerando media/ senza cambiamenti
# index.mth resta identico byte per byte.
find media/ -type f -not -name index.mth -print0 | sort -z | while IFS= read -r -d '' f; do
	openssl dgst -binary -sha1 <"$f" >> media/index.mth
done
echo "done"

echo
echo "Riepilogo: $total file esaminati, $copied contenuti unici in media/, $dups duplicati collassati"
