Dot Files
=========


Usage:
------

1) `apt-get` lines are followed by an empty new-line to prevent the install from aborting.
2) Lines requiring some form of user-input are preceded with a `$`. For example, the text to paste to the cronjob editor so it won't be accidentally copy-pasted on setup; and `chown me ...` because the user needs to change `me` to their own username.
3) Everything is expected to be run as super-user. (It's the first line.)
4) Everything is copy-pastable unless otherwise noted.

Setup should only take a few minutes aside from download times, enjoy!


Package Installation:
=====================

(Now 441% less characters thanks to [Arch Linux](https://archlinux.org)!)

`pacman -S $(< pkglist.txt)`



Openbox Commands:
=================

`Super+Space`: Openbox menu.

`PrtSc`: Screenshot.

`Super+DirectionalKey`: Resize window.

`Super+Alt+Left/Right`: Aerosnap.