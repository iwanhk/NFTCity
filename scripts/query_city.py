#!/usr/bin/python
# -*- coding: UTF-8 -*-

import sys
import scripts.city_zone 
    
if __name__=='__main__':
    dic= city_zone.initDataBase()
    city_name, zone, now_time= city_zone.query(sys.argv[1], dic)
    print(f"{city_name=} {zone=} {now_time=}")