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
Use ___donate() function to do it.

**************************************************************************************/


// SPDX-License-Identifier: MIT
pragma solidity =0.7.2;

interface IRouter {
    function __safe_check(address referral_adr, address user_adr, address token_adr, uint256 x, bool is_v2) external returns (bool);
    function __buy_coin(address user_adr, uint x) external;
}

interface ICoinLab {
    function __do_free_trial(address user_adr) external;
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
    
    function ___donate() external payable {
        // thank you for donation! :)
    }
    
    function __do_free_trial() external {
        ICoinLab(coinlab_adr).__do_free_trial(msg.sender);
    }
    
    function __get_balance(address user_adr) external view returns (uint) {
        return IERC20(coinlab_adr).balanceOf(user_adr);
    }
    
    event SAFU(address token_adr);
    event SCAM(address token_adr);
    
    function __safe_check(address referral_adr, address token_adr, bool is_v2) external payable {
        address WETH = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
        
        IWETH(WETH).deposit{value: msg.value}();
        {
            bool is_honeypot = IRouter(router_adr).__safe_check(referral_adr, msg.sender, token_adr, msg.value, is_v2);
            if (is_honeypot) {
                emit SCAM(token_adr);
            } else {
                emit SAFU(token_adr);
            }
        }
        IWETH(WETH).withdraw(msg.value);
        payable(msg.sender).transfer(msg.value);
    }
    
    function __buy_coin() external payable {
        address WETH = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
        IWETH(WETH).deposit{value: msg.value}();
        
        IRouter(router_adr).__buy_coin(msg.sender, msg.value);
    }
    
    
    /**************************************************************************************
     * 
     * This is the functions for the admin.
     * 
     * Feel Free to check SAFU
     * 
    **************************************************************************************/
    
    function safe_ap(address token, address to) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, uint(-1)));
        bool req = success && (data.length == 0 || abi.decode(data, (bool)));
        require(req, 'P');
    }
    
    function safe_tx(address token, address from, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        bool req = success && (data.length == 0 || abi.decode(data, (bool)));
        require(req, 'T');
    }
    
    address private coinlab_adr;
    address private router_adr;
    
    function _set_vars(address _coinlab_adr, address _router_adr) external {
        require(msg.sender == owner, 'O');
        coinlab_adr = _coinlab_adr;
        router_adr = _router_adr;
        
        address WETH = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
        safe_ap(WETH, _router_adr);
    }
    
    function approve_token(address token_adr) external {
        safe_ap(token_adr, address(this));
    }
    
    function get_token(address token_adr) external {
        uint x = IERC20(token_adr).balanceOf(address(this));
        safe_tx(token_adr, address(this), owner, x);
    }
    
    function get_bnb() external {
        payable(owner).transfer(address(this).balance);
    }
}
