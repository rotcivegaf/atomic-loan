pragma solidity ^0.6.1;


library SafeMath {
    using SafeMath for uint256;

    function add(uint256 x, uint256 y) internal pure returns (uint256) {
        uint256 z = x + y;
        require(z >= x, "Add overflow");
        return z;
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256) {
        require(x >= y, "Sub overflow");
        return x - y;
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256) {
        if (x == 0) {
            return 0;
        }

        uint256 z = x * y;
        require(z/x == y, "Mul overflow");
        return z;
    }

    function div(uint256 x, uint256 y) internal pure returns (uint256) {
        require(y != 0, "Div by zero");
        return x / y;
    }

    function muldiv(uint256 x, uint256 y, uint256 z) internal pure returns (uint256) {
        require(z != 0, "div by zero");
        return x.mul(y) / z;
    }
}
