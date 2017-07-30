pragma solidity ^0.4.11;
contract token { function mintToken(address target, uint256 mintedAmount);}

contract Crowdsale {
    address public beneficiary;
    uint public fundingGoal; uint public amountRaised; uint public deadline; uint public price;
    token public tokenReward;
    mapping(address => uint256) public balanceOf;
    bool fundingGoalReached = false;
    event GoalReached(address beneficiary, uint amountRaised);
    event FundTransfer(address backer, uint amount, bool isContribution);
    bool crowdsaleClosed = false;

    function Crowdsale(
        address ifSuccessfulSendTo,
        uint fundingGoalInEthers,
        uint durationInMinutes,
        uint finneyCostOfEachToken,
        token addressOfTokenUsedAsReward) {
        beneficiary = ifSuccessfulSendTo;
        fundingGoal = fundingGoalInEthers * 1 ether;
        deadline = now + durationInMinutes * 1 minutes;
        price = finneyCostOfEachToken * 1 finney;
        tokenReward = token(addressOfTokenUsedAsReward);
    }

    function () payable {
        if (crowdsaleClosed) revert();
        uint amount = msg.value;
        balanceOf[msg.sender] = amount;
        amountRaised += amount;
        tokenReward.mintToken(msg.sender, amount / price);
        FundTransfer(msg.sender, amount, true);
    }

    modifier afterDeadline() { if (now >= deadline) _; }

    function checkGoalReached() afterDeadline {
        if (amountRaised >= fundingGoal){
            fundingGoalReached = true;
            GoalReached(beneficiary, amountRaised);
        }
    }

    function safeWithdrawal() {
        if (beneficiary == msg.sender) {
            if (beneficiary.send(amountRaised)) {
                amountRaised = 0;
                FundTransfer(beneficiary, amountRaised, false);
            } else {
                fundingGoalReached = false;
            }
        }
    }
}
