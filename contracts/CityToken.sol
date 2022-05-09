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

    struct City {
        string[] names;
        int256 zoneDiff; // timezone diff in hours
        uint8[] translate;
    }

    struct Argument {
        string name;
        string font;
        uint8 mainLang;
        bool showAnimation;
    }
    string[] public LANG = [
        "af",
        "sq",
        "am",
        "ar",
        "hy",
        "az",
        "eu",
        "be",
        "bn",
        "bs",
        "bg",
        "ca",
        "ceb",
        "ny",
        "zh-cn",
        "zh-tw",
        "co",
        "hr",
        "cs",
        "da",
        "nl",
        "en",
        "eo",
        "et",
        "tl",
        "fi",
        "fr",
        "fy",
        "gl",
        "ka",
        "de",
        "el",
        "gu",
        "ht",
        "ha",
        "haw",
        "iw",
        "he",
        "hi",
        "hmn",
        "hu",
        "is",
        "ig",
        "id",
        "ga",
        "it",
        "ja",
        "jw",
        "kn",
        "kk",
        "km",
        "ko",
        "ku",
        "ky",
        "lo",
        "la",
        "lv",
        "lt",
        "lb",
        "mk",
        "mg",
        "ms",
        "ml",
        "mt",
        "mi",
        "mr",
        "mn",
        "my",
        "ne",
        "no",
        "or",
        "ps",
        "fa",
        "pl",
        "pt",
        "pa",
        "ro",
        "ru",
        "sm",
        "gd",
        "sr",
        "st",
        "sn",
        "sd",
        "si",
        "sk",
        "sl",
        "so",
        "es",
        "su",
        "sw",
        "sv",
        "tg",
        "ta",
        "te",
        "th",
        "tr",
        "uk",
        "ur",
        "ug",
        "uz",
        "vi",
        "cy",
        "xh",
        "yi",
        "yo",
        "zu"
    ];

    mapping(string => City) public cityMap;
    string public ipfsPrefix; // for GIF folder on IPFS

    constructor() {
        ipfsPrefix = "";
    }

    function mint(
        string[] calldata _names,
        int256 _zoneDiff,
        uint8[] calldata _translate
    ) public onlyOwner {
        cityMap[_names[_translate[21]]] = City(_names, _zoneDiff, _translate);
    }

    function setIPFSPrefix(string memory _prefix) public onlyOwner {
        ipfsPrefix = _prefix;
    }

    function uriString(
        string calldata name,
        string calldata font,
        uint8 mainLang,
        bool showAnimation,
        bool revealed
    ) external view onlyOwner returns (bytes memory) {
        if (revealed) {
            Argument memory argument = Argument(
                name,
                font,
                mainLang,
                showAnimation
            );

            return _buildMetaData(argument);
        } else {
            return _buildUnvealedMetadata();
        }
    }

    function getNames(string calldata name)
        external
        view
        returns (string[] memory)
    {
        return cityMap[name].names;
    }

    function getLangs(string calldata name)
        external
        view
        returns (uint8[] memory)
    {
        return cityMap[name].translate;
    }

    function svgString(
        string memory name,
        string memory font,
        uint8 mainLang,
        uint256 nowHour,
        uint256 nowMin
    ) public view returns (bytes memory) {
        bytes[6] memory parts;
        City memory city = cityMap[name];

        uint256 degree = nowHour > 12
            ? 200 - (nowHour * 100) / 12
            : (nowHour * 100) / 12;

        // SVG Template, with rect backgroud
        parts[0] = SVG.head(font, "700");
        parts[1] = SVG.rect(
            string(abi.encodePacked("0 0% ", degree.toString(), "%"))
        );

        // Rest translation text
        parts[2] = "";
        uint256 totalNames = city.names.length;
        for (uint256 i = 0; i < totalNames; i++) {
            uint256 size;
            uint256 x_pos;
            uint256 y_pos;

            if (i == mainLang) {
                continue;
            }
            size = Random.randrange(
                uint256(250 / totalNames),
                uint256(1250 / totalNames),
                i << 2
            );
            x_pos =
                ((i % (totalNames / 10)) * 5000) /
                totalNames +
                Random.randrange(30, i << (2 + 1));
            y_pos =
                ((i + 1) * 500) /
                totalNames +
                Random.randrange(30, i << (2 + 2));
            if (y_pos > 480) {
                y_pos = 480 - Random.randrange(30, i << (2 + 2));
            }

            parts[2] = abi.encodePacked(
                parts[2],
                SVG.text(
                    string(
                        abi.encodePacked(
                            Random.randrange(360, i << (2 + 3)).toString(),
                            " 100% ",
                            (100 - degree).toString(),
                            "%"
                        )
                    ),
                    size.toString(),
                    x_pos,
                    y_pos,
                    city.names[i]
                )
            );
        }

        // Main Lang text
        parts[3] = SVG.textMiddle(
            string(
                abi.encodePacked(
                    Random.randrange(360, 129).toString(),
                    " 100% ",
                    (100 - degree).toString(),
                    "%"
                )
            ),
            "70",
            city.names[city.translate[mainLang]]
        );
        // Timestamp
        string memory hourString;
        if (nowHour < 10) {
            hourString = string(abi.encodePacked("0", nowHour.toString()));
        } else {
            hourString = string(abi.encodePacked(nowHour.toString()));
        }
        string memory minString;
        if (nowMin < 10) {
            minString = string(abi.encodePacked("0", nowMin.toString()));
        } else {
            minString = string(abi.encodePacked(nowMin.toString()));
        }

        parts[4] = SVG.text(
            string(
                abi.encodePacked("180 100% ", (100 - degree).toString(), "%")
            ),
            "15",
            450,
            15,
            string(abi.encodePacked(hourString, ":", minString))
        );
        parts[5] = SVG.tail();
        return
            abi.encodePacked(
                parts[0],
                parts[1],
                parts[2],
                parts[3],
                parts[4],
                parts[5]
            );
    }

    ///////////////////////// Internal Functions /////////////////////////////////////////////
    function _buildUnvealedMetadata() internal view returns (bytes memory) {
        return
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(
                    abi.encodePacked(
                        '{"name": "NOT REVEALED',
                        '", "description":"The **Civilization City NFT**, dynamic, local time sensitive, programmable, rare!", "image_data": "',
                        "data:image/svg+xml;base64,",
                        Base64.encode(
                            bytes(
                                abi.encodePacked(
                                    SVG.head("Courier", "700"),
                                    SVG.rect("0 100% 100%"),
                                    SVG.text(
                                        "0, 0, 0%",
                                        "82",
                                        100,
                                        239,
                                        "City"
                                    ),
                                    SVG.text(
                                        "0, 0, 0%",
                                        "39",
                                        127,
                                        277,
                                        "Civilization"
                                    ),
                                    SVG.tail()
                                )
                            )
                        ),
                        '", "designer": "Dr Zu."}]}'
                    )
                )
            );
    }

    function _buildMetaData(Argument memory argument)
        internal
        view
        returns (bytes memory)
    {
        City memory city = cityMap[argument.name];

        bytes memory timeString;
        unchecked {
            int256 diff = city.zoneDiff;

            if (diff < 0) {
                diff = -diff;
            }
            diff =
                int256(DateTime.getHour() * 60 + DateTime.getMinute()) +
                city.zoneDiff;

            if (diff < 0) {
                diff += 1440; //24 hours = 1440 mins
            }

            uint256 _temp = uint256(diff) / 60;
            if (_temp < 10) {
                timeString = abi.encodePacked("0", _temp.toString());
            } else {
                timeString = bytes(_temp.toString());
            }
            _temp = uint256(diff) % 60;
            if (_temp < 10) {
                timeString = abi.encodePacked(
                    timeString,
                    ":0",
                    _temp.toString()
                );
            } else {
                timeString = abi.encodePacked(
                    timeString,
                    ":",
                    _temp.toString()
                );
            }
        }
        bytes memory animation_url = "";
        if (argument.showAnimation && bytes(ipfsPrefix).length > 0) {
            animation_url = abi.encodePacked(
                ', "animation_url": "',
                ipfsPrefix,
                argument.name,
                '.gif"'
            );
        }

        int256 diff2 = int256(DateTime.getHour() * 60 + DateTime.getMinute()) +
            city.zoneDiff;
        if (diff2 < 0) {
            diff2 += 1440; //24 hours = 1440 mins
        }

        bytes memory meta = abi.encodePacked(
            '{"name": "',
            city.names[city.translate[argument.mainLang]],
            '", "description":"The **Civilization City NFT**, dynamic, local time sensitive, programmable, rare!", "image_data": "',
            "data:image/svg+xml;base64,",
            Base64.encode(
                svgString(
                    argument.name,
                    argument.font,
                    argument.mainLang,
                    uint256(diff2) / 60,
                    uint256(diff2) % 60
                )
            ),
            '"',
            animation_url,
            ', "designer": "Dr. Zu.", "attributes": [{"trait_type": "Names","value": "',
            uint256(city.names.length).toString(),
            '"},{"trait_type": "Main language","value": "',
            LANG[argument.mainLang],
            '"},{"trait_type": "Time Zone(UTC)","value": "',
            city.zoneDiff < 0 ? "-" : "+",
            timeString,
            '"}]}'
        );

        return
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(meta)
            );
    }

    function langId(string calldata lang) public view returns (uint8) {
        uint8 length = uint8(LANG.length);

        for (uint8 i = 0; i < length; i++) {
            if (_stringEqu(bytes(LANG[i]), bytes(lang))) {
                return i;
            }
        }
        revert("Invalid MainLang");
    }

    function _stringEqu(bytes memory a, bytes memory b)
        internal
        pure
        returns (bool)
    {
        if (bytes(a).length != bytes(b).length) {
            return false;
        } else {
            return keccak256(a) == keccak256(b);
        }
    }
}
