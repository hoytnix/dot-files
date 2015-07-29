Dot Files
---------

Weather:

Move `run.py` to /opt/weather/ and add the following line to crontab:

`*/15 * * * * /usr/bin/python3.4 /opt/weather/run.py`

Required for weather to function within Conky.