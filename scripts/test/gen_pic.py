#conding=utf8  
import svgwrite
import random
import json
import os
from concurrent.futures import ThreadPoolExecutor
import colorsys

def get_colors(degree:int):
    # degree: 1-100 mean dark to bright
    bg_color= svgwrite.rgb(degree*255/100, degree*255/100, degree*255/100)
    r,g,b= colorsys.hls_to_rgb(random.randrange(361)/360, 1-degree/99, 1)
    fg_color= svgwrite.rgb(r*255, g*255, b*255)

    return (bg_color, fg_color)

def is_overlap(pointA:tuple, pointB:tuple)-> bool:
    #point tuple (a, b, x, y)
    # a,b position
    # x,y width, height
    A1=pointA[0]
    A2=pointA[1]
    A3=pointA[0]+pointA[2]
    A4=pointA[1]+pointA[3]

    B1=pointB[0]
    B2=pointB[1]
    B3=pointB[0]+pointB[2]
    B4=pointB[1]+pointB[3]

    overlap= not (A3 <= B1 or B3 <= A1) and not (A4 <= B2 or B4 <= A2)

    if overlap:
       print(f"{pointA} X {pointB} overlaped")

    return overlap



def _text(dwg, txt:str, x_pos:int, y_pos:int, size:int, weight:str, font:str, degree) -> None:
    fg_color= get_colors(degree)[1]
    dwg.add(dwg.text(txt,
        insert=(x_pos,y_pos),
        stroke='none',
        fill=fg_color,
        font_size=str(size)+'px',
        font_weight=weight,
        font_family=font)
    )
    

def text(dwg, txt:str, x:int, y:int, size:int, degree) -> None:
    new_size= random.randrange(int(size*0.5), int(size*2.5))
    _text(dwg, txt, x, y, new_size, "lighter", "Courier", degree)

def text_main(dwg, txt:str, degree) -> None:
    size= 500//(len(txt)+1)
    x= 500- len(txt)*size
    if(x<0):
        print(f"{txt} * {size} bigger than 500, abort!")
        return False
    if(x==0):
        x_pos=0
    else:
        x_pos= random.randrange(x)
    y_pos= random.randrange(size, 500)

    _text(dwg, txt, x_pos, y_pos, size, "bold", "Courier", degree)

def gen_pic(svg_file:str,  meta_dict:dict, lan_dict:dict, degree:int, main_lan:str= 'zh-cn')->None:
    dwg = svgwrite.Drawing(svg_file, size = ("500px", "500px"), profile='tiny')
    bg_color= get_colors(degree)[0]
    #print(f"{bg_color=} {fg_color=}")
    dwg.add(dwg.rect((0, 0), (500, 500), fill=bg_color))
    text_main(dwg, lan_dict[main_lan], degree)

    # 下面，我们均匀分布这批城市，按照总数1:9的比例
    total_cities= len(meta_dict.keys())
    rows= total_cities//10
    lines = 10
    height= 500//lines
    width= 500//rows
    #print(f"{total_cities=} {rows=} {lines=} {height=} {width=}")
    # x= (id % total//10) * 500*10/total + random.randrange(30)
    # y= (id *10 / total) * 50 + 500/total + Random.randrange(30)
    id=0
    for city in meta_dict.keys():
        x= (id % rows) *width+ random.randrange(30)
        y= (id // rows) * height+ 50/rows+ random.randrange(30)
        id+=1
        text(dwg, city, x, y, 50/rows, degree)

    dwg.save()

def gen_group(meta_file:str)->None:
    with open(meta_file,'r') as load_f:
        meta_dict = json.load(load_f)

    with open(meta_file[:-7]+'in.json','r') as load_f:
        lan_dict = json.load(load_f)

    id=0
    total_lans= len(lan_dict.keys())

    group_dir=  meta_file[:-8].replace('city_meta', 'city_pic')
    if not os.path.exists(group_dir):
        os.mkdir(group_dir)

    for lan in lan_dict.keys():
        svg_file=group_dir+'/'+str(id).zfill(3)+ '.'+ lan+ '.svg'
        #print(svg_file)
        degree= int(99/total_lans*id)
        #print(f"{svg_file=} {lan=}")
        gen_pic(svg_file, meta_dict, lan_dict, degree, lan)
        id+=1


if __name__=="__main__":
    g = os.walk(r"city_meta")

    cities=[]
    for path,dir_list,file_list in g:  
        for file_name in file_list:  
            if(file_name[-7:]=='ot.json'):
                print(os.path.join(path, file_name) )
                cities.append(os.path.join(path, file_name))

    #gen_group("city_meta/test.ot.json")
    with ThreadPoolExecutor() as p:
        p.map(gen_group, cities)