sed -i 's@https://wiscomsbeta.matematicasuperpiatta.it@https://wiscoms.matematicasuperpiatta.it@' mods/ms/ms_connect/init.lua
sed -i 's@= db_url_beta@= db_url_release@' mods/ms/raspberryjammod/ms_mcpipy/MTUser.py
sed -i 's@= db_url_local@= db_url_release@' mods/ms/raspberryjammod/ms_mcpipy/MTUser.py
sed -i 's@= db_url_old_wiscom@= db_url_release@' mods/ms/raspberryjammod/ms_mcpipy/MTUser.py
sed -i 's@= db_url_beta@= db_url_release@' mods/ms/raspberryjammod/mcpipy/mcpi/block.py
sed -i 's@= db_url_local@= db_url_release@' mods/ms/raspberryjammod/mcpipy/mcpi/block.py
sed -i 's@= db_url_old_wiscom@= db_url_release@' mods/ms/raspberryjammod/mcpipy/mcpi/block.py
