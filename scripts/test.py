from brownie import CivCityNFT, Random, accounts, network, config
from scripts.tools import *
import json
import os

D18= 10**18
ZERO= '0x0000000000000000000000000000000000000000'
active_network= network.show_active()

def process_city(meta_file:str):
    with open(meta_file,'r') as load_f:
        meta_dict = json.load(load_f)

    with open(meta_file[:-7]+'in.json','r') as load_f:
        lan_dict = json.load(load_f)

    names_list= list(meta_dict.keys())
    lan_list=[]
    for lan in lan_dict.keys():
        lan_list.append(names_list.index(lan_dict[lan]))

    print(f"{names_list=} \n{lan_list=}")
    return (names_list, lan_list)


def main():
    active_network= network.show_active()
    print("Current Network:"+ active_network)

    g = os.walk(r"../python/city_meta")

    cities=[]
    for path,dir_list,file_list in g:  
        for file_name in file_list:  
            if(file_name[-7:]=='ot.json'):
                #print(os.path.join(path, file_name) )
                cities.append(os.path.join(path, file_name))
    
    try:
        if active_network == 'development' :
            admin=accounts[0]
            creator=accounts[1]
            consumer=accounts[2]

            random= Random.deploy(addr(admin))
            nft= CivCityNFT.deploy(addr(admin))
            names_list, lan_list= process_city("../python/city_meta/test.ot.json")
            nft.mint(names_list, sum(map(len,names_list)), lan_list, addr(admin))
            nft.reveal(addr(admin))
            #with ThreadPoolExecutor() as p:
            #    p.map(gen_group, cities)

        if active_network== 'mainnet-fork':
            admin=accounts[0]
            creator=accounts[1]
            consumer=accounts[2]

            balance_alert(admin, "admin")
            balance_alert(creator, "creator")
            balance_alert(consumer, "consumer")

            process_city("city_meta/test.ot.json")
            #with ThreadPoolExecutor() as p:
            #    p.map(gen_group, cities)



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

            process_city("city_meta/test.ot.json")
            #with ThreadPoolExecutor() as p:
            #    p.map(gen_group, cities)


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