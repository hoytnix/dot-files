#!/usr/bin/env python
''' Python 3.5 '''

import hashlib, json, os.path, shutil, subprocess

abs_current = os.path.dirname(os.path.realpath(__file__))

def file_checksum(fp):
    with open(fp, 'rb') as f:
        return hashlib.md5(f.read()).hexdigest()

def file_diffs():
    # Get database.
    with open('files.json', 'r') as f:
        db = json.load(f)

    # UI.
    print('Checking files for differences...\n')

    # Iterate database.
    for package in db:
        files = db[package]
        package_dir = os.path.join(abs_current, package)
        
        for fps in files:
            local  = fps['local']
            remote = fps['remote']

            fp_local  = os.path.expanduser(local)
            fp_remote = os.path.join(package_dir, remote) 

            cs_local  = file_checksum(fp=fp_local)
            cs_remote = file_checksum(fp=fp_remote)

            if cs_remote != cs_local:
                print('Found: {package}/{file}'.format(package=package, file=remote))
                shutil.copy(src=fp_local, dst=fp_remote)

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

    print('\nEnter anything to say yes, otherwise press enter.')
    if input('Push to Git? ') != '':
        msg = input('\nCommit message: ')

        cmd.append('git commit -m "{msg}"'.format(msg=msg))
        cmd.append('git push')
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