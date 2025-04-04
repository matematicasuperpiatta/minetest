from dotenv import load_dotenv
import os
import re

# Carica le variabili dal file .env
load_dotenv(dotenv_path="./config.env")

# Usa le variabili
database_version = os.getenv('database_version')

def replace(file_path, old_text, new_text):
   with open(file_path, 'r', encoding='utf-8') as file:
      content = file.read()
   new_content, num_subs = re.subn(re.escape(old_text), new_text, content)
   with open(file_path, 'w', encoding='utf-8') as file:
      file.write(new_content)
   return num_subs

def try_except_configure(file_path):
   try:
      if "MTUser.py" in file_path:
         if database_version == "local":
            replace(file_path, "wiscom_local = False", "wiscom_local = True")
         else:
            replace(file_path, "wiscom_local = True", "wiscom_local = False")
         new_text = "self._base_url = db_url_" + database_version
         replace(file_path, "self._base_url = db_url_release", new_text)
         replace(file_path, "self._base_url = db_url_beta", new_text)
         replace(file_path, "self._base_url = db_url_local", new_text)
      elif "block.py" in file_path:
         new_text = "db_url = db_url_" + database_version
         replace(file_path, "db_url = db_url_release", new_text)
         replace(file_path, "db_url = db_url_beta", new_text)
         replace(file_path, "db_url = db_url_local", new_text)
      elif "database.py" in file_path:
         if database_version == "release":
            new_host = 'host="matematicasuperpiatta.c4fny1oxnyug.eu-south-1.rds.amazonaws.com"'
            new_database = 'database="wiscom_last"'
            new_password = 'password="93ucno9707nc409137nc0917ncp9qnep9u9pqu3enq9p3uenq3qq"'
         elif database_version == "beta":
            new_host = 'host="127.0.0.1"'
            new_database = 'database="database_local"'
            new_password = 'password="admin"'
            
            
      print(f"Setted database version ({database_version}) in {file_path}")
   except Exception as e:
      print(f"Error during setting database version ({database_version}) in {file_path}.\n{e}")

if __name__ == "__main__":
   '''if not database_version in ["release", "beta", "local"]:
      raise ValueError(f"Database version stored in config.env is not valid: {database_version}")
   try_except_configure(file_path="mods/ms/raspberryjammod/ms_mcpipy/MTUser.py")
   try_except_configure(file_path="mods/ms/raspberryjammod/mcpipy/mcpi/block.py")
   try_except_configure(file_path="mods/ms/raspberryjammod/ms_mcpipy/database.py")'''