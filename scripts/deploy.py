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

        if active_network in TEST_NETWORKS:
            if len(Random)==0:
                Random.deploy(addr(admin))
            #if len(SVG)==0:    
            SVG.deploy(addr(admin))
            if len(DateTime)==0: 
                DateTime.deploy(addr(admin))
            #if len(CityToken)==0: 
            city= CityToken.deploy(addr(admin))

            team= [admin, creator]
            share= [50, 50]
            nft= CivCityNFT.deploy(city, team, share, ROOT, addr(admin))
            city.transferOwnership(nft, addr(admin))            

    except Exception:
        console.print_exception()
        # Test net contract address

if __name__=="__main__":
    main()