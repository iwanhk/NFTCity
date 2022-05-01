from scripts.city_functions import *

def main():
    active_network= network.show_active()
    print("Current Network:"+ active_network)
    
    (cities, cityDict)= init_city_data()
    admin, creator, consumer, iwan= get_accounts(active_network)

    try:
        if active_network in LOCAL_NETWORKS:
            Random.deploy(addr(admin))
            SVG.deploy(addr(admin))
            DateTime.deploy(addr(admin))
            city= CityToken.deploy(addr(admin))

            team= [admin, creator]
            share= [50, 50]
            nft= CivCityNFT.deploy(CityToken[-1], team, share, ROOT, addr(admin))
            city.transferOwnership(nft, addr(admin))
            
        if active_network in TEST_NETWORKS or active_network in REAL_NETWORKS:
            if active_network in DEPLOYED_ADDR:
                city= CityToken.at(DEPLOYED_ADDR[active_network][1])
                nft= CivCityNFT.at(DEPLOYED_ADDR[active_network][0])
            

    except Exception:
        console.print_exception()
        # Test net contract address

if __name__=="__main__":
    main()