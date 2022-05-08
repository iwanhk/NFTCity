from brownie import CivCityNFT, CityToken, Random, DateTime, SVG, testArgList, accounts, network, config
from scripts.tools import *
from scripts.gen_gif import gen_dir
import scripts.city_zone as city_zone
import os
import random

D18 = 10**18
ZERO = '0x0000000000000000000000000000000000000000'
active_network = network.show_active()
LANG = ["af", "sq", "am", "ar", "hy", "az", "eu", "be", "bn", "bs", "bg", "ca", "ceb", "ny", "zh-cn", "zh-tw", "co", "hr", "cs", "da", "nl", "en", "eo", "et", "tl", "fi", "fr", "fy", "gl", "ka", "de", "el", "gu", "ht", "ha", "haw", "iw", "he", "hi", "hmn", "hu", "is", "ig", "id", "ga", "it", "ja", "jw", "kn", "kk", "km", "ko",
        "ku", "ky", "lo", "la", "lv", "lt", "lb", "mk", "mg", "ms", "ml", "mt", "mi", "mr", "mn", "my", "ne", "no", "or", "ps", "fa", "pl", "pt", "pa", "ro", "ru", "sm", "gd", "sr", "st", "sn", "sd", "si", "sk", "sl", "so", "es", "su", "sw", "sv", "tg", "ta", "te", "th", "tr", "uk", "ur", "ug", "uz", "vi", "cy", "xh", "yi", "yo", "zu"]
DATADIR = 'data/'
ROOT = '0x4a8d100c5b3c09841808d8fe60f6e7ce0812e6154420676e08030af0ad9b43fc'
ipfs = 'https://bafybeie3mhgs5mf236vwkdehwyrnvmmo5shezlpir7pdioccuqt6euxtum.ipfs.nftstorage.link/'
proof = {'0x7B0dc23E87febF1D053E7Df9aF4cce30F21fAe9C': ['0x248ac1f01201ebad7020ea2c3e1b2fdf454040932298e8947f9ffb61e8de51a2', '0x91a8ee7c5b8062ff383207a299bf57fda043b5785fd32b35fe1a757a9c52abbf'],
         '0x8531fEaAcD66599102adf9C5f701E6C490f44f1C': ['0x869e65de98ffe6d41241bd4a4149d7152f7ecbe9627441c85862fdeffaa7b05a', '0x91a8ee7c5b8062ff383207a299bf57fda043b5785fd32b35fe1a757a9c52abbf'],
         '0xAb1fdD3F84b2019BEF47939E66fb6194532f9640': ['0xc6fa5ccdc8ab39e4d4daca36f8694c30d4bd3c67febddf13d0f8083d1d24c504']
         }

LOCAL_NETWORKS = ['development', 'mainnet-fork', 'polygon-fork']
TEST_NETWORKS = ['rinkeby', 'bsc-test', 'mumbai']
REAL_NETWORKS = ['mainnet', 'polygon']
DEPLOYED_ADDR = {  # Deployed address of CivCityNFT CityToken
    'rinkeby': ["0x22c1b71bf659a36fad8a476c3499964d2714c13b", "0x8525e4bf39ce1f5e9a3c4cd4fc29c39828edd8e9"],
    'mumbai': ["0xFB6072fa6bc00A506e2794b5CFA535722D2F10f2", "0x6dA65D1182C4d38B0C7deA0C5146E42e0F0AC69A"]
}


def get_accounts(active_network):
    if active_network in LOCAL_NETWORKS:
        admin = accounts.add(config['wallets']['admin'])
        creator = accounts.add(config['wallets']['creator'])
        consumer = accounts.add(config['wallets']['consumer'])
        iwan = accounts.add(config['wallets']['iwan'])

        accounts[0].transfer(admin, "100 ether")
        accounts[1].transfer(creator, "100 ether")
        accounts[2].transfer(consumer, "100 ether")
        accounts[3].transfer(iwan, "100 ether")

    else:
        admin = accounts.add(config['wallets']['admin'])
        creator = accounts.add(config['wallets']['creator'])
        consumer = accounts.add(config['wallets']['consumer'])
        iwan = accounts.add(config['wallets']['iwan'])

    balance_alert(admin, "admin")
    balance_alert(creator, "creator")
    balance_alert(consumer, "consumer")
    balance_alert(iwan, "consumer")
    return [admin, creator, consumer, iwan]


def flat_contract(name: str, meta_data: dict) -> None:
    if not os.path.exists(name + '_flat'):
        os.mkdir(name + '_flat')

    with open(name + '_flat/settings.json', 'w') as f:
        json.dump(meta_data['standard_json_input']['settings'], f)

    for file in meta_data['standard_json_input']['sources'].keys():
        print(f"Flatten file {name+ '_flat/'+ file} ")
        with open(name + '_flat/' + file, 'w') as f:
            content = meta_data['standard_json_input']['sources'][file]['content'].split(
                '\n')

            for line in content:
                if 'import "' in line:
                    f.write(line.replace('import "', 'import "./')+'\n')
                else:
                    f.write(line+'\n')
            f.write(f'\n// Generated by {__file__} \n')


def init_city_data():
    cityDict = city_zone.initDataBase()

    g = os.walk(DATADIR + "city_meta")

    cities = []
    for path, dir_list, file_list in g:
        for file_name in file_list:
            if(file_name[-7:] == 'ot.json'):
                #print(os.path.join(path, file_name) )
                cities.append(file_name[:-8])
    print(f"Total {len(cities)} city meta data stored in cities")
    return (cities, cityDict)


