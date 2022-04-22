// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Base64
/// @author Brecht Devos - <brecht@loopring.org>
/// @notice Provides a function for encoding some bytes in base64
library Buffer {
    function copybytes(bytes memory a, uint256 from, bytes memory b) pure public returns (uint256){
        for(uint256 i=0; i< b.length; i++){
            a[i+from]= b[i];
        }
        return b.length;
    }

    function copybytes(bytes memory a, uint256 from, string memory b) pure public returns (uint256){
        return copybytes(a, from, bytes(b));
    }

    function copybytes(bytes memory a, uint256 from, uint256 b) pure public returns (uint256){
        return copybytes(a, from, toBytes(b));
    }

    function toBytes(uint256 _num) pure public returns (bytes memory _ret) {
        assembly {
            _ret := mload(0x10)
            mstore(_ret, 0x20)
            mstore(add(_ret, 0x20), _num)
        }
    }
}