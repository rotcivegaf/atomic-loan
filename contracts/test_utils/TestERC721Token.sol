pragma solidity ^0.6.1;

import "./ERC721Base.sol";


contract TestERC721Token is ERC721Base {
    function generate(address _beneficiary, uint256 _assetId) external {
        _generate(_beneficiary, _assetId);
    }
}