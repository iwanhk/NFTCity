#!/usr/bin/env python
import os
from collections import defaultdict
from datetime import datetime
from urllib.request   import urlretrieve
from urllib.parse import urljoin
from zipfile  import ZipFile
from concurrent.futures import ThreadPoolExecutor

import pytz # pip install pytz

geonames_url = 'http://download.geonames.org/export/dump/'
basename = 'cities15000' # all cities with a population > 15000 or capitals
filename = basename + '.zip'
DATADIR= 'data/'

def initDataBase():
    # get file
    if not os.path.exists(filename):
        urlretrieve(urljoin(geonames_url, filename), filename)

    # parse it
    city2tz = defaultdict(set)
    with ZipFile(filename) as zf, zf.open(basename + '.txt') as file:
        for line in file:
            fields = line.split(b'\t')
            if fields: # geoname table http://download.geonames.org/export/dump/
                name, asciiname, alternatenames = fields[1:4]
                timezone = fields[-2].decode('utf-8').strip()
                if timezone:
                    for city in [name, asciiname] + alternatenames.split(b','):
                        city = city.decode('utf-8').strip()
                        if city:
                            city2tz[city].add(timezone)

    return city2tz

    print("Number of available city names (with aliases): %d" % len(city2tz))

    #
    n = sum((len(timezones) > 1) for city, timezones in iter(city2tz.items()))
    print("")
    print("Find number of ambigious city names\n "
        "(that have more than one associated timezone): %d" % n)

#
def query(city:str, city2tz):
    fmt = '%Y-%m-%d %H:%M:%S %Z%z'
    if not city in city2tz:
        print(f"{city} is not in dic {len(city2tz)}")
        return None, None, None

    for tzname in city2tz[city]:
        now = datetime.now(pytz.timezone(tzname))
        
        #print("")
        #print("%s is in %s timezone" % (city, tzname))
        #print("Current time in %s is %s" % (city, now.strftime(fmt)))
        #print(f"{city} in {tzname}, Now={now.strftime(fmt)}")
        return city, tzname, now.strftime(fmt)

if "__main__"== __name__:
    city2tz= initDataBase()
    
    g = os.walk(DATADIR+ "city_meta")
    cities=[]
    for path,dir_list,file_list in g:  
        for file_name in file_list:  
            if(file_name[-7:]=='ot.json'):
                print(file_name[:-8])
                cities.append(file_name[:-8])

    i=0
    for city in cities:
        city, tzname, time_now= query(city, city2tz)
        if time_now != None:
            print(f"{city} in {tzname}, Now={time_now}")
            i+=1
    print(f"Total {i} cities")
    #with ThreadPoolExecutor() as p:
    #    p.map(query, cities)