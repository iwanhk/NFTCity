#conding=utf8  
import json
import os

DATADIR='data/'

if __name__=="__main__":
    g = os.walk(DATADIR+ "city_meta")

    city_files=[]
    cities=set()
    for path,dir_list,file_list in g:  
        for file_name in file_list:  
            if(file_name[-7:]=='in.json'):
                #print(os.path.join(path, file_name) )
                city_files.append(os.path.join(path, file_name))

    for file in city_files:
        out_file= file.replace('.in.', '.ot.')
        city= file[15:-8]
        cities.add(city)

        with open(out_file, 'r') as f:
            lans= len(json.load(f))
        with open(file, 'r') as f:
            content= json.load(f)
            print(f"{city} {content['zh-tw']} {content['zh-cn']} {lans}个名字")

    print(f"共 {len(cities)} 个城市文件信息")

    g = os.walk(DATADIR+ "svg")
    svgs=set()
    for path,dir_list,file_list in g:  
        for file_name in dir_list:  
            svgs.add(file_name)
    
    g = os.walk(DATADIR+ "gif")
    gifs=set()
    for path,dir_list,file_list in g:  
        for file_name in file_list:  
            if(file_name[-4:]=='.gif'):
                gifs.add(file_name[:-4])
    diff1= cities-svgs
    diff2= svgs- cities
    if len(diff1):
        print(f"Cities-svg {len(diff1)} cities: \n{diff1} ")
    if len(diff2):
        print(f"SVG-Cities {len(diff2)} cities: \n{diff2} ")

    diff1= cities-gifs
    diff2= gifs- cities
    if len(diff1):
        print(f"Cities- gif {len(diff1)} cities: \n{diff1} ")
    if len(diff2):
        print(f"Gif- cities {len(diff2)} cities: \n{diff2} ")