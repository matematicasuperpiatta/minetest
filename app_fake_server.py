from flask import Flask, render_template
import subprocess
import os

app = Flask(__name__)

@app.route("/")


def index():
   filename = "/home/stemblocks/MS/ms_server/worlds/MATEMATICA_SUPERPIATTA/connected.dat"
   if os.path.exists(filename):
      f=open(filename, "r")
      if ( os.path.getsize(filename) != 0):
         response="user:"+f.read()
      else:
         response="Empty"
   else:
      response="None"
   print("#app_fake_server.py: response", response)
   return (response)

@app.route("/<name>")
def MS_connect(name):
   if (len(name) > 4 and name[:5] == "user:"):
      print("Sto cambiando utente")
      name = name[5:]
      with open("/home/stemblocks/MS/ms_server/worlds/MATEMATICA_SUPERPIATTA/connected.dat", 'w') as file:
         file.write(name)
   if(name=='disconnect'):
      with open("/home/stemblocks/MS/ms_server/worlds/MATEMATICA_SUPERPIATTA/connected.dat", 'w') as file:
         file.write(name)
      subprocess.run("pkill minetest", shell=True)
   return(name)


if __name__ == "__main__":
    app.run(host='0.0.0.0',port=80)

