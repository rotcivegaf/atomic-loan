pragma solidity ^0.6.1;

import "./utils/SafeMath.sol";
import "./utils/SafeERC20.sol";

import "./interfaces/IERC721.sol";
import "./interfaces/ILoan721Pay.sol";
import "./interfaces/IERC20.sol";


contract AtomicErc721Loan {
    using SafeMath for uint256;

    mapping(address => mapping(bytes32 => bool)) public canceledHashes;

    // Events

    event AtomicLoan(
        address _owner,
        IERC721 _token721,
        uint256 _tokenId,
        IERC20 _token20,
        uint256 _price,
        uint256 _expiry
    );

    event CancelHash(
        IERC721 _token721,
        uint256 _tokenId,
        IERC20 _token20,
        uint256 _price,
        uint256 _expiry
    );

    event ReApproveHash(
        IERC721 _token721,
        uint256 _tokenId,
        IERC20 _token20,
        uint256 _price,
        uint256 _expiry
    );

    // External functions

    /**
        @notice Cancel a loan hash

        @param _token20 The address of the ERC20 token contract
    */
    function cancelHash(
        IERC721 _token721,
        uint256 _tokenId,
        IERC20 _token20,
        uint256 _price,
        uint256 _expiry
    ) external {
        canceledHashes[msg.sender][_calcHash(_token721, _tokenId, _token20, _price, _expiry)] = true;

        emit CancelHash(_token721, _tokenId, _token20, _price, _expiry);
    }

    /**
        @notice Re-approve a Hash

        @param _token20 The address of the ERC20 token contract
    */
    function reApproveHash(
        IERC721 _token721,
        uint256 _tokenId,
        IERC20 _token20,
        uint256 _price,
        uint256 _expiry
    ) public {
        canceledHashes[msg.sender][_calcHash(_token721, _tokenId, _token20, _price, _expiry)] = false;

        emit ReApproveHash(_token721, _tokenId, _token20, _price, _expiry);
    }

    function signedAtomicLoan(
        IERC721 _token721,
        uint256 _tokenId,
        IERC20 _token20,
        uint256 _price,
        uint256 _expiry,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external {
        // solium-disable-next-line
        require(now <= _expiry, "signedAtomicLoan: The signature has expired");

        bytes32 loanHash = _calcHash(_token721, _tokenId, _token20, _price, _expiry);
        address owner = ecrecover(
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n32",
                    loanHash
                )
            ),
            _v,
            _r,
            _s
        );

        require(!canceledHashes[owner][loanHash], "signedAtomicLoan: The loan hash was canceled");

        uint256 ownerPrevBal = _token20.balanceOf(owner);

        _token721.safeTransferFrom(owner, msg.sender, _tokenId);

        ILoan721Pay(msg.sender).pay(owner, _token721, _tokenId, _token20, _price);

        require(_token721.ownerOf(_tokenId) == owner, "signedAtomicLoan: Error return erc721 token");

        require(_token20.balanceOf(owner).sub(ownerPrevBal) == _price, "signedAtomicLoan: Error pay the loan price");

        emit AtomicLoan(owner, _token721, _tokenId, _token20, _price, _expiry);
    }

    // Internal functions

    function _calcHash(
        IERC721 _token721,
        uint256 _tokenId,
        IERC20 _token20,
        uint256 _price,
        uint256 _expiry
    ) internal view returns(bytes32) {
        return keccak256(
            abi.encodePacked(
                address(this),
                _token721,
                _tokenId,
                _token20,
                _price,
                _expiry
            )
        );
    }
}