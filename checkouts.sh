source versions.env

# ms_shared
cd mods/ms || { echo "❌ Errore: cartella mods/ms non trovata"; exit 1; }
git stash
git checkout "$checkout_ms_shared" || { echo "❌ Errore: checkout fallito su ms_shared"; exit 1; }
git stash pop
cd ../../

# ms_mcipipy
cd mods/ms/raspberryjammod/ms_mcpipy || { echo "❌ Errore: cartella mods/ms/raspberryjammod/ms_mcpipy non trovata"; exit 1; }
git stash
git checkout "$checkout_ms_mcpipy" || { echo "❌ Errore: checkout fallito su ms_mcpipy"; exit 1; }
git stash pop
cd ../../../../