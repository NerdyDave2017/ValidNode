// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract VLDIndex {

    // Contract name
    string public name = "VLDIndex";

    // Reward token
    IERC20 public vld;

    //  Contract owner
    address public owner;
    address public contractAddress;

    // Project wallets
    address public treasury;
    address public rewardPool;
    address public validReserve;
    address public operations;
    address public developerRights;
    address public transactionCharges;

    struct userClaimedRewards{
        uint256 duration;
        uint256 reward;
        uint256 stakingDate;
    }

    address[] public stakers;
    uint256 numberOfStakers;
    uint256 public minStakeAmount = 10000 * (10 ** 18);
    mapping(address => uint256) public stakingBalance;
    mapping(address => mapping(uint256 => userClaimedRewards)) public claimedRewards; // Stores data for every reward claimed by investor
    mapping(address => uint256 ) public withdrawalNumber;
    mapping(address => uint256 ) public duration;
    mapping(address => uint256 ) public nodesPurchased;
    mapping(address => bool) public hasStaked;
    mapping(address => bool) public isStaking;

    // Reward days
    uint256 day1 = 1 days; 
    uint256 day3 = 3 days; 
    uint256 day5 = 5 days; 
    uint256 day7 = 7 days; 
    uint256 day10 = 10 days; 
    uint256 day14 = 14 days; 
    uint256 day21 = 21 days; 
    uint256 day35 = 35 days; 
    uint256 day55 = 55 days; 


    

    // Every $VLD deposit would be split according to the following
    /**
    * 50% to treasury
    * 30% to rewardPool
    * 15% to validReserve
    * 4.4% to operations
    * 0.6% to developerRights
    * 0.5% external fee for transactions
    **/

    // Everyone who creates a node will be given at minimum 1% ROI per day
    /**
    * After 0 days of not claiming daily ROI = 1.00%
    * After 3 days of not claiming, daily ROI = 1.02% 
    * After 5 days of not claiming, daily ROI = 1.04% 
    * After 7 days of not claiming, daily ROI = 1.06% 
    * After 10 days of not claiming, daily ROI = 1.08%
    * After 14 days of not claiming, daily ROI = 1.10% 
    * After 21 days of not claiming, daily ROI = 1.15% 
    * After 35 days of not claiming, daily ROI = 1.25% 
    * After 55 days of not claiming, daily ROI = 1.35%
    **/

    

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    // Constructor 
    constructor (address _tokenAddress) {
        vld = IERC20(_tokenAddress);
        owner = msg.sender;
    }

    function transferOwnership( address _newOwner) public onlyOwner{
        require(_newOwner != 0x0000000000000000000000000000000000000000, "Owner cannot be a dead address" );
        owner = _newOwner;
    }

    // Set contract address after deployment
    function setContractAddress(address _contract) public onlyOwner {
        contractAddress = payable(_contract);
    }

    
    // Set project wallets

    function setTreasury(address _treasury) public onlyOwner  {
        treasury = payable(_treasury);
    }
    function setRewardPool(address _rewardPool) public onlyOwner {
        rewardPool = payable(_rewardPool);
    }
    function setValidReserve(address _validReserve) public onlyOwner {
        validReserve = payable(_validReserve);
    }
    function setOperations(address _operations) public onlyOwner {
        operations = payable(_operations);
    }
    function setDeveloperRights(address _developerRights) public onlyOwner {
        developerRights = payable(_developerRights);
    }
    function setTransactionCharges(address _transactionCharges) public onlyOwner {
        transactionCharges = payable(_transactionCharges);
    }

    // Get reward token balance 
    function balance(address sender) public view returns (uint256){
       return vld.balanceOf(sender);
    }

   

    // Stake tokens
    function depositTokens(uint256 amount) public payable {
        // Remember to call approve function on ERC20 contract to allow staking contract transfer tokens
        uint256 transactionFees = amount /100 / 10 * 5;
        require(amount >= minStakeAmount, "Minimum of 10000 VLD required for staking");
        require(amount + transactionFees <= balance(msg.sender), "Insufficient balance, amount and transaction fees should be provided");
    
        // Transfer 50% of amount to treasury
        uint256 treasuryAllocation = amount / 100 * 50;
        vld.transferFrom(msg.sender, treasury, treasuryAllocation);
        // Transfer 30% of amount to rewardPool
        uint256 rewardPoolAllocation = amount / 100 * 30;
        vld.transferFrom(msg.sender, rewardPool, rewardPoolAllocation);
        // Transfer 15% of amount to validReserve
        uint256 validReserveAllocation =  amount / 100 * 15;
        vld.transferFrom(msg.sender, validReserve, validReserveAllocation);
        // Transfer 4.4% of amount to operations
        uint256 operationsAllocation = amount  / 100 / 10 * 44;
        vld.transferFrom(msg.sender, operations, operationsAllocation);
        // Transfer 0.6% of amount to developerRights
        uint256 developerRightsAllocation = amount /100 / 10 * 6;
        vld.transferFrom(msg.sender, developerRights, developerRightsAllocation);
        // Transfer external  0.5% of amount to transactionCharges
        uint256 transactionChargesAllocation = amount / 100 / 10 * 5;
        vld.transferFrom(msg.sender, transactionCharges, transactionChargesAllocation);

        // Update staking balance 
        stakingBalance[msg.sender] = stakingBalance[msg.sender] + amount;

        if(!hasStaked[msg.sender]){
            stakers.push(msg.sender);
            numberOfStakers++;
        }
        

        // Update staking boolean, duration
        hasStaked[msg.sender] = true;
        isStaking[msg.sender] = true;
        duration[msg.sender] = block.timestamp; // stores number of seconds that have passed since January 1st 1970.
        nodesPurchased[msg.sender] = stakingBalance[msg.sender] + ( amount / minStakeAmount);
    }

    
    // Claim rewards
    function claimRewardTokens() public payable {
        // Check if msg.sender is a staker
        require(hasStaked[msg.sender],"The caller is not an investor");
        // Check if msg.sender isStaking
        require(isStaking[msg.sender],"The caller is not staking currently");
        // Check if staking balance greater than or equal to 10000 VLD
        require(stakingBalance[msg.sender] >= minStakeAmount, "Investor cannot stake less than 10000 VLD");
        // Check if duration of staker is >= 1 day 
        require(duration[msg.sender] >= day1, "Caller can not claim rewards earlier than a day");
        // Calculate staker's reward
        uint256 stakingDuration = block.timestamp - duration[msg.sender];
        uint256 investorBalance = stakingBalance[msg.sender];
        uint256 reward =  calculateRewardInterest(msg.sender) * (stakingDuration / 1 days);
        // Calculate tax
        uint256 tax = investorBalance / 100 / 10 * 5; // 0.5% of investor balance
        uint256 netReward = reward - tax; // /reward - tax
        
        // Check if reward of staker is greater than 0, Transfer token reward to msg.sender from reward pool address
        if(reward != 0){
            // Transfer net reward to investor
            vld.transferFrom(rewardPool, msg.sender, netReward);
            // Transfer tax to transaction charges address
            vld.transferFrom(rewardPool, transactionCharges, tax);
        }else{
            return;
        }
        
        // Set investor withdrawal
        uint256 noOfWithdrawals = withdrawalNumber[msg.sender];

       // Save user withdrawal 
        claimedRewards[msg.sender][noOfWithdrawals] = userClaimedRewards({
        duration: stakingDuration,
        reward: reward,
        stakingDate: duration[msg.sender]
        });
        withdrawalNumber[msg.sender]++;

        // Reset staker duration to current time
        duration[msg.sender] = block.timestamp;
        
        
    } 

    function calculateInvestorReward(address investor)public view returns(uint256 grossReward){
        // Check if msg.sender is a staker
        require(hasStaked[investor],"The caller is not an investor");
        // Check if msg.sender isStaking
        require(isStaking[investor],"The caller is not staking currently");
        // Calculate staker's reward
        uint256 stakingDuration = block.timestamp - duration[investor];
        uint256 investorBalance = stakingBalance[investor];
        uint256 reward =  calculateRewardInterest(investor) * (stakingDuration / 1 days);
        // Calculate tax
        uint256 tax = investorBalance / 100 / 10 * 5; // 0.5% of investor balance
        uint256 netReward = reward - tax; // /reward - tax
        return netReward;
    }

    function calculateStakingDuration(address investor) public view returns(uint256 stakingTime){
        // Check if msg.sender is a staker
        require(hasStaked[investor],"The caller is not an investor");
        // Check if msg.sender isStaking
        require(isStaking[investor],"The caller is not staking currently");
        uint256 stakingDuration = block.timestamp - duration[investor];
        return stakingDuration;
    }

    function investorNodeBalance(address investor) public view returns (uint256 investorBalance){
        // Check if msg.sender is a staker
        require(hasStaked[investor],"The caller is not an investor");
        // Check if msg.sender isStaking
        require(isStaking[investor],"The caller is not staking currently");
        // Get and return investor balance
        return stakingBalance[investor];
    }


    // Function to calculate investor's reward
    function calculateRewardInterest(address investor)public view returns(uint256 reward){
        require(hasStaked[investor],"This user is not an investor");
        require(isStaking[investor],"This user is not staking currently");
        uint256 stakingDuration = block.timestamp - duration[investor];
        uint256 investorBalance = stakingBalance[investor];

        // Everyone who creates a node will be given at minimum 1% ROI per day
        /**
        * After 0 days of not claiming daily ROI = 1.00%
        * After 3 days of not claiming, daily ROI = 1.02% 
        * After 5 days of not claiming, daily ROI = 1.04% 
        * After 7 days of not claiming, daily ROI = 1.06% 
        * After 10 days of not claiming, daily ROI = 1.08%
        * After 14 days of not claiming, daily ROI = 1.10% 
        * After 21 days of not claiming, daily ROI = 1.15% 
        * After 35 days of not claiming, daily ROI = 1.25% 
        * After 55 days of not claiming, daily ROI = 1.35%
        **/

        if(stakingDuration < day1){
            // reward less than a day is 0% of investor balance
            return 0;
        }if( day1 >= stakingDuration && stakingDuration < day3){
            //  reward interest for 1 day is 1% of investor balance
            return investorBalance / 100 * 1;
        }if( day3 >= stakingDuration && stakingDuration < day5){
            //  reward interest for 3 days is 1.02% of investor balance
            return investorBalance / 100 /100 * 102;
        }if( day5 >= stakingDuration && stakingDuration < day7){
            //  reward interest for 5 days is 1.04% of investor balance
            return investorBalance / 100 /100 * 104;
        }if( day7 >= stakingDuration && stakingDuration < day10){
            //  reward interest for 7 days is 1.04% of investor balance
            return investorBalance / 100 /100 * 106;
        }if( day10 >= stakingDuration && stakingDuration < day14){
            //  reward interest for 10 days is 1.08% of investor balance
            return investorBalance / 100 /100 * 108;
        }if( day14 >= stakingDuration && stakingDuration < day21){
            //  reward interest for 14 days is 1.10% of investor balance
            return investorBalance / 100 /100 * 110;
        }if( day21 >= stakingDuration && stakingDuration < day35){
            //  reward interest for 21 days is 1.15% of investor balance
            return investorBalance / 100 /100 * 115;
        }if( day35 >= stakingDuration && stakingDuration < day55){
            //  reward interest for 35 days is 1.25% of investor balance
            return investorBalance / 100 /100 * 125;
        }if( day55 >= stakingDuration){
            //  reward interest for 55 days is 1.35% of investor balance
            return investorBalance / 100 /100 * 135;
        }
    }


}

