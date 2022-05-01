from scripts.city_functions import *

def main():
    active_network= "developmet"
    print("Current Network:"+ active_network)
    
    (cities, cityDict)= init_city_data()
    admin, creator, consumer, iwan= get_accounts(active_network)

    try:
        Random.deploy(addr(admin))
        SVG.deploy(addr(admin))
        DateTime.deploy(addr(admin))
        city= CityToken.deploy(addr(admin))

        team= [admin, creator]
        share= [50, 50]
        nft= CivCityNFT.deploy(CityToken[-1], team, share, ROOT, addr(admin))

        flat_contract('CityToken', CityToken.get_verification_info())
        flat_contract('CivCityNFT', CivCityNFT.get_verification_info())

    except Exception:
        console.print_exception()
        # Test net contract address

if __name__=="__main__":
    main()