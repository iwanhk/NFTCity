#!/usr/bin/python
# -*- coding: iso-8859-1 -*-

import json
import os
import sys

def modify(file:str)->None:
    with open(file, 'r') as f:
        in_dict= json.load(f)

    out_dict={}
    for i in in_dict.values():
        out_dict[i]=None

    with open(file.replace('.in.', '.ot.'), 'w') as f:
        f.write(json.dumps(out_dict)) 

if __name__== "__main__":
    file= sys.argv[1]

    if not os.path.exists(file):
        print(f"{file} not exist")
        exit()
    print(f"Modify meta file {file}")
    modify(file)