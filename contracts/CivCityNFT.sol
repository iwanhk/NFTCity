// SPDX-License-Identifier: MIT

/*
          _____                    _____                _____                _____          
         /\    \                  /\    \              /\    \              |\    \         
        /::\    \                /::\    \            /::\    \             |:\____\        
       /::::\    \               \:::\    \           \:::\    \            |::|   |        
      /::::::\    \               \:::\    \           \:::\    \           |::|   |        
     /:::/\:::\    \               \:::\    \           \:::\    \          |::|   |        
    /:::/  \:::\    \               \:::\    \           \:::\    \         |::|   |        
   /:::/    \:::\    \              /::::\    \          /::::\    \        |::|   |        
  /:::/    / \:::\    \    ____    /::::::\    \        /::::::\    \       |::|___|______  
 /:::/    /   \:::\    \  /\   \  /:::/\:::\    \      /:::/\:::\    \      /::::::::\    \ 
/:::/____/     \:::\____\/::\   \/:::/  \:::\____\    /:::/  \:::\____\    /::::::::::\____\
\:::\    \      \::/    /\:::\  /:::/    \::/    /   /:::/    \::/    /   /:::/~~~~/~~      
 \:::\    \      \/____/  \:::\/:::/    / \/____/   /:::/    / \/____/   /:::/    /         
  \:::\    \               \::::::/    /           /:::/    /           /:::/    /          
   \:::\    \               \::::/____/           /:::/    /           /:::/    /           
    \:::\    \               \:::\    \           \::/    /            \::/    /            
     \:::\    \               \:::\    \           \/____/              \/____/             
      \:::\    \               \:::\    \                                                   
       \:::\____\               \:::\____\                                                  
        \::/    /                \::/    /                                                  
         \/____/                  \/____/                                                   
                                                                                            
*/

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/finance/PaymentSplitter.sol";
import "./ERC721A.sol";
import "../interfaces/ICityToken.sol";

