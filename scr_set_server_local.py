'''
ATTENTION:  currently a reverse script to return to a remote server does not exist! Use carrefully.
'''

wiscom_local_address = "127.0.0.1:8000/wiscom"
db_database = "wiscom_local"
db_host = "127.0.0.1"
db_password = "admin"


########################################################################################################################

with open("mods/ms/ms_connect/init.lua", "r") as file:
   lines = file.readlines()
for i, line in enumerate(lines):
   if "matematicasuperpiatta.it/wiscom" in line:
      lines[i] = line.split(" = ")[0] + ' = "' + wiscom_local_address + '/api/",\n'
with open("mods/ms/ms_connect/init.lua", "w") as file:
   for line in lines:
      file.write(line)
      
with open("mods/ms/raspberryjammod/ms_mcpipy/MTUser.py", "r") as file:
   lines = file.readlines()
for i, line in enumerate(lines):
   if "wiscom_local = " in line:
      lines[i] = line.split(" = ")[0] + ' = True\n'
with open("mods/ms/raspberryjammod/ms_mcpipy/MTUser.py", "w") as file:
   for line in lines:
      file.write(line)

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
      
      
