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

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Base64.sol";
import "./Random.sol";
import "./SVG.sol";
import "./DateTime.sol";

contract CityToken is Ownable {
    using Strings for uint256;

    struct City{
        string[] names;
        int zoneDiff; // timezone diff in hours 
        uint8 mainLang; // 21==en
        uint8[] translate;
    }
    string[] public LANG=["af", "sq", "am", "ar", "hy", "az", "eu", "be", "bn", "bs", "bg", "ca", "ceb", "ny", "zh-cn", "zh-tw", "co", "hr", "cs", "da", "nl", "en", "eo", "et", "tl", "fi", "fr", "fy", "gl", "ka", "de", "el", "gu", "ht", "ha", "haw", "iw", "he", "hi", "hmn", "hu", "is", "ig", "id", "ga", "it", "ja", "jw", "kn", "kk", "km", "ko", "ku", "ky", "lo", "la", "lv", "lt", "lb", "mk", "mg", "ms", "ml", "mt", "mi", "mr", "mn", "my", "ne", "no", "or", "ps", "fa", "pl", "pt", "pa", "ro", "ru", "sm", "gd", "sr", "st", "sn", "sd", "si", "sk", "sl", "so", "es", "su", "sw", "sv", "tg", "ta", "te", "th", "tr", "uk", "ur", "ug", "uz", "vi", "cy", "xh", "yi", "yo", "zu"];

    City[] public cities;
    bool[] public animation; // show GIF
    string[] public font;
    string public ipfsPrefix; // for GIF folder on IPFS

    constructor () {
        ipfsPrefix="";
    }

    function mint(string[] calldata _names, int _zoneDiff, uint8[] calldata _translate) public onlyOwner {
        cities.push(City(_names, _zoneDiff, 21, _translate)); // list(googletrans.LANGUAGES)[21] = en

        animation.push(false);
        font.push('Courier');
    }

    function setIPFSPrefix(string memory _prefix) public onlyOwner{
        ipfsPrefix= _prefix;
    }

    function tokenURI(uint256 tokenId, bool revealed) public view onlyOwner returns (string memory) {
        City storage city= cities[tokenId];

        if(revealed){
            bytes memory animation_url='';
            if(animation[tokenId] && bytes(ipfsPrefix).length>0){
                animation_url= abi.encodePacked(', "animation_url": "', ipfsPrefix, city.names[city.translate[21]], '.gif"');
            }

            int diff=city.zoneDiff;
            bytes memory timeString;
            if(diff<0){
                diff= -diff;
            }
            uint256 _temp= uint(diff)/60;
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
                Base64.encode(bytes(_buildImage(tokenId, revealed))),
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
            Base64.encode(bytes(_buildImage(tokenId, revealed))),
            '", "designer": "CD", "attributes": [{"trait_type": "Names","value": "',
            uint256(city.names.length).toString(),
            '"},{"trait_type": "Main language","value": "',
            LANG[city.mainLang],
            '"}]}'))))));
    }

    function showAnimation(uint256 tokenId, bool _show) external onlyOwner {
        require(bytes(ipfsPrefix).length>0, "Admin has not set the ipfs prefix");
        animation[tokenId] = _show;
    }

    function setFont(uint256 tokenId, string calldata _font) external onlyOwner {
        font[tokenId] = _font;
    }
    
    function getFont(uint256 tokenId) view external returns (string memory) {
        return font[tokenId];
    }
    function setMainLang(uint256 tokenId, string calldata lang) external onlyOwner {
        for(uint8 i=0; i< LANG.length; i++){
            if(_stringEqu(bytes(LANG[i]), bytes(lang))){
                cities[tokenId].mainLang= i;
                return;
            }
        }

        revert("No this lang in the lang list");
    }

    function getMainLang(uint256 tokenId) view external returns(string memory) {
        return LANG[cities[tokenId].mainLang];
    }
    function getNames(uint256 tokenId) view  external returns (string [] memory){
        return cities[tokenId].names;
    }

    function getLangs(uint256 tokenId) view external returns (uint8 [] memory){
        return cities[tokenId].translate;
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

        // Rest translation text
        parts[2]="";
        uint256 totalNames= city.names.length;
        for(uint256 i=0; i<totalNames; i++){
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

///////////////////////// Internal Functions /////////////////////////////////////////////
    function _buildImage(uint256 tokenId, bool revealed) view internal returns (string memory) {
        City storage city= cities[tokenId];
        
        if(!revealed) {
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
    function _stringEqu(bytes memory a, bytes memory b) pure internal returns (bool){
        if(bytes(a).length != bytes(b).length) {
            return false;
        } else {
            return keccak256(a) == keccak256(b);
        }
    }
}