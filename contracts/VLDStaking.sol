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

    address[] public stakers;
    uint256 numberOfStakers;
    uint256 public minStakeAmount = 10000 * (10 ** 18);
    mapping(address => uint256) public stakingBalance;
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
        uint256 transactionChargesAllocation = amount /100 / 10 * 5;
        vld.transferFrom(msg.sender, transactionCharges, transactionChargesAllocation);

        // Update staking balance 
        stakingBalance[msg.sender] = stakingBalance[msg.sender] + amount;

        if(!hasStaked[msg.sender]){
            stakers.push(msg.sender);
            numberOfStakers++;
        }

        // Update staking boolean and duration
        hasStaked[msg.sender] = true;
        isStaking[msg.sender] = true;
        duration[msg.sender] = block.timestamp; // stores number of seconds that have passed since January 1st 1970.
        nodesPurchased[msg.sender] = stakingBalance[msg.sender] + ( amount / minStakeAmount);
    }


}