#!/usr/bin/env python3

from selenium import webdriver
import sys
import os
import cv2
import numpy as np

def svg2png(driver, svg_file:str, png_file:str)->None:
    driver.get("file:///" + os.path.join(os.getcwd(),svg_file))
    png = driver.get_screenshot_as_png()
    nparr = np.frombuffer(png, np.uint8)
    img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
    im= img[0:1000, 0:1000]
    cv2.imwrite(png_file, im)

def walk_dir(svg_dir:str, png_dir:str)->None:
    options = webdriver.ChromeOptions()
    options.add_argument("disable-gpu")
    options.add_argument("disable-infobars")

    driver = webdriver.Chrome(options=options)

    g = os.walk(svg_dir)

    for path,dir_list,file_list in g:  
        for file_name in file_list:  
            if(file_name[-4:]=='.svg'):
                #print(os.path.join(path, file_name) )
                png_path= path.replace(svg_dir, png_dir)
                if not os.path.exists(png_path):
                    os.makedirs(png_path)
                svg= os.path.join(path, file_name)
                png= os.path.join(png_path, file_name.replace('.svg', '.png'))
                print(f"Converting {svg} to {png}")
                if not os.path.exists(png):
                    svg2png(driver, svg, png)

    driver.quit()

if __name__=='__main__':
    walk_dir(sys.argv[1], sys.argv[2])