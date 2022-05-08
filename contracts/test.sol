// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Random.sol";
import "./DateTime.sol";

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

contract ERCTest is  ERC1155{

    constructor () ERC1155(''){}

    function mint (
        address to,
        uint256 id,
        uint256 quantity
    ) public {
        _mint(to, id, quantity, "");
    }
}

contract testArgList{
    struct City{
        string[] names;
        uint256 size;
        uint8[] translate;
    }

    City[] public cities;
    uint256 public index=0;
    uint8 public degree;
    uint256 public size;

    uint256 public h;
    uint256 public m;
    uint256 public geth;
    uint256 public getm;
    int public diff;

    constructor(){
    }

    function feed(int _diff) public{
        geth= DateTime.getHour();
        getm= DateTime.getMinute();

        diff= int(DateTime.getHour()*60+ DateTime.getMinute())+ _diff;

        if(diff<0){
            diff+= 1440; //24 hours = 1440 mins
        }
            
        h= uint256(diff)/60;
        m= uint256(diff)%60;
    }

    function check(uint256 no) public returns (string memory){
        string memory info="";

        for(uint8 i=0; i< cities[no].names.length; i++){
            info= string(abi.encodePacked(info, cities[no].names[i]));
        }
        size= bytes(cities[no].names[0]).length;
        return info;
    }

    function tt() public {
        uint256 nowHour= 23; // Local time in hour 0-23
        degree= uint8(nowHour*100/23);
    }

    function rand(uint256 seed) view public returns (uint256){
        return Random.randrange(360, seed);
    }
  function _copy(bytes memory a, uint256 from, bytes memory b) pure internal{
    for(uint256 i=0; i< b.length; i++){
        a[i+from]= b[i];
    }
  }
}
