// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.0;

contract GasContract {
    mapping(address => uint256) public balances;
    mapping(address => uint256) public whitelist;
    mapping(address => uint256) public whiteListStruct;
    address[5] public administrators;

    event AddedToWhitelist(address userAddress, uint256 tier);
    event WhiteListTransfer(address indexed);

    modifier onlyOwner() {
        if (msg.sender != administrators[4]) {
            revert();
        } else {
            _;
        }
    }

    constructor(address[] memory _admins, uint256 totalSupply) {
        balances[msg.sender] = totalSupply;
        for (uint256 ii = 0; ii < 5; ii++) {
            administrators[ii] = _admins[ii];
        }
    }

    function balanceOf(address _user) public view returns (uint256 balance_) {
        return balances[_user];
    }

    function transfer(
        address _recipient,
        uint256 _amount,
        string calldata _name
    ) public returns (bool status_) {
        balances[msg.sender] -= _amount;
        balances[_recipient] += _amount;
        return true;
    }

    function addToWhitelist(address _userAddrs, uint256 _tier)
        public
        onlyOwner
    {
        require(
            _tier < 255,
            "Gas Contract - addToWhitelist function -  tier level should not be greater than 255"
        );
        if (_tier > 3) {
            whitelist[_userAddrs] = 3;
        } else {
            whitelist[_userAddrs] = _tier;
        }
        emit AddedToWhitelist(_userAddrs, _tier);
    }

    function whiteTransfer(
        address _recipient,
        uint256 _amount
    ) public {
        whiteListStruct[msg.sender] = _amount;
        balances[msg.sender] -= (_amount - whitelist[msg.sender]);
        balances[_recipient] += (_amount - whitelist[msg.sender]);
        
        emit WhiteListTransfer(_recipient);
    }

    function getPaymentStatus(address sender) public view returns (bool, uint256) {        
        return (true, whiteListStruct[sender]);
    }

    receive() external payable {
        payable(msg.sender).transfer(msg.value);
    }

}