##############################################
#       CHOSE SETTINGS AND FOLDERS           #
##############################################
settings = {
   'active_block_range': '6',
   'creative_mode': 'true',
   #'viewing_range': '110',
   'item_entity_ttl': '15',
   'server_unload_unused_data_timeout': '30',
   'max_clearobjects_extra_loaded_blocks': '4096',
   'max_block_send_distance': '6',
   'max_block_generate_distance': '6',
   'max_simultaneous_block_sends_per_client': '16',
   'max_simultaneous_block_sends_server_total': '16',
   'server_map_save_interval': '15'
}
folders = [""]
##############################################
if __name__ == "__main__":
   import subprocess
   filePaths = []
   for folder in folders:
      command = f'find {folder} -name "*.mt"'
      result = subprocess.run(command, shell=True, capture_output=True, text=True)
      pathsMT = result.stdout.split("\n")
      command = f'find {folder} -name "*.conf"'
      result = subprocess.run(command, shell=True, capture_output=True, text=True)
      pathsCONF = result.stdout.split("\n")
      filePaths += [path for path in pathsMT if path] + [path for path in pathsCONF if path]
   
   for filePath in filePaths:
      with open(filePath, "r") as file:
         lines = file.readlines()
      with open(filePath, "w") as file:
         for setting in settings.keys():
            value = settings[setting]
            newLine = setting + " = " + value + '\n'
            ok = False
            for i, line in enumerate(lines):
               if setting in line:
                  lines[i] = newLine
                  ok = True
            if not ok:
               lines.append(newLine)
         txt = ''
         for line in lines:
            txt += line
         file.write(txt)
