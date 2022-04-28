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

library DateTime {

    uint constant SECONDS_PER_DAY = 24 * 60 * 60;
    uint constant SECONDS_PER_HOUR = 60 * 60;
    uint constant SECONDS_PER_MINUTE = 60;

    function getHour() internal view returns (uint hour) {
        uint secs = block.timestamp % SECONDS_PER_DAY;
        hour = secs / SECONDS_PER_HOUR;
    }
    function getMinute() internal view returns (uint minute) {
        uint secs = block.timestamp % SECONDS_PER_HOUR;
        minute = secs / SECONDS_PER_MINUTE;
    }
}