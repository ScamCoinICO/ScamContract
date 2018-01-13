pragma solidity ^0.4.18;

interface token {
    function transfer(address receiver, uint amount) public;
}

contract ScamICO {
    token public tokenReward; // token being sold
    address public beneficiary; // Wallet to send funding to
    uint256 public amountRaised;
    uint256 public ICOEndTime; // how long ICO goes for
    uint256 public price; // cost of token
    mapping(address => uint256) public balanceOf;

    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    function ScamICO(uint256 _lengthOfICO, uint256 _price, address _beneficiary, address _tokenAddress) public {
        require(_lengthOfICO != 0);
        require(_beneficiary != 0x0);
        require(_price > 0);

        price = _price;
        ICOEndTime = now + _lengthOfICO * 1 minutes;
        beneficiary = _beneficiary;
        tokenReward = token(_tokenAddress);
    }

    function () external payable {
        buyTokens(msg.sender);
    }

    function buyTokens(address sender) public payable {
        require(sender != address(0));
        require(validPurchase());

        uint256 etherAmount = msg.value;
        uint256 tokens = etherAmount * price;
        amountRaised += etherAmount;

        tokenReward.transfer(sender, tokens);
        TokenPurchase(sender, beneficiary, etherAmount, tokens);
    }

    function forwardFunds() internal {
        beneficiary.transfer(msg.value);
    }

    function validPurchase() internal view returns (bool) {
        bool withinPeriod = now <= ICOEndTime;
        bool nonZeroPurchase = msg.value != 0;
        return withinPeriod && nonZeroPurchase;
    }

    function hasEnded() public view returns (bool) {
        return now > ICOEndTime;
    }

}
