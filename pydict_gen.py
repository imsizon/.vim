#!/usr/bin/python
# -*- coding: UTF-8 -*-
'''
Build dictionary for python modules
@version: 1.0
@author: U{imsizon <xich@imsizon.com>}
@license: LGPL
'''

import os, sys

def listSubDir(path):
    if(os.path.isdir(path)):
        return [subdir for subdir in os.listdir(path) if os.path.isdir(os.path.join(path, subdir)) and subdir != "EGG-INFO"]
    else:
        return []

def genPydictForModule(module):
    os.chdir(os.path.expanduser("~/.vim/bundle/Pydiction"))
    os.system("python pydiction.py %s" %(module))

def listPyModule(par_path, module_prefix):
    subs = listSubDir(par_path)
    if(not subs):
        return []
    modules = []
    for sub in subs:
        modules.append("%s%s" %(module_prefix, sub))
        if(os.path.isdir(os.path.join(par_path, sub))):
            modules.extend(listPyModule(os.path.join(par_path, sub), "%s%s." %(module_prefix, sub)))
    return modules

def main():
    if sys.version_info[0:2] < (2, 3):
        sys.exit("You need a Python 2.x version of at least Python 2.3")

    if len(sys.argv) <= 1:
        sys.exit("%s requires at least one argument. None given." % sys.argv[0])

    if(not os.path.isdir(sys.argv[1])):
        sys.exit("%s is not a dir" %(sys.argv[1]))

    libs = listSubDir(sys.argv[1])
    if(libs):
        for lib in libs:
            modules = listPyModule(os.path.join(sys.argv[1], lib), '')
            if(modules):
                for module in modules:
                    print module
                    genPydictForModule(module)

if __name__=="__main__":
    main()
