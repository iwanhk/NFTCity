// SPDX-License-Identifier: MIT

// Amended by Iwan
/**
OpeaSea Metadata:
{
  "description": "Friendly OpenSea Creature that enjoys long swims in the ocean.", 
  "external_url": "https://openseacreatures.io/3", 
  "image": "https://storage.googleapis.com/opensea-prod.appspot.com/puffs/3.png", 
  "name": "Dave Starbelly",
  "attributes": [[
    {
      "trait_type": "Base", 
      "value": "Starfish"
    }, 
    {
      "trait_type": "Eyes", 
      "value": "Big"
    }], 
  "background_color": Background color of the item on OpenSea. Must be a six-character hexadecimal without a pre-pended #.
  "nimation_url": A URL to a multi-media attachment for the item. The file extensions GLTF, GLB, WEBM, MP4, M4V, OGV, and OGG are supported, along with the audio-only extensions MP3, WAV, and OGA.
  "Animation_url": also supports HTML pages, allowing you to build rich experiences and interactive NFTs using JavaScript canvas, WebGL, and more. Scripts and relative paths within the HTML page are now supported. However, access to browser extensions is not supported.
  "youtube_url": A URL to a YouTube video.
}
*/

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Base64.sol";
import "./Random.sol";
import "./SVG.sol";
import "./DateTime.sol";

