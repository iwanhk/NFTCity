from scripts.city_functions import *


def main():
    active_network = network.show_active()
    print("Current Network:" + active_network)

    (cities, cityDict) = init_city_data()
    admin, creator, consumer, iwan = get_accounts(active_network)

    try:
        if active_network in LOCAL_NETWORKS:
            Random.deploy(addr(admin))
            SVG.deploy(addr(admin))
            DateTime.deploy(addr(admin))
            city = CityToken.deploy(addr(admin))

            team = [admin, creator]
            share = [50, 50]
            nft = CivCityNFT.deploy(
                CityToken[-1], team, share, ROOT, addr(admin))
            city.transferOwnership(nft, addr(admin))

            # Test for whitelist mint
            # for city in cities:
            #   mint(city, cityDict, nft, True, admin)

            # nft.setStep(1, addr(admin)) # 1= WhitelistSale
            #whitelist_mint(cities[3], cityDict, nft, consumer)
            #whitelist_mint_test(cities[3], cityDict, nft, iwan, creator)

            # nft.setStep(2, addr(admin)) # 2= PublicSale
            #public_mint(cities[1], cityDict, nft, iwan)

            nft.setPrices(0, 0, addr(admin))
            nft.setStep(1, addr(admin))  # SoldOut
            gift(cities[0], cityDict, nft, iwan, 2, admin)
            whitelist_mint(cities[1], cityDict, nft, consumer, 0)

            nft.setStep(2, addr(admin))  # 2= PublicSale
            public_mint(cities[2], cityDict, nft, iwan, 0, 3)

            nft.setIPFSPrefix(ipfs, addr(admin))
            nft.setStep(3, addr(admin))

        if active_network in TEST_NETWORKS or active_network in REAL_NETWORKS:
            if active_network in DEPLOYED_ADDR:
                city = CityToken.at(DEPLOYED_ADDR[active_network][1])
                nft = CivCityNFT.at(DEPLOYED_ADDR[active_network][0])

                #nft.setPrices(0,0, addr(admin))
                # nft.setStep(1, addr(admin)) # SoldOut
                #gift(cities[0], cityDict, nft, iwan, admin)

                #nft.setPrices(0,0, addr(admin))
                nft.setStep(3, addr(admin))  # public sale
                public_mint(cities[3], cityDict, nft, iwan, 0)

                # for city in cities:
                #    public_mint(cities[3], cityDict, nft, iwan, 0)

    except Exception:
        console.print_exception()
        # Test net contract address


if __name__ == "__main__":
    main()
