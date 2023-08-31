-- INSTALL LIBRARIES --
LINUX
	sudo apt-get update
	sudo apt-get install lua5.1 luarocks -y
	sudo luarocks install luasocket
	sudo apt-get install git lsof python3-pip -y
	pip3 install jsonpickle sympy sockets requests tabulate openpyxl
	sudo apt-get install build-essential libirrlicht-dev cmake libbz2-dev libpng-dev libjpeg-dev
	libxxf86vm-dev libgl1-mesa-dev libsqlite3-dev libogg-dev libvorbis-dev libopenal-dev

WINDOWS
	follow instruction from
	https://github.com/minetest/minetest/blob/master/doc/compiling/windows.md

-- CREATE FOLDER --
CLIENT
	git clone https://github.com/matematicasuperpiatta/minetest.git ms_client
	cd ms-client
	git checkout feature-ticket
	cd lib/
	git clone https://github.com/minetest/irrlicht.git irrlichtmt
	cd irrlichtmt/
	git checkout 1.9.0mt8
	cd ../../
SERVER
	git clone https://github.com/matematicasuperpiatta/minetest.git ms_server
	cd ms-server
	git checkout develop
	cp minetest.conf.ms minetest.conf
	cd lib/
	git clone https://github.com/minetest/irrlicht.git irrlichtmt/
	cd irrlichtmt/
	git checkout 1.9.0mt8
	cd ../../
	cd mods/
	git clone https://gitlab.com/leonardoguidoni/ms-shared.git ms/
	cd ms/raspberryjammod/
	git checkout develop
	git clone https://gitlab.com/stemblocks/ms-mcpipy.git ms_mcpipy/
	cd ms_mcpipy/
	git checkout develop
	mkdir ../../../../worlds
	cp -r MATEMATICA_SUPERPIATTA ../../../../worlds
	../../../../


-- COMPILING --
SERVER (only linux)
	-- from ms_server folder --
	cmake . -DRUN_IN_PLACE=TRUE -DBUILD_SERVER=TRUE -DBUILD_CLIENT=FALSE
	make -j 1
CLIENT
	LINUX
	-- from ms_client folder --
	cmake . -DRUN_IN_PLACE=TRUE -DBUILD_SERVER=FALSE -DBUILD_CLIENT=TRUE
	make -j 1

	WINDOWS
	follow instruction from
	https://github.com/minetest/minetest/blob/master/doc/compiling/windows.md
	(You must choose the modality Debug / Release both from CMake and Visual Studio steps)

	ANDROID (from LINUX computer)
	download and install Android Studio
	-- from ms_client folder --
	extract content of
		https://drive.google.com/file/d/1D0xQlCgf9DXSiY64HLT2q6ReCVpZfC2c/view?usp=drive_link
	in ms-android/native/deps

	from Android Studio
	>File>Open and select ms_client/ms-android
	>Build/Build bundle(s) / APK(s)>Build APK(s)

	-- If you want make a release for App Store --
	in ms-android/build.gradle change raw
		project.ext.set("versionCode", 53)
	with a valid versionCode
	>Build>Generate signed boundle or APK
	choice Android App Boundle
	insert valid credentials*
	chose 'release'

	*Is a .jks file. When you obtain one, is common to save in .ssh folder

