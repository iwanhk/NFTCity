import os
from concurrent.futures import ThreadPoolExecutor

cities=[]
DATADIR= 'data/'

def get_cities(dir:tuple)-> None:
    for maindir, subdir, file_name_list in os.walk(dir[0]):
        if(len(subdir)):
            for city in subdir:
                if not os.path.exists(f"{dir[1]}/{city}.gif"):
                    cities.append(f'"{maindir}/{city}/???.*.png" "{dir[1]}/{city}.gif"')

def gen_gif(dir:str)-> None:
    cmd= f'convert -delay 15 -loop 0 {dir}'
    print(cmd)
    os.system(cmd)

def gen_dir(dir:tuple)->None:
    get_cities(dir)
    with ThreadPoolExecutor() as p:
        p.map(gen_gif, cities)

if __name__ == "__main__":
    gen_dir((DATADIR+ 'png', DATADIR+ 'gif'))