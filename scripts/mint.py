from brownie import CivCityNFT, Random, DateTime, SVG, accounts, network, config
from scripts.tools import *
import json
import os,sys
import random
from scripts.city_zone import *

D18= 10**18
ZERO= '0x0000000000000000000000000000000000000000'
active_network= network.show_active()
LANG=["af", "sq", "am", "ar", "hy", "az", "eu", "be", "bn", "bs", "bg", "ca", "ceb", "ny", "zh-cn", "zh-tw", "co", "hr", "cs", "da", "nl", "en", "eo", "et", "tl", "fi", "fr", "fy", "gl", "ka", "de", "el", "gu", "ht", "ha", "haw", "iw", "he", "hi", "hmn", "hu", "is", "ig", "id", "ga", "it", "ja", "jw", "kn", "kk", "km", "ko", "ku", "ky", "lo", "la", "lv", "lt", "lb", "mk", "mg", "ms", "ml", "mt", "mi", "mr", "mn", "my", "ne", "no", "or", "ps", "fa", "pl", "pt", "pa", "ro", "ru", "sm", "gd", "sr", "st", "sn", "sd", "si", "sk", "sl", "so", "es", "su", "sw", "sv", "tg", "ta", "te", "th", "tr", "uk", "ur", "ug", "uz", "vi", "cy", "xh", "yi", "yo", "zu"];
ipfs='https://bafybeie3mhgs5mf236vwkdehwyrnvmmo5shezlpir7pdioccuqt6euxtum.ipfs.nftstorage.link/'

DATADIR='data/'

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

def mint(city, cityDict, nft, reveal, user):
    with open(DATADIR+ 'deployed.json', 'r') as deployed_file:
        history= json.load(deployed_file)
    if city in history:
        print(f"{city} in history, pass")
        return
    file_name=os.path.join(DATADIR+ "city_meta", city+'.ot.json')
    names_list, lan_list= process_city(file_name)
    city_name, zone, now_time= query(city, cityDict)
    if now_time==None:
        print(f"{city} cannot be found in cityZone, pass")
        return
    #print(f"{now_time=}")

    zoneDiff=int(now_time[-4:-2])*60+ int(now_time[-2:])
    if now_time[-5]=='-':
        zoneDiff= -zoneDiff
    print(f"Minting NFT {city} ...")
    nft.mint(names_list, zoneDiff, lan_list, reveal, addr(user))
    history[city]= nft.totalSupply()
    with open(DATADIR+ 'deployed.json', 'w') as deployed_file:
        json.dump(history, deployed_file)
        

def main():
    active_network= network.show_active()
    print("Current Network:"+ active_network)

    cityDict= initDataBase()

    g = os.walk(DATADIR+ "city_meta")

    cities=[]
    for path,dir_list,file_list in g:  
        for file_name in file_list:  
            if(file_name[-7:]=='ot.json'):
                #print(os.path.join(path, file_name) )
                cities.append(file_name[:-8])
    print(f"Total {len(cities)} city NFT to be minted")
    try:
        if active_network== 'bsc-test' or active_network== 'rinkeby' :
            accounts.add(config['wallets']['admin'])
            accounts.add(config['wallets']['creator'])
            accounts.add(config['wallets']['consumer'])

            admin= accounts[0]
            creator= accounts[1]
            consumer= accounts[2]

            balance_alert(admin, "admin")
            balance_alert(creator, "creator")
            balance_alert(consumer, "consumer")

            if len(Random)==0:
                Random.deploy(addr(admin))
            if len(SVG)==0:
                SVG.deploy(addr(admin))
            if len(DateTime)==0:
                DateTime.deploy(addr(admin))
            nft= CivCityNFT[-1]

            for city in cities:
                mint(city, cityDict, nft, True, admin)

            #mint(cities[0], cityDict, nft, True, admin)
        
            nft.setIPFSPrefix(ipfs, addr(admin))
            
        if active_network == 'bsc-main':
            accounts.add(config['wallets']['admin'])
            accounts.add(config['wallets']['creator'])
            accounts.add(config['wallets']['consumer'])

            admin= accounts[0]
            creator= accounts[1]
            consumer= accounts[2]

    except Exception:
        console.print_exception()
        # Test net contract address

if __name__=="__main__":
    main()