from brownie import CivCityNFT, Random, DateTime, SVG, accounts, network, config
from scripts.tools import *
import json
import os,sys
import random
import scripts.city_zone as city_zone

D18= 10**18
DATADIR='data/'

active_network= network.show_active()
LANG=["af", "sq", "am", "ar", "hy", "az", "eu", "be", "bn", "bs", "bg", "ca", "ceb", "ny", "zh-cn", "zh-tw", "co", "hr", "cs", "da", "nl", "en", "eo", "et", "tl", "fi", "fr", "fy", "gl", "ka", "de", "el", "gu", "ht", "ha", "haw", "iw", "he", "hi", "hmn", "hu", "is", "ig", "id", "ga", "it", "ja", "jw", "kn", "kk", "km", "ko", "ku", "ky", "lo", "la", "lv", "lt", "lb", "mk", "mg", "ms", "ml", "mt", "mi", "mr", "mn", "my", "ne", "no", "or", "ps", "fa", "pl", "pt", "pa", "ro", "ru", "sm", "gd", "sr", "st", "sn", "sd", "si", "sk", "sl", "so", "es", "su", "sw", "sv", "tg", "ta", "te", "th", "tr", "uk", "ur", "ug", "uz", "vi", "cy", "xh", "yi", "yo", "zu"];
ipfs='https://bafybeie3mhgs5mf236vwkdehwyrnvmmo5shezlpir7pdioccuqt6euxtum.ipfs.nftstorage.link/'
proof={'0x7B0dc23E87febF1D053E7Df9aF4cce30F21fAe9C': ['0x248ac1f01201ebad7020ea2c3e1b2fdf454040932298e8947f9ffb61e8de51a2','0x91a8ee7c5b8062ff383207a299bf57fda043b5785fd32b35fe1a757a9c52abbf'],
        '0x8531fEaAcD66599102adf9C5f701E6C490f44f1C': ['0x869e65de98ffe6d41241bd4a4149d7152f7ecbe9627441c85862fdeffaa7b05a','0x91a8ee7c5b8062ff383207a299bf57fda043b5785fd32b35fe1a757a9c52abbf'],
        '0xAb1fdD3F84b2019BEF47939E66fb6194532f9640': ['0xc6fa5ccdc8ab39e4d4daca36f8694c30d4bd3c67febddf13d0f8083d1d24c504']
}

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

def _get_meta(city, cityDict) -> tuple:
    with open(DATADIR+ 'deployed.json', 'r') as deployed_file:
        history= json.load(deployed_file)
    if city in history:
        print(f"{city} in history, pass")
        return (None, None, None)

    file_name=os.path.join(DATADIR+ "city_meta", city+'.ot.json')
    names_list, lan_list= process_city(file_name)
    city_name, zone, now_time= city_zone.query(city, cityDict)
    if now_time==None:
        print(f"{city} cannot be found in cityZone, pass")
        return (None, None, None)
    #print(f"{now_time=}")

    zoneDiff=int(now_time[-4:-2])*60+ int(now_time[-2:])
    if now_time[-5]=='-':
        zoneDiff= -zoneDiff

    return (names_list, zoneDiff, lan_list)

def _after_mint_record(city, nft):
    with open(DATADIR+ 'deployed.json', 'r') as deployed_file:
        history= json.load(deployed_file)

    history[city]= nft.totalSupply()
    with open(DATADIR+ 'deployed.json', 'w') as deployed_file:
        json.dump(history, deployed_file)

def whitelist_mint(city, cityDict, nft, user):
    names_list, zoneDiff, lan_list= _get_meta(city, cityDict)
    if names_list==None:
        return

    print(f"Minting NFT {city} ...")
    nft.whitelistMint(user, proof[user], names_list, zoneDiff, lan_list, addr2(user, "0.0025 ether"))
    _after_mint_record(city, nft)

def whitelist_mint_test(city, cityDict, nft, user1, user2):
    names_list, zoneDiff, lan_list= _get_meta(city, cityDict)
    if names_list==None:
        return

    print(f"Minting NFT {city} ...")
    nft.whitelistMint(user1, proof[user2], names_list, zoneDiff, lan_list, addr2(user1, "0.0025 ether"))
    _after_mint_record(city, nft)

def public_mint(city, cityDict, nft, user):
    names_list, zoneDiff, lan_list= _get_meta(city, cityDict)
    if names_list==None:
        return

    print(f"Minting NFT {city} ...")
    nft.publicSaleMint(user, names_list, zoneDiff, lan_list, addr2(user, "0.003 ether"))
    _after_mint_record(city, nft)

def gift(city, cityDict, nft, _to, _from):
    names_list, zoneDiff, lan_list= _get_meta(city, cityDict)
    if names_list==None:
        return

    print(f"Minting NFT {city} ...")
    nft.gift(_to, names_list, zoneDiff, lan_list, addr(_from))
    _after_mint_record(city, nft)

def main():
    active_network= network.show_active()
    print("Current Network:"+ active_network)

    cityDict= city_zone.initDataBase()

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
            accounts.add(config['wallets']['iwan'])

            admin= accounts[0]
            creator= accounts[1]
            consumer= accounts[2]
            iwan= accounts[3]

            balance_alert(admin, "admin")
            balance_alert(creator, "creator")
            balance_alert(consumer, "consumer")
            balance_alert(consumer, "iwan")

            nft= CivCityNFT[-1]

            # Test for whitelist mint
            #for city in cities:
            #   mint(city, cityDict, nft, True, admin)

            #nft.setStep(1, addr(admin)) # 1= WhitelistSale
            #whitelist_mint(cities[3], cityDict, nft, consumer)
            #whitelist_mint_test(cities[3], cityDict, nft, iwan, creator)
        
            #nft.setStep(2, addr(admin)) # 2= PublicSale
            #public_mint(cities[1], cityDict, nft, iwan)

            nft.setStep(3, addr(admin)) # SoldOut
            gift(cities[4], cityDict, nft, iwan, admin)
            #nft.setIPFSPrefix(ipfs, addr(admin))
            
        if active_network == 'bsc-main':
            accounts.add(config['wallets']['admin'])
            accounts.add(config['wallets']['creator'])
            accounts.add(config['wallets']['consumer'])
            accounts.add(config['wallets']['iwan'])

            admin= accounts[0]
            creator= accounts[1]
            consumer= accounts[2]
            iwan= accounts[3]

    except Exception:
        console.print_exception()
        # Test net contract address

if __name__=="__main__":
    main()