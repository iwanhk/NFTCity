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
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "../interfaces/ICityToken.sol";


contract CivCityNFT is Ownable, PaymentSplitter, ERC1155, ERC1155Pausable {
  enum Step {
      Before,
      WhitelistSale,
      PublicSale,
      Revealed
  }

  Step public sellingStep;

  uint256 private constant MAX_SUPPLY = 10000;
  uint256 private constant MAX_WHITELIST_AND_GIFT = 3000;

  uint256 public wlSalePrice = 0.0025 ether;
  uint256 public publicSalePrice = 0.003 ether;
  uint256 private teamLength;

  uint256 public globalId;

  bytes32 private merkleRoot;

  ICityToken city;

  mapping(address => uint) public amountNFTsperWalletWhitelistSale;
  mapping(string=> uint256) private nameIndex;

  modifier callerIsUser() {
      require(tx.origin == msg.sender, "The caller is another contract");
      _;
  }

  modifier tokenExist(uint256 tokenId) {
      require(tokenId>0 && tokenId< globalId, "Nonexistent token");
      _;
  }
  
  modifier ownerOfToken(uint256 tokenId) {
      require(ownerOf(tokenId)== msg.sender, "Only Owner");
      _;
  }

  modifier reachTotalSupply() {
      require(globalId < MAX_SUPPLY, "Max supply exceeded");
      _;
  }

  modifier reachToalSpecial() {
      require(globalId < MAX_WHITELIST_AND_GIFT, "Max specail supply exceeded");
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
  constructor(address _city, address[] memory _team, uint[] memory _teamShares, bytes32 _merkleRoot) ERC1155('') 
  PaymentSplitter(_team, _teamShares) {

    city= ICityToken(_city);
    merkleRoot = _merkleRoot;
    teamLength = _team.length;
    globalId= 1; // 0 is revered
  }

  function whitelistMint(address _account, 
    uint256 _amount,
    bytes32[] calldata _proof,
    string[] calldata _names, 
    int _zoneDiff, 
    uint8[] calldata _translate) external payable callerIsUser stepOne reachToalSpecial {

    require(isWhiteListed(msg.sender, _proof), "Not whitelisted");
    require(amountNFTsperWalletWhitelistSale[msg.sender] == 0, "You can only get 1 NFT on the Whitelist Sale");
    require(msg.value >= wlSalePrice, "Not enought funds");
    amountNFTsperWalletWhitelistSale[msg.sender] += 1;

    _safeMint(_account, _amount, _names, _zoneDiff, _translate);
  }

  function gift(address _account,
    uint256 _amount,
    string[] calldata _names, 
    int _zoneDiff, 
    uint8[] calldata _translate) external onlyOwner stepOne reachToalSpecial {
    _safeMint(_account, _amount, _names, _zoneDiff, _translate);
  }

  function publicSaleMint(address _account,
    uint256 _amount,
    string[] calldata _names, 
    int _zoneDiff, 
    uint8[] calldata _translate) external payable callerIsUser stepTwo reachTotalSupply {
    require(msg.value >= publicSalePrice, "Not enought funds");

    _safeMint(_account, _amount, _names, _zoneDiff, _translate);
  }
  function _safeMint(address to, uint256 _amount, string[] calldata _names, int _zoneDiff, uint8[] calldata _translate) internal {
      if(nameIndex[names[_translate[21]]]==0){
        city.mint(_names, _zoneDiff, _translate);
        _mint(to,id,amount,'');
      }else{
          // to mint an existing token


      }
  }

  function currentTime() internal view returns(uint) {
      return block.timestamp;
  }

  function setStep(uint _step) external onlyOwner {
      sellingStep = Step(_step);
  }

  //Whitelist
  function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
      merkleRoot = _merkleRoot;
  }

  function setIPFSPrefix(string memory _prefix) external onlyOwner{
      city.setIPFSPrefix(_prefix);
  }

  function setPrices(uint256 _wlSalePrice, uint256 _publicSalePrice) public onlyOwner{
    wlSalePrice= _wlSalePrice;
    publicSalePrice= _publicSalePrice;
  }

  function isWhiteListed(address _account, bytes32[] calldata _proof) internal view returns(bool) {
      return _verify(leaf(_account), _proof);
  }

  function leaf(address _account) internal pure returns(bytes32) {
      return keccak256(abi.encodePacked(_account));
  }

  function _verify(bytes32 _leaf, bytes32[] memory _proof) internal view returns(bool) {
      return MerkleProof.verify(_proof, merkleRoot, _leaf);
  }

  //ReleaseALL
  function releaseAll() external onlyOwner{
      for(uint i = 0 ; i < teamLength ; i++) {
          release(payable(payee(i)));
      }
  }

  receive() override external payable {
      revert('Only if you mint');
  }

    function uri(uint256 tokenId) public override view 
    tokenExist(tokenId) returns (string memory){
    return city.tokenURI(tokenId, sellingStep == Step.Revealed);
  }

  function showAnimation(uint256 tokenId, bool _show) external tokenExist(tokenId) {
      require(ownerOf(tokenId)== msg.sender, "You are not onwer of this NFT");
      city.showAnimation(tokenId, _show);
  }

  function setFont(uint256 tokenId, string calldata _font) external 
    tokenExist(tokenId) ownerOfToken(tokenId){
      city.setFont(tokenId, _font);
  }
  
  function getFont(uint256 tokenId) view external tokenExist(tokenId) {
      city.getFont(tokenId);
  }
  function setMainLang(uint256 tokenId, string calldata _lang) external 
    tokenExist(tokenId) ownerOfToken(tokenId){
    city.setMainLang(tokenId, _lang);
  }
}