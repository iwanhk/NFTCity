import os,sys
import json
import city_zone

DATADIR= 'data/'

def process_city(meta_file:str):
    with open(meta_file,'r') as load_f:
        meta_dict = json.load(load_f)

    with open(meta_file[:-7]+'in.json','r') as load_f:
        lan_dict = json.load(load_f)

    names_list= list(meta_dict.keys())
    lan_list=[]
    for lan in lan_dict.keys():
        lan_list.append(names_list.index(lan_dict[lan]))

    #print(f"{names_list=} \n{lan_list=}")
    return (names_list, lan_list)

def try_city(city, cityDict):
    file_name=os.path.join(DATADIR+ "city_meta", city+'.ot.json')
    names_list, lan_list= process_city(file_name)
    city_name, zone, now_time= city_zone.query(city, cityDict)
    if now_time==None:
        print(f"{city} cannot be found in cityZone, pass")

if __name__=="__main__":
    cityDict= city_zone.initDataBase()

    g = os.walk(DATADIR+ "city_meta")

    cities=[]
    for path,dir_list,file_list in g:  
        for file_name in file_list:  
            if(file_name[-7:]=='ot.json'):
                #print(os.path.join(path, file_name) )
                cities.append(file_name[:-8])
    
    for city in cities:
        try_city(city, cityDict)