contract CivCityNFT is Ownable, ERC721A, PaymentSplitter {
    enum Step {
        Before,
        WhitelistSale,
        PublicSale,
        Revealed
    }

    struct NFTRecord {
        string name; // name is EN name, must be uniqe
        string font;
        uint8 mainLang;
        bool showAnimation;
    }

    Step public sellingStep;

    uint256 private constant MAX_SUPPLY = 10000; // Max total cities
    uint256 private constant MAX_WHITELIST_AND_GIFT = 3000; // revered for gift and white list
    uint256 private constant MAX_AMOUNT = 3000; // amount per city

    uint256 public wlSalePrice = 0.0025 ether;
    uint256 public publicSalePrice = 0.003 ether;
    uint256 private teamLength;

    bytes32 private merkleRoot;

    ICityToken city;

    mapping(address => uint256) public amountNFTsperWalletWhitelistSale;
    mapping(string => uint256) private cityMap; // name => id, amount

    NFTRecord[] nft;

    modifier callerIsUser() {
        require(tx.origin == msg.sender, "The caller is another contract");
        _;
    }

    modifier tokenExist(uint256 tokenId) {
        require(_exists(tokenId), "Nonexistent token");
        _;
    }

    modifier ownerOfToken(uint256 tokenId) {
        require(ownerOf(tokenId) == msg.sender, "Only Owner");
        _;
    }

    modifier reachTotalSupply() {
        require(totalSupply() < MAX_SUPPLY, "Max supply exceeded");
        _;
    }

    modifier reachToalSpecial() {
        require(
            totalSupply() < MAX_WHITELIST_AND_GIFT,
            "Max specail supply exceeded"
        );
        _;
    }

    modifier stepOne() {
        require(sellingStep == Step.WhitelistSale, "Not in Whitelist stage");
        _;
    }

    modifier stepTwo() {
        require(sellingStep >= Step.PublicSale, "Not in public stage");
        _;
    }

    constructor(
        address _city,
        address[] memory _team,
        uint256[] memory _teamShares,
        bytes32 _merkleRoot
    )
        ERC721A("Civilization.Cities.NFT", "CC")
        PaymentSplitter(_team, _teamShares)
    {
        city = ICityToken(_city);
        merkleRoot = _merkleRoot;
        teamLength = _team.length;
    }

    function whitelistMint(
        address _account,
        bytes32[] calldata _proof,
        string[] calldata _names,
        int256 _zoneDiff,
        uint8[] calldata _translate
    ) external payable callerIsUser stepOne reachToalSpecial {
        require(isWhiteListed(msg.sender, _proof), "Not whitelisted");
        require(
            amountNFTsperWalletWhitelistSale[msg.sender] == 0,
            "You can only get 1 NFT on the Whitelist Sale"
        );
        require(msg.value >= wlSalePrice, "Not enought funds");
        amountNFTsperWalletWhitelistSale[msg.sender] += 1;

        _safeMint(_account, 1, _names, _zoneDiff, _translate);
    }

    function gift(
        address _account,
        uint256 _amount,
        string[] calldata _names,
        int256 _zoneDiff,
        uint8[] calldata _translate
    ) external onlyOwner stepOne reachToalSpecial {
        _safeMint(_account, _amount, _names, _zoneDiff, _translate);
    }

    function publicSaleMint(
        address _account,
        uint256 _amount,
        string[] calldata _names,
        int256 _zoneDiff,
        uint8[] calldata _translate
    ) external payable callerIsUser stepTwo reachTotalSupply {
        require(msg.value >= publicSalePrice, "Not enought funds");

        _safeMint(_account, _amount, _names, _zoneDiff, _translate);
    }

    function _safeMint(
        address to,
        uint256 _amount,
        string[] calldata _names,
        int256 _zoneDiff,
        uint8[] calldata _translate
    ) internal {
        require(_amount > 0, "0 amount to mint");
        string memory cityENName = _names[_translate[21]];

        if (cityMap[cityENName] == 0) {
            // New record
            city.mint(_names, _zoneDiff, _translate);
        }
        cityMap[cityENName] += _amount;
        for (uint256 i = 0; i < _amount; ++i) {
            nft.push(NFTRecord(cityENName, "Courier", 21, false));
        }

        _safeMint(to, _amount, "");
    }

    function currentTime() internal view returns (uint256) {
        return block.timestamp;
    }

    function setStep(uint256 _step) external onlyOwner {
        sellingStep = Step(_step);
    }

    //Whitelist
    function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function setIPFSPrefix(string memory _prefix) external onlyOwner {
        city.setIPFSPrefix(_prefix);
    }

    function setPrices(uint256 _wlSalePrice, uint256 _publicSalePrice)
        public
        onlyOwner
    {
        wlSalePrice = _wlSalePrice;
        publicSalePrice = _publicSalePrice;
    }

    function isWhiteListed(address _account, bytes32[] calldata _proof)
        internal
        view
        returns (bool)
    {
        return _verify(leaf(_account), _proof);
    }

    function leaf(address _account) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_account));
    }

    function _verify(bytes32 _leaf, bytes32[] memory _proof)
        internal
        view
        returns (bool)
    {
        return MerkleProof.verify(_proof, merkleRoot, _leaf);
    }

    //ReleaseALL
    function releaseAll() external onlyOwner {
        for (uint256 i = 0; i < teamLength; i++) {
            release(payable(payee(i)));
        }
    }

    receive() external payable override {
        revert("Only if you mint");
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        tokenExist(tokenId)
        returns (string memory)
    {
        return
            string(
                city.uriString(
                    nft[tokenId].name,
                    nft[tokenId].font,
                    nft[tokenId].mainLang,
                    nft[tokenId].showAnimation,
                    sellingStep == Step.Revealed
                )
            );
    }

    function showAnimation(uint256 tokenId, bool _show)
        external
        tokenExist(tokenId)
        ownerOfToken(tokenId)
    {
        nft[tokenId].showAnimation = _show;
    }

    function setFont(uint256 tokenId, string calldata _font)
        external
        tokenExist(tokenId)
        ownerOfToken(tokenId)
    {
        nft[tokenId].font = _font;
    }

    function getFont(uint256 tokenId)
        external
        view
        tokenExist(tokenId)
        returns (string memory)
    {
        return nft[tokenId].font;
    }

    function setMainLang(uint256 tokenId, string calldata _lang)
        external
        tokenExist(tokenId)
        ownerOfToken(tokenId)
    {
        nft[tokenId].mainLang = city.langId(_lang);
    }
}
