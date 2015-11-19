Dot Files
=========


Usage:
------

1) `apt-get` lines are followed by an empty new-line to prevent the install from aborting.
2) Lines requiring some form of user-input are preceded with a `$`. For example, the text to paste to the cronjob editor so it won't be accidentally copy-pasted on setup; and `chown me ...` because the user needs to change `me` to their own username.
3) Everything is expected to be run as super-user. (It's the first line.)
4) Everything is copy-pastable unless otherwise noted.

Setup should only take a few minutes aside from download times, enjoy!



Admin:
------

    su
    
    wget https://github.com/pr0xmeh/dot/releases/download/v1.0/dot-1.0.0.tar.gz
    tar -zxvf dot-1.0.0.tar.gz
    cd dot

    # Build tools
    apt-get install cmake autoconf automake libtool pkg-config

Sudo:

    apt-get install sudo

    visudo

Openbox:
    
    apt-get install openbox

    cp -r openbox ~/.config
    cp ./debian/usr/bin/cb-aerosnap /usr/bin
    cp ./debian/usr/bin/ob-exit /usr/bin
    chmod +x /usr/bin/cb-aerosnap
    chmod +x /usr/bin/ob-exit

Tint2:
    
    apt-get install tint2

    cp -r tint2 ~/.config
    cp ./debian/usr/bin/tint2restart /usr/bin
    chmod +x /usr/bin/tint2restart

Conky:
    
    # Install.
    apt-get install conky

    # Configure.
    cp ./conky/conkyrc ~/.conkyrc

    # Weather.
    mkdir /opt/weather
    $ chown me /opt/weather
    cp ./debian/opt/weather/run.py /opt/weather

    # Cronjob.
    crontab -e
    
    $ */15 * * * * /usr/bin/python3.4 /opt/weather/run.py

Desktop:

    apt-get install arandr nitrogen compton

Audio:
    
    # Sound control.
    apt-get install pavucontrol

    
    # pnmixer - install dependencies;
    apt-get install glib2.0 intltool libx11-dev libasound2-dev libgtk-3-dev

    # download;
    wget https://github.com/nicklan/pnmixer/releases/download/v0.6/pnmixer-0.6.1.tar.gz
    tar -zxvf pnmixer-0.6.1.tar.gz
    
    # install;
    cd pnmixer-0.6.1
    ./autogen.sh
    make
    make install

    # clean up.
    cd ../
    rm -R pnmixer-0.6.1
    rm pnmixer-0.6.1.tar.gz


Utilities:
----------

Networking:

    apt-get install openssh-server git filezilla deluge rsync slurm 

File system:

    apt-get install thunar file-roller ncdu secure-delete

Desktop:

    apt-get install htop terminator xdotool wmctrl shutter


Media:
------

    apt-get install mcomix gimp

Audio:

    apt-get install audacity lmms soundconverter kid3

Video:

    apt-get install blender kazam handbrake smplayer

DVD:

    apt-get install devede xfburn asunder

youtube-dl:

Get download instructions from the [official webpage](https://rg3.github.io/youtube-dl/download.html), there isn't a reliable way to download the latest version.



Development:
============

Python:
-------

Py3k:

    apt-get install python3.4 python3-dev python3-setuptools

Images: 

    apt-get install libjpeg-dev zlib1g-dev libtiff5-dev libfreetype6-dev liblcms2-dev libwebp-dev tcl8.5-dev tk8.5-dev python3-tk


Node:
-----

    apt-get install npm

Packages:

    npm install -g coffee-script
    npm install -g node-sass



Openbox Commands:
=================

`Super+Space`: Openbox menu.

`PrtSc`: Screenshot.

`Super+DirectionalKey`: Resize window.

`Super+Alt+Left/Right`: Aerosnap.