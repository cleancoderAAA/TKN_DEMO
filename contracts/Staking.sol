// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract StakeableChamber {

    constructor() {
        stakeholders.push();
    }
   
    struct Stake{
        address user;
        uint256 amount;
        uint256 since;
        uint256 claimable;
    }
    
    struct Stakeholder{
        address user;
        Stake[] address_stakes;        
    }   

    struct StakingSummary{
        uint256 total_amount;
        uint256 total_claim;
        Stake[] stakes;
    }

    Stakeholder[] internal stakeholders;
          
    mapping(address => uint256) internal stakes;
    
    event Staked(address indexed user, uint256 amount, uint256 index, uint256 timestamp);
    event unStaked(address indexed user, uint256 amount, uint256 index, uint256 timestamp);
    uint256 internal rewardPerDay = 100;

    function _addStakeholder(address staker) internal returns (uint256){
        
        stakeholders.push();
        uint256 userIndex = stakeholders.length - 1;
        stakeholders[userIndex].user = staker;
        stakes[staker] = userIndex;
        return userIndex; 
        
    }

    function _stake(uint256 _amount) internal{
        
        require(_amount > 0, "Cannot stake nothing");
        uint256 index = stakes[msg.sender];
        uint256 timestamp = block.timestamp;
        if(index == 0){
            index = _addStakeholder(msg.sender);
        }
        stakeholders[index].address_stakes.push(Stake(msg.sender, _amount, timestamp, 0));
        emit Staked(msg.sender, _amount, index,timestamp);

    }

    function _unstake( uint256 _stakeID) internal{        
        
        stakeholders[stakes[msg.sender]].address_stakes[_stakeID].amount = 0;
        stakeholders[stakes[msg.sender]].address_stakes[_stakeID].since = block.timestamp;               
        emit unStaked(msg.sender, stakeholders[stakes[msg.sender]].address_stakes[_stakeID].amount, _stakeID,block.timestamp);

    }

    function calculateStakeReward(Stake memory _current_stake) internal view returns(uint256){

        return (((block.timestamp - _current_stake.since) / 1 days) * _current_stake.amount) / rewardPerDay;

    }

    function stakeAmount(address _staker) public view returns(uint256){
        
       uint256 totalStakeAmount; 
        StakingSummary memory summary = StakingSummary(0, 0, stakeholders[stakes[_staker]].address_stakes);
        for (uint256 s = 0; s < summary.stakes.length; s += 1){
            totalStakeAmount = totalStakeAmount+summary.stakes[s].amount;
        }
        return totalStakeAmount;

    }

    function getStakeTimesAndAmount(address _staker) public view returns(uint256 totalTimes , uint256[] memory StakeAmounts, uint256[] memory RewardAmounts){
        
        StakingSummary memory summary = StakingSummary(0, 0, stakeholders[stakes[_staker]].address_stakes);
        for (uint256 s = 0; s < summary.stakes.length; s += 1){
            RewardAmounts[s] = calculateStakeReward(summary.stakes[s]);
            StakeAmounts[s] = summary.stakes[s].amount;
        }

        totalTimes = summary.stakes.length;        

    }

    function hasStake(address _staker) public view returns(StakingSummary memory){
        
        uint256 totalStakeAmount; 
        uint256 totalStakeClaim; 
        StakingSummary memory summary = StakingSummary(0, 0, stakeholders[stakes[_staker]].address_stakes);
        for (uint256 s = 0; s < summary.stakes.length; s += 1){
            uint256 availableReward = calculateStakeReward(summary.stakes[s]);
            summary.stakes[s].claimable = availableReward;
            totalStakeAmount = totalStakeAmount+summary.stakes[s].amount;
            totalStakeClaim = totalStakeClaim+summary.stakes[s].claimable;
        }
        summary.total_amount = totalStakeAmount;
        summary.total_claim = totalStakeClaim;
        return summary;

    }

    function getStakers() public view returns(address[] memory){
        address[] memory buffer = new address[](stakeholders.length-1);
        for(uint256 i = 1; i < stakeholders.length; i+=1){
            buffer[i-1] = stakeholders[i].user;
        }
        return buffer;
    }   
   
    
}