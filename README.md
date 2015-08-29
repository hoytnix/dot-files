Dot Files
---------

## Install:

su
apt-get install openbox 
apt-get install conky nitrogen tint2 arandr
apt-get install gmrun terminator git 

## Configuration:

Weather:

Move `run.py` to /opt/weather/ and add the following line to crontab:

`*/15 * * * * /usr/bin/python3.4 /opt/weather/run.py`

Required for weather to function within Conky.