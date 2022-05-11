//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./Staking.sol";

contract Taco is ERC20, Ownable, StakeableChamber{

    constructor() ERC20("TKN", "TKN") {
        _mint(msg.sender, 10_000_000_000 * 10**18 );
    }

    function decimals() public view virtual override returns (uint8) {
        return 9;
    }    

    function mint(address _to, uint256 _amount) external onlyOwner{
        _mint(_to, _amount);
    }

    function burn(address _from, uint256 _amount) external onlyOwner{
        _burn(_from, _amount);
    }    

    function stake(uint256 _amount) public {
      
      require(_amount < balanceOf(msg.sender), "TKN Token: Cannot stake more than you own");

        _stake(_amount);
                
        _burn(msg.sender, _amount);
    }

    function unStake(uint256 _stakeID) public {
      
        require(_stakeID < stakeholders[stakes[msg.sender]].address_stakes.length, "TKN Token: Cannot unstake");
        uint256 rewardAmount = calculateStakeReward(stakeholders[stakes[msg.sender]].address_stakes[_stakeID]);
        _mint(msg.sender, rewardAmount);  
        _unstake(_stakeID);
                
    }
    
}