def process_city(meta_file: str):
    with open(meta_file, 'r') as load_f:
        meta_dict = json.load(load_f)

    with open(meta_file[:-7]+'in.json', 'r') as load_f:
        lan_dict = json.load(load_f)

    names_list = list(meta_dict.keys())
    lan_list = []
    for lan in lan_dict.keys():
        lan_list.append(names_list.index(lan_dict[lan]))

    print(f"{names_list=}")
    return (names_list, lan_list)


def dump_svg(city, nft, index, user):
    # Dump SVG
    if not os.path.exists(DATADIR + 'svg'):
        os.mkdir(DATADIR + 'svg')
    names_list = city.getNames(index)
    name = names_list[city.getLangs(index)[21]]

    if not os.path.exists(DATADIR + 'svg/'+name):
        os.mkdir(DATADIR + 'svg/'+name)

    lang_list = city.getLangs(index)
    round = max(len(names_list), 24)
    # print(names_list)
    for i in range(round):
        hour = i % 24
        minut = random.randrange(60)
        lang = LANG[lang_list.index(i)]

        print(f'Changing main lang to {lang}')
        nft.setMainLang(index, lang, addr(user))
        svg = city.svgString(index, hour, minut)
        print(
            f'[{str(hour).zfill(2)}:{str(minut).zfill(2)}] Writing No{i} {lang} to svg/{name}/{i} file...')
        with open(DATADIR + 'svg/'+name + "/" + str(i).zfill(3) + "."+lang+'.svg', 'w') as f:
            f.write(svg)

# Simple mint is for dump out SVG files, we don't recoed


def simple_mint(city, cityDict, nft, user, price):
    file_name = os.path.join(DATADIR + "city_meta", city+'.ot.json')
    names_list, lan_list = process_city(file_name)
    city_name, zone, now_time = city_zone.query(city, cityDict)
    if now_time == None:
        print(f"{city} cannot be found in cityZone, pass")
        return
    # print(f"{now_time=}")

    zoneDiff = int(now_time[-4:-2])*60 + int(now_time[-2:])
    if now_time[-5] == '-':
        zoneDiff = -zoneDiff
    print(f"Minting NFT {city} ...")
    nft.publicSaleMint(user, names_list, zoneDiff,
                       lan_list, addr2(user, price))


def _get_meta(city, cityDict) -> tuple:
    if active_network in LOCAL_NETWORKS:
        pass
    else:
        with open(DATADIR + 'mint.json', 'r') as deployed_file:
            history = json.load(deployed_file)
        if city in history:
            print(f"{city} in history, pass")
            return (None, None, None)

    file_name = os.path.join(DATADIR + "city_meta", city+'.ot.json')
    names_list, lan_list = process_city(file_name)
    city_name, zone, now_time = city_zone.query(city, cityDict)
    if now_time == None:
        print(f"{city} cannot be found in cityZone, pass")
        return (None, None, None)
    # print(f"{now_time=}")

    zoneDiff = int(now_time[-4:-2])*60 + int(now_time[-2:])
    if now_time[-5] == '-':
        zoneDiff = -zoneDiff

    return (names_list, zoneDiff, lan_list)


def _after_mint_record(city, nft):
    if active_network in LOCAL_NETWORKS:
        return
    with open(DATADIR + 'deployed.json', 'r') as deployed_file:
        history = json.load(deployed_file)

    history[city] = nft.totalSupply()
    with open(DATADIR + 'deployed.json', 'w') as deployed_file:
        json.dump(history, deployed_file)


def whitelist_mint(city, cityDict, nft, user, price):
    names_list, zoneDiff, lan_list = _get_meta(city, cityDict)
    if names_list == None:
        return

    print(f"Minting NFT {city} ...")
    tx = nft.whitelistMint(
        user, proof[user.address], names_list, zoneDiff, lan_list, addr2(user, price))
    tx.wait(1)
    if tx.status == 1:
        _after_mint_record(city, nft)


def whitelist_mint_test(city, cityDict, nft, user1, price, user2):
    names_list, zoneDiff, lan_list = _get_meta(city, cityDict)
    if names_list == None:
        return

    print(f"Minting NFT {city} ...")
    tx = nft.whitelistMint(
        user1, proof[user2.address], names_list, zoneDiff, lan_list, addr2(user1, price))
    tx.wait(1)
    if tx.status == 1:
        _after_mint_record(city, nft)


def public_mint(city, cityDict, nft, user, price, amount):
    names_list, zoneDiff, lan_list = _get_meta(city, cityDict)
    if names_list == None:
        return

    print(f"Minting NFT {city} ...")
    tx = nft.publicSaleMint(user, amount, names_list, zoneDiff,
                            lan_list, addr2(user, price))
    tx.wait(1)
    if tx.status == 1:
        _after_mint_record(city, nft)


def gift(city, cityDict, nft, _to, amount, _from):
    names_list, zoneDiff, lan_list = _get_meta(city, cityDict)
    if names_list == None:
        return

    print(f"Minting NFT {city} ...")
    tx = nft.gift(_to, amount, names_list, zoneDiff, lan_list, addr(_from))
    tx.wait(1)
    if tx.status == 1:
        _after_mint_record(city, nft)
