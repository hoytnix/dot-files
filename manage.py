#!/usr/bin/env python
''' Python 3.5 '''

import hashlib, json, os, shutil, subprocess

abs_current = os.path.dirname(os.path.realpath(__file__))

def file_checksum(fp):
    try:
        with open(fp, 'rb') as f:
            return hashlib.md5(f.read()).hexdigest()
    except: # File does not exist yet.
        return ""

def file_diffs():
    # Get database.
    with open('packages.json', 'r') as f:
        db = json.load(f)

    # UI.
    print('Checking files for differences...\n')

    # Iterate database.
    for package_name in db:
        # Package variables.
        package_dir = os.path.join(abs_current, package_name)
        package = db[package_name]
        
        # Recursive (lazy) package searching.
        if type(package) == str:
            package = os.path.expanduser(package)
            for dirpath, dirnames, filenames in os.walk(package):
                for filename in filenames:
                    fp_local  = os.path.join(package, filename)
                    fp_remote = os.path.join(package_dir, filename)

                    cs_local  = file_checksum(fp=fp_local)
                    cs_remote = file_checksum(fp=fp_remote)

                    if cs_remote != cs_local:
                        print('Found: {package}/{file}'.format(package=package_name, file=fp_remote))
                        shutil.copyfile(src=fp_local, dst=fp_remote)

        # Manual package searching.
        if type(package) == list:
            for fp in package:
                fn_local  = fp['local']
                fn_remote = fp['remote']

                fp_local  = os.path.expanduser(fn_local)
                fp_remote = os.path.join(package_dir, fn_remote) 

                cs_local  = file_checksum(fp=fp_local)
                cs_remote = file_checksum(fp=fp_remote)

                if cs_remote != cs_local:
                    print('Found: {package}/{file}'.format(package=package_name, file=remote))
                    shutil.copyfile(src=fp_local, dst=fp_remote)

def exec_me(args):
    i = 0
    cmd = ''
    for arg in args:
        cmd += arg
        i += 1
        if i != args.__len__():
            cmd += ' && '
    subprocess.call(cmd, shell=True)

def update_pkglist():
    cmd = []
    cmd.append('cd {dir}'.format(dir=abs_current))
    cmd.append('pacman -Qqen > pkglist.txt')
    exec_me(cmd)

def git_push():
    print('\n') # Hack.
        
    cmd = []
    cmd.append('cd {dir}'.format(dir=abs_current))
    cmd.append('git add -A')
    cmd.append('git status')
    exec_me(cmd)

    cmd = []
    print('\nEnter anything to say yes, otherwise press enter.')
    answer = input('Push to Git? ') 
    if answer != '' and answer.lower() != 'n':
        msg = input('\nCommit message: ')

        cmd.append('git commit -m "{msg}"'.format(msg=msg))
        cmd.append('git push')
    else:
        cmd.append('git reset HEAD')
    exec_me(cmd)

def main():
    # 1. Check files for differences.
    file_diffs()

    # 2. Update package list.
    update_pkglist()

    # 3. Push to git.
    git_push()

if __name__ == '__main__':
    main()
    print('\nGoodbye.')