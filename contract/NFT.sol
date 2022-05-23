//SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.5.0/contracts/token/ERC721/ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.5.0/contracts/ownership/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.5.0/contracts/drafts/Counters.sol";

contract ChicCat is ERC721, Ownable {
    using Counters for Counters.Counter;
    string public fileExtention = ".json";
    using Strings for uint256;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("ChicCat", "CAT") {}

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://QmNYtTUWY6xrfdUu1zVV1sw2Bk8f9NbE3SyT7JzwhLAeMu/";
    }

    function safeMint(address to) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }

      function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString(), fileExtention)) : "";
    }

    function batchMint(address to, uint amount) public onlyOwner{
        for (uint i = 0; i < amount; i++) {
            safeMint(to);
        }
    }
}
