#!/usr/bin/env python
''' Python 3.5 '''

import hashlib, json, os.path, shutil

abs_current = os.path.dirname(os.path.realpath(__file__))

def file_checksum(fp):
    with open(fp, 'rb') as f:
        return hashlib.md5(f.read()).hexdigest()

def main():
    # Get database.
    with open('files.json', 'r') as f:
        db = json.load(f)

    # Iterate database.
    for package in db:
        files = db[package]
        package_dir = os.path.join(abs_current, package)
        
        for fps in files:
            fp_local  = os.path.expanduser(fps['local'])
            fp_remote = os.path.join(package_dir, fps['remote']) 

            cs_local  = file_checksum(fp=fp_local)
            cs_remote = file_checksum(fp=fp_remote)

            if cs_remote != cs_local:
                shutil.copy(src=fp_local, dst=fp_remote)

if __name__ == '__main__':
    main()