// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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


import "@openzeppelin/contracts/utils/Strings.sol";
import "./Random.sol";

library SVG {
    using Strings for uint256;
    function head(string calldata fontFamily, string calldata fontWeight) public pure returns (bytes memory) {
        return abi.encodePacked('<svg baseProfile="tiny" height="500" width="500" xmlns="http://www.w3.org/2000/svg"><style>text {font-family:',
                    fontFamily, 
                    ';font-weight:',
                    fontWeight,
                    '}</style>');
    }

    function tail() public pure returns (bytes memory){
        return '</svg>';
    }

    function rect(string calldata hsl) public pure returns (bytes memory){
        return abi.encodePacked('<rect fill="hsl(',
                                hsl,
                                ')" height="500" width="500" x="0" y="0"/>');
    }
    function text(string calldata hsl, 
                    string calldata fontSize, 
                    uint256 x, uint256 y,
                    string calldata text_content) public view returns (bytes memory){
                        string memory X= x.toString();
                        string memory Y= y.toString();
                        string memory range=(x+Random.randrange(10, x)).toString();
                        string memory speed= Random.randrange(10, x).toString();
                        bytes memory animation= abi.encodePacked('<animate attributeName="x" values="',
                                X,
                                ';', range, 
                                ';', X,
                                '" dur="',
                                speed,
                                's" repeatCount="indefinite"/></text>'
                                );

                        return abi.encodePacked('<text fill="hsl(',
                                hsl,
                                ')" font-size="',
                                fontSize,
                                '" x="', X,
                                '" y="', Y,
                                '">',
                                text_content,
                                animation
                                );   
    }

    function textMiddle(string calldata hsl, 
                    string calldata fontSize,
                    string calldata text_content) public pure returns (bytes memory){
                        return abi.encodePacked('<g><text id="tx" fill="hsl(',
                                hsl,
                                ')" font-size="',
                                fontSize,
                                '" x="250" y="250" style="text-anchor: middle">',
                                text_content,
                                '<animate attributeName="y" values="200;300;200" dur="15s" repeatCount="indefinite"/></text><animateTransform attributeName="transform" begin="tx.click" dur="0.1s" type="scale" from="1" to="1.1" repeatCount="1"/></g>');   
    }
}