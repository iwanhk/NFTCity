from scripts.city_functions import *

def main():
    active_network= "development"
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
        city.transferOwnership(nft, addr(admin))

        nft.setStep(3) # Final stage
        nft.setPrices(0,0)

        for c in cities:
            if os.path.exists(DATADIR+ 'svg/'+ c):
                continue
            mint(c, cityDict, nft, admin, "0")
        
        #mint(cities[0], cityDict, nft, admin)

        for i in range(nft.totalSupply()):
            name= city.getNames(i)[city.getLangs(i)[21]]
            print(f"Now dumping {name}...")
            dump_svg(city, nft, i, admin)


    except Exception:
        console.print_exception()
        # Test net contract address

if __name__=="__main__":
    main()