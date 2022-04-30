from brownie import CivCityNFT, Random, DateTime, SVG, accounts, network, config
from scripts.tools import *
import json
import os,sys
import random
from scripts.gen_gif import gen_dir
import scripts.city_zone as city_zone

D18= 10**18
ZERO= '0x0000000000000000000000000000000000000000'
active_network= network.show_active()
LANG=["af", "sq", "am", "ar", "hy", "az", "eu", "be", "bn", "bs", "bg", "ca", "ceb", "ny", "zh-cn", "zh-tw", "co", "hr", "cs", "da", "nl", "en", "eo", "et", "tl", "fi", "fr", "fy", "gl", "ka", "de", "el", "gu", "ht", "ha", "haw", "iw", "he", "hi", "hmn", "hu", "is", "ig", "id", "ga", "it", "ja", "jw", "kn", "kk", "km", "ko", "ku", "ky", "lo", "la", "lv", "lt", "lb", "mk", "mg", "ms", "ml", "mt", "mi", "mr", "mn", "my", "ne", "no", "or", "ps", "fa", "pl", "pt", "pa", "ro", "ru", "sm", "gd", "sr", "st", "sn", "sd", "si", "sk", "sl", "so", "es", "su", "sw", "sv", "tg", "ta", "te", "th", "tr", "uk", "ur", "ug", "uz", "vi", "cy", "xh", "yi", "yo", "zu"];
DATADIR= 'data/'
ROOT='0x4a8d100c5b3c09841808d8fe60f6e7ce0812e6154420676e08030af0ad9b43fc'

def process_city(meta_file:str):
    with open(meta_file,'r') as load_f:
        meta_dict = json.load(load_f)

    with open(meta_file[:-7]+'in.json','r') as load_f:
        lan_dict = json.load(load_f)

    names_list= list(meta_dict.keys())
    lan_list=[]
    for lan in lan_dict.keys():
        lan_list.append(names_list.index(lan_dict[lan]))

    print(f"{names_list=}")
    return (names_list, lan_list)

def mint(city, cityDict, nft, user):
    file_name=os.path.join(DATADIR+ "city_meta", city+'.ot.json')
    names_list, lan_list= process_city(file_name)
    city_name, zone, now_time= city_zone.query(city, cityDict)
    if now_time==None:
        print(f"{city} cannot be found in cityZone, pass")
        return
    print(f"{now_time=}")

    zoneDiff=int(now_time[-4:-2])*60+ int(now_time[-2:])
    if now_time[-5]=='-':
        zoneDiff= -zoneDiff
    #nft.mint(names_list, zoneDiff, lan_list, reveal, addr(user))
    nft.publicSaleMint(user, names_list, zoneDiff, lan_list, addr2(user, 0))

def dump_svg(nft, index, user):
    # Dump SVG
    if not os.path.exists(DATADIR+ 'svg'):
        os.mkdir(DATADIR+ 'svg')
    names_list= nft.getNames(index)
    name= names_list[nft.getLangs(index)[21]]

    if not os.path.exists(DATADIR+ 'svg/'+name):
        os.mkdir(DATADIR+ 'svg/'+name)

    lang_list= nft.getLangs(index)
    round= max(len(names_list), 24)
    #print(names_list)
    for i in range(round):
        hour= i % 24
        minut= random.randrange(60)
        lang= LANG[lang_list.index(i)]
        
        print(f'Changing main lang to {lang}')
        nft.setMainLang(index, lang, addr(user))
        svg= nft.svgString(index, hour, minut)
        print(f'[{str(hour).zfill(2)}:{str(minut).zfill(2)}] Writing No{i} {lang} to svg/{name}/{i} file...')
        with open(DATADIR+ 'svg/'+name+ "/"+ str(i).zfill(3)+ "."+lang+'.svg', 'w') as f:
            f.write(svg)
        
        

def main():
    active_network= network.show_active()
    print("Current Network:"+ active_network)
    
    try:
        if active_network == 'development' :
            admin=accounts[0]
            creator=accounts[1]
            consumer=accounts[2]

            cityDict= city_zone.initDataBase()

            g = os.walk(DATADIR+ "city_meta")

            cities=[]
            for path,dir_list,file_list in g:  
                for file_name in file_list:  
                    if(file_name[-7:]=='ot.json'):
                        #print(os.path.join(path, file_name) )
                        cities.append(file_name[:-8])

            Random.deploy(addr(admin))
            SVG.deploy(addr(admin))
            DateTime.deploy(addr(admin))

            team= [admin, creator]
            share= [50, 50]
            CivCityNFT.deploy(team, share, ROOT, addr(admin))

            nft= CivCityNFT[-1]
            nft.setStep(3) # Final stage
            nft.setPrices(0,0)

            """
            for city in cities:
                if os.path.exists(DATADIR+ 'svg/'+ city):
                    continue
                mint(city, cityDict, nft, admin)
            """
            mint(cities[0], cityDict, nft, admin)

            for i in range(nft.totalSupply()):
                name= nft.getNames(i)[nft.getLangs(i)[21]]
                print(f"Now dumping {name}...")
                dump_svg(nft, i, admin)
            #gen_dir(('svg', 'gif'))
            
            #with ThreadPoolExecutor() as p:
            #    p.map(gen_group, cities)
            #nft.reveal(addr(admin))

        if active_network== 'mainnet-fork':
            admin=accounts[0]
            creator=accounts[1]
            consumer=accounts[2]

            balance_alert(admin, "admin")
            balance_alert(creator, "creator")
            balance_alert(consumer, "consumer")

            nft= CivCityNFT[-1]
            for i in range(nft.totalSupply()):
                dump_svg(nft, i, admin)


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

            nft= CivCityNFT[-1]
            for i in range(nft.totalSupply()):
                dump_svg(nft, i, admin)

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