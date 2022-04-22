from brownie import CivCityNFT, Random, DateTime, SVG, accounts, network, config
from scripts.tools import *
import json
import os,sys
import random
import scripts.city_zone

D18= 10**18
ZERO= '0x0000000000000000000000000000000000000000'
active_network= network.show_active()
LANG=["af", "sq", "am", "ar", "hy", "az", "eu", "be", "bn", "bs", "bg", "ca", "ceb", "ny", "zh-cn", "zh-tw", "co", "hr", "cs", "da", "nl", "en", "eo", "et", "tl", "fi", "fr", "fy", "gl", "ka", "de", "el", "gu", "ht", "ha", "haw", "iw", "he", "hi", "hmn", "hu", "is", "ig", "id", "ga", "it", "ja", "jw", "kn", "kk", "km", "ko", "ku", "ky", "lo", "la", "lv", "lt", "lb", "mk", "mg", "ms", "ml", "mt", "mi", "mr", "mn", "my", "ne", "no", "or", "ps", "fa", "pl", "pt", "pa", "ro", "ru", "sm", "gd", "sr", "st", "sn", "sd", "si", "sk", "sl", "so", "es", "su", "sw", "sv", "tg", "ta", "te", "th", "tr", "uk", "ur", "ug", "uz", "vi", "cy", "xh", "yi", "yo", "zu"];


def main():
    active_network= network.show_active()
    print("Current Network:"+ active_network)
    
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
            #nft= CivCityNFT.deploy(addr(admin))
            admin.deploy(contract=CivCityNFT, publish_source=True)
            
        if active_network == 'bsc-main':
            accounts.add(config['wallets']['admin'])
            accounts.add(config['wallets']['creator'])
            accounts.add(config['wallets']['consumer'])

            admin= accounts[0]
            creator= accounts[1]
            consumer= accounts[2]

            if len(Random)==0:
                Random.deploy(addr(admin))
            if len(SVG)==0:
                SVG.deploy(addr(admin))
            if len(DateTime)==0:
                DateTime.deploy(addr(admin))
            nft= CivCityNFT.deploy(addr(admin))

    except Exception:
        console.print_exception()
        # Test net contract address

if __name__=="__main__":
    main()