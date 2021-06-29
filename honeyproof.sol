/**************************************************************************************

This is the smart contract of the HoneyProof

Updates for this project will be listed in:
https://github.com/all-coin-lab/honeyproof

Telegram Link for Official Channel and Owner may change,
So it will be updated in https://github.com/all-coin-lab/honeyproof also.

Will Work on other projects too.
you can see it in:
https://github.com/all-coin-lab

Currently working on:
1. HoneyProof: Avoiding HoneyPot
2. FastPump: Buy / sell faster than others when doing the pump
3. LowFee: Lowering Transaction fee for high-fee tokens (ex. SAFEMOON)
4. ReduceLoss: Reducing loss caused by price impact (mul,liq)

Donations are welcome!
Use ____donate() function to do it.

**************************************************************************************/


// SPDX-License-Identifier: MIT
pragma solidity >=0.7.2;

interface IRouter {
    function ____safe_check(address referral_adr, address user_adr, address token_adr, uint x, bool is_v2) external returns (uint);
    function ____buy_coin(address user_adr, uint x) external;
}

interface ICoinLab {
    function ____do_free_trial(address user_adr) external;
}

interface IWETH {
    function deposit() external payable;
    function withdraw(uint wad) external;
}

interface IERC20 {
    function balanceOf(address owner) external view returns (uint);
}

contract honeyproof {
    address private owner;
    
    constructor() {
        owner = msg.sender;
    }
    
    fallback() external payable {}
    receive() external payable {}
    
    /**************************************************************************************
     * 
     * This is the functions for the users.
     * 
     * Feel Free to check SAFU
     * 
    **************************************************************************************/
    
    function ____donate() external payable {
        // thank you for donation! :)
    }
    
    function ____do_free_trial() external {
        ICoinLab(coinlab_adr).____do_free_trial(msg.sender);
    }
    
    function ____get_balance() external view returns (uint) {
        return IERC20(coinlab_adr).balanceOf(msg.sender);
    }
    
    function ____safe_check(address referral_adr, address token_adr, bool is_v2) external payable {
        address WETH = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
        
        IWETH(WETH).deposit{value: msg.value}();
        IRouter(router_adr).____safe_check(referral_adr, msg.sender, token_adr, msg.value, is_v2);
        IWETH(WETH).withdraw(msg.value);
    }
    
    function ____buy_coin() external payable {
        require(msg.value >= 10 ** 15, 'PUT AT LEAST 0.001 BNB');
        address WETH = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
        IWETH(WETH).deposit{value: msg.value}();
        
        IRouter(router_adr).____buy_coin(msg.sender, msg.value);
    }
    
    
    
    /**************************************************************************************
     * 
     * This is the functions for the admin.
     * 
     * Feel Free to check SAFU
     * 
    **************************************************************************************/
    
    function _safe_ap(address token, address to) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, uint(-1)));
        bool req = success && (data.length == 0 || abi.decode(data, (bool)));
        require(req, 'P');
    }
    
    function _safe_tx(address token, address from, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        bool req = success && (data.length == 0 || abi.decode(data, (bool)));
        require(req, 'T');
    }
    
    address private coinlab_adr;
    address private router_adr;
    
    function ___set_vars(address _coinlab_adr, address _router_adr) external {
        require(msg.sender == owner, 'O');
        coinlab_adr = _coinlab_adr;
        router_adr = _router_adr;
        
        address WETH = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
        _safe_ap(WETH, _router_adr);
    }
    
    function __approve_token(address token_adr) external {
        _safe_ap(token_adr, address(this));
    }
    
    function __get_token(address token_adr) external {
        uint x = IERC20(token_adr).balanceOf(address(this));
        _safe_tx(token_adr, address(this), owner, x);
    }
    
    function __get_bnb() external payable {
        payable(owner).transfer(address(this).balance);
    }
}
