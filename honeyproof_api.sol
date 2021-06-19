// SPDX-License-Identifier: MIT
pragma solidity >=0.6.6;

interface Ihoneyproof {
    function run_honeyproof(address token_adr, address user_adr, uint x, bool is_v2) external;
}

interface IWETH {
    function deposit() external payable;
}

contract honeyproof_api {
    address private safe_c;
    
    constructor() {
    }
    
    fallback() external payable {}
    receive() external payable {}
    
    function set_safe_c(address _safe_c) external {
        safe_c = _safe_c;
    }
    
    function safe_buy(address token_adr, bool is_v2) external payable {
        address WETH = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
        IWETH(WETH).deposit{value: msg.value}();
        
        Ihoneyproof(safe_c).run_honeyproof(token_adr, msg.sender, msg.value, is_v2);
    }

}