contract CivCityNFT is ERC721Enumerable, Ownable {
  using Strings for uint256;

<<<<<<< Updated upstream
=======
  enum Step {
      Before,
      WhitelistSale,
      PublicSale,
      Reveal
  }

  Step public sellingStep;

  uint256 private constant MAX_SUPPLY = 10000;
  uint256 private constant MAX_WHITELIST_AND_GIFT = 3000;

  uint256 public wlSalePrice = 0.0025 ether;
  uint256 public publicSalePrice = 0.003 ether;

  bytes32 private merkleRoot;

  mapping(address => uint) public amountNFTsperWalletWhitelistSale;

  uint256 private teamLength;
>>>>>>> Stashed changes
  struct City{
    string[] names;
    int zoneDiff; // timezone diff in hours 
    uint8 mainLang; // 21==en
    uint8[] translate;
  }
  string[] public LANG=["af", "sq", "am", "ar", "hy", "az", "eu", "be", "bn", "bs", "bg", "ca", "ceb", "ny", "zh-cn", "zh-tw", "co", "hr", "cs", "da", "nl", "en", "eo", "et", "tl", "fi", "fr", "fy", "gl", "ka", "de", "el", "gu", "ht", "ha", "haw", "iw", "he", "hi", "hmn", "hu", "is", "ig", "id", "ga", "it", "ja", "jw", "kn", "kk", "km", "ko", "ku", "ky", "lo", "la", "lv", "lt", "lb", "mk", "mg", "ms", "ml", "mt", "mi", "mr", "mn", "my", "ne", "no", "or", "ps", "fa", "pl", "pt", "pa", "ro", "ru", "sm", "gd", "sr", "st", "sn", "sd", "si", "sk", "sl", "so", "es", "su", "sw", "sv", "tg", "ta", "te", "th", "tr", "uk", "ur", "ug", "uz", "vi", "cy", "xh", "yi", "yo", "zu"];

<<<<<<< Updated upstream
  City[] public cities;
  bool[] public revealed; // blind box
=======
  City[] private cities;
>>>>>>> Stashed changes
  bool[] public animation; // show GIF
  string[] public font;
  string public ipfsPrefix; // for GIF folder on IPFS

<<<<<<< Updated upstream
  constructor() ERC721("Civilization.Cities.NFT", "CC") {
    ipfsPrefix="";
=======
  modifier callerIsUser() {
      require(tx.origin == msg.sender, "The caller is another contract");
      _;
  }  
  
  modifier tokenExist(uint256 tokenId) {
      require(_exists(tokenId), "Nonexistent token");
      _;
  }
  
  modifier ownerOfToken(uint256 tokenId) {
      require(ownerOf(tokenId)== msg.sender, "Only Owner");
      _;
  }

  modifier maxSupply() {
      require(totalSupply() < MAX_SUPPLY, "Max supply exceeded");
      _;
  }

  modifier maxSpecialOffer() {
      require(totalSupply() < MAX_WHITELIST_AND_GIFT, "Max supply exceeded");
      _;
  }

  modifier stepOne() { // white list and gift stage, max 3000 items
      require(sellingStep == Step.WhitelistSale, "Not in Whitelist and gift stage");
      _;
  }

  modifier stepTwo() { // white list and gift stage, max 3000 items
      require(sellingStep >= Step.PublicSale, "Not in public sale stage");
      _;
  }
  constructor(address[] memory _team, uint[] memory _teamShares, bytes32 _merkleRoot) ERC721A("Civilization.Cities.NFT", "CC") 
  PaymentSplitter(_team, _teamShares) {
    ipfsPrefix="";
    merkleRoot = _merkleRoot;
    teamLength = _team.length;
  }

  function whitelistMint(address _account, 
      bytes32[] calldata _proof,
      string[] calldata _names, 
      int _zoneDiff, 
      uint8[] calldata _translate) external payable callerIsUser stepOne maxSpecialOffer {

      
      require(isWhiteListed(msg.sender, _proof), "Not whitelisted");
      require(amountNFTsperWalletWhitelistSale[msg.sender] == 0, "You can only get 1 NFT on the Whitelist Sale");
      require(msg.value >= wlSalePrice, "Not enought funds");
      amountNFTsperWalletWhitelistSale[msg.sender] += 1;
      _safeMint(_account, _names, _zoneDiff, _translate);
  }


  function gift(address _account,
      string[] calldata _names, 
      int _zoneDiff, 
      uint8[] calldata _translate) external onlyOwner stepOne maxSpecialOffer {
      _safeMint(_account, _names, _zoneDiff, _translate);
  }

  function publicSaleMint(address _account,
      string[] calldata _names, 
      int _zoneDiff, 
      uint8[] calldata _translate) external payable callerIsUser stepTwo maxSpecialOffer {

      require(msg.value >= publicSalePrice, "Not enought funds");

      _safeMint(_account, _names, _zoneDiff, _translate);
  }

  function _safeMint(address to,string[] calldata _names, int _zoneDiff, uint8[] calldata _translate) internal {
      cities.push(City(_names, _zoneDiff, 21, _translate)); // list(googletrans.LANGUAGES)[21] = en

      animation.push(false);
      font.push('Courier');
      _safeMint(to, 1, '');
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

  function setPrice(uint256 _wlSalePrice, uint256 _publicSalePrice) external onlyOwner {
      wlSalePrice= _wlSalePrice;
      publicSalePrice= _publicSalePrice;
  }

  function isWhiteListed(address _account, bytes32[] calldata _proof) internal view returns(bool) {
      return _verify(leaf(_account), _proof);
  }

  function leaf(address _account) internal pure returns(bytes32) {
      return keccak256(abi.encodePacked(_account));
>>>>>>> Stashed changes
  }
  
  // public
  function mint(string[] calldata _names, int _zoneDiff, uint8[] calldata _translate, bool _reveal) public onlyOwner{
    uint256 id= totalSupply();
    require(id< 10000, "Max 10000 NFT had minted");

    cities.push(City(_names, _zoneDiff, 21, _translate)); // list(googletrans.LANGUAGES)[21] = en

    _safeMint(msg.sender, id);

    revealed.push(_reveal);
    animation.push(false);
    font.push('Courier');
  }

  function setIPFSPrefix(string memory _prefix) public onlyOwner{
    ipfsPrefix= _prefix;
  }

  function walletOfOwner(address _owner)
    public
    view
    returns (uint256[] memory)
  {
    uint256 ownerTokenCount = balanceOf(_owner);
    uint256[] memory tokenIds = new uint256[](ownerTokenCount);
    for (uint256 i; i < ownerTokenCount; i++) {
      tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
    }
    return tokenIds;
  }

  function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );

    City storage city= cities[tokenId];

    if(revealed[tokenId]){
      bytes memory animation_url='';
      if(animation[tokenId] && bytes(ipfsPrefix).length>0){
        animation_url= abi.encodePacked(', "animation_url": "', ipfsPrefix, city.names[city.translate[21]], '.gif"');
      }

      int diff=city.zoneDiff;
      bytes memory timeString;
      if(diff<0){
        diff= -diff;
      }
      uint _temp= uint(diff)/60;
      if(_temp<10){
        timeString= abi.encodePacked('0',_temp.toString()); 
      }else{
        timeString= bytes(_temp.toString()); 
      }
      _temp= uint(diff)% 60;
      if(_temp<10){
        timeString= abi.encodePacked(timeString, ':0',_temp.toString()); 
      }else{
        timeString= abi.encodePacked(timeString, ':', _temp.toString()); 
      }

      return string(abi.encodePacked(
        'data:application/json;base64,', Base64.encode(bytes(string(abi.encodePacked(
          '{"name": "', city.names[city.translate[city.mainLang]],
          '", "description":"The **Civilization City NFT**, dynamic, local time sensitive, programmable, rare!", "image_data": "',
          'data:image/svg+xml;base64,',
          Base64.encode(bytes(_buildImage(tokenId))),
          '"',
          animation_url,
          ', "designer": "CD", "attributes": [{"trait_type": "Names","value": "',
          uint256(city.names.length).toString(),
          '"},{"trait_type": "Main language","value": "',
          LANG[city.mainLang],
          '"},{"trait_type": "Time Zone(UTC)","value": "',
          city.zoneDiff<0?'-':'+',timeString,
          '"}]}'))))));
    }
    return string(abi.encodePacked(
        'data:application/json;base64,', Base64.encode(bytes(string(abi.encodePacked(
          '{"name": "NOT REVEALED',
          '", "description":"The **Civilization City NFT**, dynamic, local time sensitive, programmable, rare!", "image_data": "',
          'data:image/svg+xml;base64,',
          Base64.encode(bytes(_buildImage(tokenId))),
          '", "designer": "CD", "attributes": [{"trait_type": "Names","value": "',
          uint256(city.names.length).toString(),
          '"},{"trait_type": "Main language","value": "',
          LANG[city.mainLang],
          '"}]}'))))));
  }

  //only owner
  function reveal(uint256 tokenId, bool _reveal) public {
      require(_exists(tokenId),"ERC721Metadata: URI query for nonexistent token");
      require(ownerOf(tokenId)== msg.sender, "You are not onwer of this NFT");
      revealed[tokenId] = _reveal;
  }

  function showAnimation(uint256 tokenId, bool _show) public {
      require(_exists(tokenId),"ERC721Metadata: URI query for nonexistent token");
      require(ownerOf(tokenId)== msg.sender, "You are not onwer of this NFT");
      require(bytes(ipfsPrefix).length>0, "Admin has not set the ipfs prefix");
      animation[tokenId] = _show;
  }

  function setFont(uint256 tokenId, string calldata _font) public {
      require(_exists(tokenId),"ERC721Metadata: URI query for nonexistent token");
      require(ownerOf(tokenId)== msg.sender, "You are not onwer of this NFT");
      font[tokenId] = _font;
  }
  
  function setMainLang(uint256 tokenId, string calldata lang) public {
    require(_exists(tokenId),"ERC721Metadata: URI query for nonexistent token");
    require(ownerOf(tokenId)== msg.sender, "You are not onwer of this NFT");

    for(uint8 i=0; i< LANG.length; i++){
      if(_stringEqu(bytes(LANG[i]), bytes(lang))){
        cities[tokenId].mainLang= i;
        return;
      }
    }

    revert("No this lang in the lang list");
  }

  function getMainLang(uint256 tokenId) view public returns(string memory){
    require(_exists(tokenId),"ERC721Metadata: URI query for nonexistent token");
    return LANG[cities[tokenId].mainLang];
  }

<<<<<<< Updated upstream
=======
  function getFont(uint256 tokenId) view public tokenExist(tokenId) returns(string memory){
    return font[tokenId];
  }

  function getNames(uint256 tokenId) view public tokenExist(tokenId) returns(string memory){
    return cities[tokenId].names;
  }
>>>>>>> Stashed changes
  function _stringEqu(bytes memory a, bytes memory b) pure internal returns (bool){
    if(bytes(a).length != bytes(b).length) {
        return false;
    } else {
        return keccak256(a) == keccak256(b);
    }
  } 
  
  function _buildImage(uint256 tokenId) view internal returns (string memory){
    City storage city= cities[tokenId];
    
    if(revealed[tokenId] == false) {
      bytes[5] memory parts;
              // SVG Template, with rect backgroud
      parts[0]= SVG.head(font[tokenId],'700');
      parts[1]= SVG.rect('0 100% 100%'); // White
      parts[2]= SVG.text('0, 0, 0%', "82", 'x= "100" y="239"', 'City');
      parts[3]= SVG.text('0, 0, 0%', "39", 'x= "127" y="277"', 'Civilization');
      parts[4]= SVG.tail();
      return string(abi.encodePacked(parts[0], parts[1], parts[2], parts[3], parts[4]));
    }

    int diff= int(DateTime.getHour()*60+ DateTime.getMinute())+ city.zoneDiff;

    if(diff<0){
      diff+= 1440; //24 hours = 1440 mins
    }

    return svgString(tokenId, uint256(diff)/60, uint256(diff)%60);
  }
  function svgString(uint256 tokenId, uint256 nowHour, uint256 nowMin) view public returns (string memory){
    bytes[6] memory parts;
    City storage city= cities[tokenId];

    uint256 degree= nowHour*100/12;
    if(nowHour> 12){
      degree= 200- degree;
    }

    // SVG Template, with rect backgroud
    parts[0]= SVG.head(font[tokenId],'700');
    parts[1]= SVG.rect(string(abi.encodePacked('0 0% ', degree.toString(), '%')));
         

    string storage name= city.names[city.translate[city.mainLang]];
    /*
    uint256 size= 500/bytes(name).length;
    uint256 x_pos= Random.randrange(500-size*bytes(name).length, 127);
    uint256 y_pos= Random.randrange(size+30, 470, 128);
    */

    // Rest translation text
    parts[2]="";
    uint256 totalNames= city.names.length;
    for(uint i=0; i<totalNames; i++){
        uint256 size;
        uint256 x_pos;
        uint256 y_pos;

        if(i==city.translate[city.mainLang]){
          continue;
        }
        size= Random.randrange(uint256(250/totalNames), uint256(1250/totalNames), i<<2);
        x_pos= (i % (totalNames/10))  * 5000/totalNames + Random.randrange(30, i<<2+1);
        y_pos= (i+1)* 500/ totalNames+ Random.randrange(30, i<<2+2);
        if(y_pos> 480){y_pos=480- Random.randrange(30, i<<2+2);}

        parts[2]= abi.encodePacked(parts[2], SVG.text(
                      string(abi.encodePacked(Random.randrange(360, i<<2+3).toString(), " 100% ", (100-degree).toString(), "%")), 
                      size.toString(),
                      string(abi.encodePacked('x= "', x_pos.toString(), '" y="', y_pos.toString(), '"')),
                      city.names[i]));
    }

    // Main Lang text
    parts[3]= SVG.textMiddle(string(abi.encodePacked(Random.randrange(360, 129).toString(), " 100% ", (100-degree).toString(), "%")), 
                  "70",
                  string(abi.encodePacked('x= "250" y="250"')),
                  name);
    // Timestamp
    string memory hourString;
    if(nowHour<10){
      hourString=string(abi.encodePacked("0", nowHour.toString())); 
    }else{
      hourString=string(abi.encodePacked(nowHour.toString())); 
    }
    string memory minString;
    if(nowMin<10){
      minString=string(abi.encodePacked("0", nowMin.toString())); 
    }else{
      minString=string(abi.encodePacked(nowMin.toString())); 
    }

    parts[4]= SVG.text(string(abi.encodePacked("180 100% ", (100-degree).toString(), "%")), 
                  "15",
                  'x= "450" y="15"',
                  string(abi.encodePacked(hourString, ":", minString)));
    parts[5]= SVG.tail();
    return string(abi.encodePacked(parts[0], parts[1], parts[2], parts[3], parts[4], parts[5]));
  }

  function getNames(uint256 indexId) view public returns (string [] memory){
    return cities[indexId].names;
  }

  function getLangs(uint256 indexId) view public returns (uint8 [] memory){
    return cities[indexId].translate;
  }
}