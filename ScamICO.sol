pragma solidity ^0.4.16;

interface token {
    function transfer(address receiver, uint amount) public;
}

contract ScamICO {
    address public beneficiary; // Wallet to send funding to
    uint public fundingGoal;    // Amount needed to raise
    uint public amountRaised;
    uint public deadline; // how long ICO goes for
    uint public price; // cost of token
    token public tokenReward;
    mapping(address => uint256) public balanceOf;
    bool fundingGoalReached = false;
    bool crowdsaleClosed = false;

    event GoalReached(address recipient, uint totalAmountRaised);
    event FundTransfer(address backer, uint amount, bool isContribution);

    /**
    * Constructor function to set up owner
    */

    function ScamICO(address ifSuccessfulSendTo, uint fundingGoalInEthers, uint durationInMinutes,
        uint etherCostOfEachToken, address addressOfTokenUsedAsReward) public {
        beneficiary = ifSuccessfulSendTo;
        fundingGoal = fundingGoalInEthers * 1 ether;
        deadline = now + durationInMinutes * 1 minutes;
        price = etherCostOfEachToken * 1 ether;
        tokenReward = token(addressOfTokenUsedAsReward);
    }

    /**
    * no name function === default function called whenever anyone sends fund to a contract
    */
    function () payable public {
        require(!crowdsaleClosed); // crowdsale must be ongoing
        uint amount = msg.value;
        balanceOf[msg.sender] += amount;
        amountRaised += amount;
        tokenReward.transfer(msg.sender, amount / price);
        FundTransfer(msg.sender, amount, true);
    }

    modifier afterDeadline() {
        if (now >= deadline) _;
    }

    /**
    * check if goal was reached and end campaign if goal reached, or time limit has been reached
    */

    function checkGoalReached() afterDeadline public{
        fundingGoalReached = true;
        GoalReached(beneficiary, amountRaised);
        crowdsaleClosed = true;
    }

    /**
    * Withdraw funds after goal / time limit has been reached
    */
    function safeWithdrawal() afterDeadline public {
        if (beneficiary == msg.sender && fundingGoalReached) {
            if (beneficiary.send(amountRaised)) {
                FundTransfer(beneficiary, amountRaised, false);
            } else {
                fundingGoalReached = false;
            }
        }
    }
}
