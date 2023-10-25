# Global Variables
db_beta_url = "https://wiscomsbeta.matematicasuperpiatta.it"
db_release_url = "https://wiscoms.matematicasuperpiatta.it"
class Configurations:
   def __init__(self):
      self.operating_system = ['android',
           ['linux', 'machintosh', 'ios', 'windows', 'android']]
      self.ms_type = ['full',
           ['full', 'acer', 'panel']]
      self.dev_phase = ['release',
           ['beta', 'release']]
      self.server_type = ['ecs',
           ['local', 'multi', 'ecs']]
      self.version = ['1.1.1',
           True]
      self.debug = ['false',
           ['true', 'false']]
      self.monitor = ['false',
           ['true', 'false']]
      self.slack = ['false',
           ['true', 'false']]

# Cambiare solo fino a qui.
      
   def check(self, field):
      return not isinstance(field, list) or not isinstance(field[1], list) or (field[0] in field[1])
      
   def push_operating_system(self):
      if self.check(self.operating_system):
         with open("builtin/ms-mainmenu/oop/handshake.lua", "r") as handshake:
            lines = handshake.readlines()
         for i, line in enumerate(lines):
            if 'operating_system =' in line:
               pre, post = line.split("=")
               lines[i] = pre + '= "' + self.operating_system[0] + '",\n'
         with open("builtin/ms-mainmenu/oop/handshake.lua", "w") as handshake:
            for line in lines:
               handshake.write(line)
         return True
      else:
         return False
   
   def push_ms_type(self):
      if self.check(self.ms_type):
         with open("builtin/ms-mainmenu/oop/handshake.lua", "r") as handshake:
            lines = handshake.readlines()
         for i, line in enumerate(lines):
            if 'ms_type =' in line:
               pre, post = line.split("=")
               lines[i] = pre + '= "' + self.ms_type[0] + '",\n'
         with open("builtin/ms-mainmenu/oop/handshake.lua", "w") as handshake:
            for line in lines:
               handshake.write(line)
         return True
      else:
         return False
   def push_dev_phase(self):
      if self.check(self.dev_phase):
         with open("builtin/ms-mainmenu/oop/handshake.lua", "r") as handshake:
            lines = handshake.readlines()
         for i, line in enumerate(lines):
            if 'dev_phase =' in line:
               pre, post = line.split("=")
               lines[i] = pre + '= "' + self.dev_phase[0] + '",\n'
         with open("builtin/ms-mainmenu/oop/handshake.lua", "w") as handshake:
            for line in lines:
               handshake.write(line)
         with open("builtin/ms-mainmenu/dlg_whoareu.lua", "r") as dlg_whoareu:
            lines = dlg_whoareu.readlines()
         url = db_beta_url if self.dev_phase[0] == "beta" else db_release_url
         for i, line in enumerate(lines):
            if "wiscom/api/" in line:
               pre, post = line.split("https://")
               _, post = post.split("/wiscom/api/")
               post = "/wiscom/api/" + post
               lines[i] = pre + url + post
         with open("builtin/ms-mainmenu/dlg_whoareu.lua", "w") as dlg_whoareu:
            for line in lines:
               dlg_whoareu.write(line)

   def push_server_type(self):
      if self.check(self.server_type):
         with open("builtin/ms-mainmenu/oop/handshake.lua", "r") as handshake:
            lines = handshake.readlines()
         for i, line in enumerate(lines):
            if 'server_type =' in line:
               pre, post = line.split("=")
               lines[i] = pre + '= "' + self.server_type[0] + '",\n'
         with open("builtin/ms-mainmenu/oop/handshake.lua", "w") as handshake:
            for line in lines:
               handshake.write(line)

   def push_version(self):
      if self.check(self.version):
         with open("builtin/ms-mainmenu/oop/handshake.lua", "r") as handshake:
            lines = handshake.readlines()
         for i, line in enumerate(lines):
            if 'version =' in line:
               pre, post = line.split("=")
               lines[i] = pre + '= "' + self.version[0] + '",\n'
         with open("builtin/ms-mainmenu/oop/handshake.lua", "w") as handshake:
            for line in lines:
               handshake.write(line)
         with open("CMakeLists.txt", "r") as cmake:
            lines = cmake.readlines()
         major, minor, patch = self.version[0].split('.')
         for i, line in enumerate(lines):
            if 'set(VERSION_MAJOR ' in line:
               lines[i] = 'set(VERSION_MAJOR ' + major + ')\n'
            if 'set(VERSION_MINOR ' in line:
               lines[i] = 'set(VERSION_MINOR ' + minor + ')\n'
            if 'set(VERSION_PATCH ' in line:
               lines[i] = 'set(VERSION_PATCH ' + patch + ')\n'
         with open("CMakeLists.txt", "w") as cmake:
            for line in lines:
               cmake.write(line)

   def push_debug(self):
      if self.check(self.debug):
         with open("builtin/ms-mainmenu/oop/handshake.lua", "r") as handshake:
            lines = handshake.readlines()
         for i, line in enumerate(lines):
            if 'debug =' in line and not "--" in line:
               pre, post = line.split("=")
               lines[i] = pre + '= "' + self.debug[0] + '",\n'
         with open("builtin/ms-mainmenu/oop/handshake.lua", "w") as handshake:
            for line in lines:
               handshake.write(line)

   def push_monitor(self):
      if self.check(self.monitor):
         with open("builtin/ms-mainmenu/oop/handshake.lua", "r") as handshake:
            lines = handshake.readlines()
         for i, line in enumerate(lines):
            if 'monitor =' in line:
               pre, post = line.split("=")
               lines[i] = pre + '= "' + self.monitor[0] + '",\n'
         with open("builtin/ms-mainmenu/oop/handshake.lua", "w") as handshake:
            for line in lines:
               handshake.write(line)

   def push_slack(self):
      if self.check(self.slack):
         with open("builtin/ms-mainmenu/oop/handshake.lua", "r") as handshake:
            lines = handshake.readlines()
         for i, line in enumerate(lines):
            if 'slack =' in line:
               pre, post = line.split("=")
               lines[i] = pre + '= "' + self.slack[0] + '",\n'
         with open("builtin/ms-mainmenu/oop/handshake.lua", "w") as handshake:
            for line in lines:
               handshake.write(line)
   def push(self):
      self.push_operating_system()
      self.push_ms_type()
      self.push_dev_phase()
      self.push_server_type()
      self.push_version()
      self.push_debug()
      self.push_monitor()
      self.push_slack()
      
      
if __name__ == "__main__":
   configurations = Configurations()
   configurations.push()