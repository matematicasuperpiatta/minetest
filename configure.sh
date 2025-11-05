#!/bin/bash

# Carica le variabili da config.env
source config.env

# Usa il valore di database_host da config.env o un valore di default
db_host="${database_host:-default}"

# Sovrascrivi il valore se già presente, altrimenti aggiungi la variabile al file minetest.conf
if grep -q "^database_host" "minetest.conf"; then
    # Se la riga esiste, sovrascrivila con il nuovo valore
    sed -i "s/^database_host.*/database_host = $db_host/" "minetest.conf"
else
    # Se la riga non esiste, aggiungi la variabile al file
    echo "
database_host = $db_host" >> "minetest.conf"
fi

echo "Configurato database_host nel file minetest.conf: $db_host"

# Usa il valore di database_host da config.env o un valore di default
wiscom_local="${wiscom_local:-default}"

# Sovrascrivi il valore se già presente, altrimenti aggiungi la variabile al file minetest.conf
if grep -q "^wiscom_local" "minetest.conf"; then
    # Se la riga esiste, sovrascrivila con il nuovo valore
    sed -i "s/^wiscom_local.*/wiscom_local = $wiscom_local/" "minetest.conf"
else
    # Se la riga non esiste, aggiungi la variabile al file
    echo "
wiscom_local = $wiscom_local" >> "minetest.conf"
fi

echo "Configurato wiscom_local nel file minetest.conf: $wiscom_local"
