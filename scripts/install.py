from os import listdir
from os.path import isfile, join, abspath
from subprocess import call

def install():
    bin_dir = '/usr/local/bin/'
    script_dir = abspath('./bin')

    scripts = [f for f in listdir(script_dir) if isfile(join(script_dir, f))]
    for script in scripts:
        script_path = join(script_dir, script)
        bin_path = join(bin_dir, script)

        cmds = ('cp {} {}'.format(script_path, bin_path), 'chmod +x {}'.format(bin_path))
        for cmd in cmds:
            call('sudo {}'.format(cmd), shell=True)

if __name__ == '__main__':
    print('Hey! This script uses sudo, you may want to read what it does!')
    print('Press [Enter] if that\'s OK.')
    input()

    install()
