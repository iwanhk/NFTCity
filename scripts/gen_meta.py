#!/usr/bin/python
# -*- coding: iso-8859-1 -*-

import googletrans
import json
from tqdm import tqdm
import os, sys
from concurrent.futures import ThreadPoolExecutor

cities={}
DATADIR='data/'

def trans(city:str) ->None:
    if os.path.exists(DATADIR+ "city_meta/"+ city+'.in.json') and os.path.exists(DATADIR+ "city_meta/"+ city+'.ot.json'):
        return
    translator= googletrans.Translator()
    in_dict= {}
    out_dict={}

    with tqdm(total=len(googletrans.LANGUAGES)) as pbar:
        for lan in googletrans.LANGUAGES:
            ret= translator.translate(city, dest=lan).text
            if(ret[-1]=='.'):
                ret= ret[:-1] # 把多余的结尾的点去掉
            if(ret[-1]=='。'):
                ret= ret[:-1] # 把多余的结尾的点去掉
            out_dict[ret]= None
            in_dict[lan]= ret
            #print(ret)
            pbar.set_description(city+'='+ret)
            pbar.update(1)

    out_json = json.dumps(out_dict)
    in_json= json.dumps(in_dict)

    with open(DATADIR+ "city_meta/"+ in_dict['en']+'.in.json', 'w') as f:
        f.write(in_json)
    with open(DATADIR+ "city_meta/"+ in_dict['en']+'.ot.json', 'w') as f:
        f.write(out_json) 

if __name__== "__main__":

    with open(DATADIR+ 'cities.txt', 'r') as f:
        line= f.readline()
        while(line):
            city= line.replace('\n', '')
            cities[city]=None
            line= f.readline()

    #with ThreadPoolExecutor() as p:
    #    p.map(trans, list(cities.keys()))
    trans('Tianjin')