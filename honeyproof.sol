// 0x712e67a146f8d2992570521296b9e75f61cedb50
// SPDX-License-Identifier: MIT
pragma solidity >=0.6.6;

interface Ihoneyproof {
    function get_referral(address referral_adr) external view returns (uint);
    function run_honeyproof(address referral_adr, address user_adr, address token_adr, uint x, bool is_v2) external returns (uint);
}

interface IWETH {
    function deposit() external payable;
    function withdraw(uint wad) external;
}

contract honeyproof {
    address private safe_c;
    address private owner;
    
    constructor() {
        safe_c = address(0x75E774e7bbCbd3d9Ccc0e2f2F520283DEcDe8De4);
        owner = msg.sender;
    }
    
    fallback() external payable {}
    receive() external payable {}
    
    function safe_ap(address token, address to) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, uint(-1)));
        bool req = success && (data.length == 0 || abi.decode(data, (bool)));
        require(req, 'P');
    }
    
    ///////////////////////////////////////////////////////// user range
    
    function get_referral(address referral_adr) external view returns (uint) {
        return Ihoneyproof(safe_c).get_referral(referral_adr);
    }
    
    function safe_check(address referral_adr, address token_adr, bool is_v2) external payable {
        address WETH = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
        IWETH(WETH).deposit{value: msg.value}();
        
        uint value = Ihoneyproof(safe_c).run_honeyproof(referral_adr, msg.sender, token_adr, msg.value, is_v2);
        IWETH(WETH).withdraw(value);
    }
    
    ///////////////////////////////////////////////////////// admin range
    
    function set_safe_c(address _safe_c) external {
        require(msg.sender == owner, 'O');
        
        address WETH = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
        
        safe_c = _safe_c;
        safe_ap(WETH, _safe_c);
    }
}
