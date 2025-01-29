'''
ATTENTION:  currently a reverse script to return to a remote server does not exist! Use carrefully.
'''

db_local_address = "127.0.0.1:8000/wiscom"
db_database = "database_local"
db_host = "127.0.0.1"
db_password = "admin"


########################################################################################################################
# ms_connect/init.lua
with open("mods/ms/ms_connect/init.lua", "r") as file:
   lines = file.readlines()
for i, line in enumerate(lines):
   if "matematicasuperpiatta.it/wiscom" in line:
      lines[i] = line.split(" = ")[0] + ' = "' + db_local_address + '/api/",\n'
with open("mods/ms/ms_connect/init.lua", "w") as file:
   for line in lines:
      file.write(line)
      
# MTUser.py
with open("mods/ms/raspberryjammod/ms_mcpipy/MTUser.py", "r") as file:
   lines = file.readlines()
for i, line in enumerate(lines):
   if "wiscom_local = " in line:
      lines[i] = line.split(" = ")[0] + ' = True\n'
   if i > 1 and 'if wiscom_local:' in lines[i-1]:
      if "self._base_url = " in line:
         lines[i] = line.split(" = ")[0] + ' = db_url_local\n'
with open("mods/ms/raspberryjammod/ms_mcpipy/MTUser.py", "w") as file:
   for line in lines:
      file.write(line)

# database.py
with open("mods/ms/raspberryjammod/ms_mcpipy/database.py", "r") as file:
   lines = file.readlines()
for i, line in enumerate(lines):
   if "host=" in line and not "# host=" in line:
      lines[i] = line.split("=")[0] + '="' + db_host + '",\n'
   if "database=" in line:
      lines[i] = line.split("=")[0] + '="' + db_database + '",\n'
   if "password=" in line:
      lines[i] = line.split("=")[0] + '="' + db_password + '",\n'
with open("mods/ms/raspberryjammod/ms_mcpipy/database.py", "w") as file:
   for line in lines:
      file.write(line)
  
# block.py
with open("mods/ms/raspberryjammod/mcpipy/mcpi/block.py", "r") as file:
   lines = file.readlines()
for i, line in enumerate(lines):
   if "db_url = " in line:
      lines[i] = line.split(" = ")[0] + ' = db_url_local\n'
with open("mods/ms/raspberryjammod/mcpipy/mcpi/block.py", "w") as file:
   for line in lines:
      file.write(line)
