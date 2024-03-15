# Global Variables
db_beta_url = "https://wiscomsbeta.matematicasuperpiatta.it"
db_release_url = "https://wiscoms.matematicasuperpiatta.it"
api_release = 'fvqyugucy1.execute-api.eu-south-1.amazonaws.com/release'
api_dev = 'fvqyugucy1.execute-api.eu-south-1.amazonaws.com/dev'


class Configurations:
   def __init__(self):
      self.api = ['release',
                 ('release', 'dev')]
      self.operating_system = ['android',
                              ('linux', 'macintosh', 'ios', 'windows', 'android')]
      self.ms_type = ['full',
                     ('full', 'acer', 'panel')]
      self.dev_phase = ['release',
                       ('beta', 'release')]
      self.server_type = ['ecs',
                         ('local', 'multi', 'ecs')]
      self.version = ['1.1.4',
                      True]
      self.debug = ['false',
                   ('true', 'false')]
      self.monitor = ['false',
                     ('true', 'false')]
      self.slack = ['false',
                   ('true', 'false')]
      self.android_code = ['65',
                      True]
   
   # Cambiare solo fino a qui.
   
   def check(self, field):
      return not isinstance(field, list) or not isinstance(field[1], list) or (field[0] in field[1])
   
   def push_api(self):
      if self.check(self.operating_system):
         with open("minetest.conf", "r") as minetest:
            lines = minetest.readlines()
         for i, line in enumerate(lines):
            if len(line) >= 14 and line[:14] == 'ms_discovery =':
               pre, _ = line.split("=")
               post = api_dev if self.api[0] == "dev" else api_release
               lines[i] = pre + '= ' + post + '\n'
         with open("minetest.conf", "w") as minetest:
            for line in lines:
               minetest.write(line)
         return True
      else:
         return False
   
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
         
         with open("minetest.conf", "r") as conf:
            lines = conf.readlines()
         for i, line in enumerate(lines):
            if 'debug_log_level =' in line:
               dl = 0 if self.operating_system[0] == 'linux' or self.operating_system[0] == 'windows' else 3
               lines[i] = "debug_log_level = " + str(dl) + "\n"
         with open("minetest.conf", "w") as conf:
            for line in lines:
               conf.write(line)
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
         with open("builtin/ms-mainmenu/init.lua", "r") as handshake:
            lines = handshake.readlines()
            n = len(lines)
         with open("minetest.conf", "r") as conf:
            lines += conf.readlines()
         for i, line in enumerate(lines):
            if 'matematicasuperpiatta.it/wiscom' in line:
               pre, post = line.split("/wiscoms")
               if self.dev_phase[0] == "beta":
                  ok = post.startswith("beta")
                  lines[i] = line if ok else pre + "/wiscomsbeta" + post
               elif self.dev_phase[0] == "release":
                  ok = not post.startswith("beta")
                  lines[i] = line if ok else pre + "/wiscoms" + post[4:]
         with open("builtin/ms-mainmenu/init.lua", "w") as handshake:
            for line in lines[:n]:
               handshake.write(line)
         with open("minetest.conf", "w") as conf:
            for line in lines[n:]:
               conf.write(line)
         return True
      else:
         return False
   
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
         return True
      else:
         return False
   
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
         with open("ms-android/build.gradle", "r") as cmake:
            lines = cmake.readlines()
         for i, line in enumerate(lines):
            if 'project.ext.set("versionMajor", ' in line:
               lines[i] = 'project.ext.set("versionMajor", ' + major + ')\n'
            if 'project.ext.set("versionMinor", ' in line:
               lines[i] = 'project.ext.set("versionMinor", ' + minor + ')\n'
            if 'project.ext.set("versionPatch", ' in line:
               lines[i] = 'project.ext.set("versionPatch", ' + patch + ')\n'
         with open("ms-android/build.gradle", "w") as cmake:
            for line in lines:
               cmake.write(line)
         with open("snapcraft.yaml", "r") as snapcraft:
            lines = snapcraft.readlines()
         for i, line in enumerate(lines):
            if "version:" in line:
               lines[i] = "version: " + self.version[0] + "\n"
         with open("snapcraft.yaml", "w") as snapcraft:
            for line in lines:
               snapcraft.write(line)
         return True
      else:
         return False
   
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
         with open("ms-android/build.gradle", "r") as build_gradle:
            lines = build_gradle.readlines()
         for i, line in enumerate(lines):
            if 'project.ext.set("developmentBuild", ' in line:
               lines[i] = 'project.ext.set("developmentBuild", ' + (('1' if self.debug[0] == 'true' else '0') + ')\n')
         with open("ms-android/build.gradle", "w") as build_gradle:
            for line in lines:
               build_gradle.write(line)
         return True
      return False
   
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
         return True
      else:
         return False
   
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
         return True
      else:
         return False

   def push_android_code(self):
      if self.check(self.android_code):
         with open("ms-android/build.gradle", "r") as build_gradle:
            lines = build_gradle.readlines()
         for i, line in enumerate(lines):
            if 'project.ext.set("versionCode", ' in line:
               lines[i] = 'project.ext.set("versionCode", ' + self.android_code[0] + ')\n'
         with open("ms-android/build.gradle", "w") as build_gradle:
            for line in lines:
               build_gradle.write(line)
         return True
      return False
   
   def push(self):
      x = True
      x *= self.push_api()
      x *= self.push_operating_system()
      # x *= self.push_ms_type()
      x *= self.push_dev_phase()
      x *= self.push_server_type()
      x *= self.push_version()
      x *= self.push_debug()
      x *= self.push_monitor()
      x *= self.push_slack()
      x *= self.push_android_code()
      print("Done!" if x else "Error with some setting.")


if __name__ == "__main__":
   configurations = Configurations()
   configurations.push()
