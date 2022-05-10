// install and import ethers.js library for connecting to the blockchain
import { ethers } from "ethers";

// import VLDStaking smart contract address and ABI(metadata Interface)
import { VLDStakingADdress } from "../contractAddresses";
import VLDStaking from "../abis/VLDStaking.json";

// Get the provider from window.ethereum
const provider = new ethers.providers.Web3Provider(window.ethereum);
const signer = provider.getSigner();

// create a new instance of the contract
const contract = new ethers.Contract(VLDStakingADdress, VLDStaking.abi, signer);

/**
 * @dev Functions to call the contract's function
 *
 */

/**
 *
 * @param {minimum of 10000} amount
 * @dev Investors must have minimum of 10000VLD + external transaction fee 0.5% of amount
 * @dev Remember to call the approve function from VLD.so to approve the contract to spend the VLD
 */
export const stakeVld = async (amount) => {
  // amount is the amount of VLD to be staked
  const tx = await contract.functions.depositTokens(amount);
  const result = await tx.wait();
  // return the result
  return result;
};

export const claimRewardTokens = async () => {
  // only an investor can call this function
  const tx = await contract.functions.claimRewardTokens();
  const result = await tx.wait();
  // return the result
  return result;
};

export const calculateStakingDuration = async (investorAddress) => {
  // Function to get duration of of incestor's staking
  const result = await contract.functions.calculateStakingDuration(
    investorAddress
  );
  return result;
};

export const calculateInvestorReward = async (investorAddress) => {
  // Function to get net reward of investor
  const result = await contract.functions.calculateInvestorReward(
    investorAddress
  );
  return result;
};

/**
 * @dev The functions bellow are important and should be called after contract deployment
 * @dev These functions can only be called by owner(account that deployed the contract) of the contract
 */

/**
 * @dev set project wallets
 */
export const setTreasuryWallet = async (walletAddress) => {
  // walletAddress is the address of the Treasury wallet
  const result = await contract.functions.setTreasury(walletAddress);
  // return the result
  return result;
};

export const setRewardPoolWallet = async (walletAddress) => {
  // walletAddress is the address of the Reward Pool wallet
  const result = await contract.functions.setRewardPool(walletAddress);
  // return the result
  return result;
};

export const setValidReserveWallet = async (walletAddress) => {
  // walletAddress is the address of the Valid Reserve wallet
  const result = await contract.functions.setValidReserve(walletAddress);
  // return the result
  return result;
};

export const setOperationsWallet = async (walletAddress) => {
  // walletAddress is the address of the Operations wallet
  const result = await contract.functions.setOperations(walletAddress);
  // return the result
  return result;
};

export const setDeveloperRightsWallet = async (walletAddress) => {
  // walletAddress is the address of the Developer Rights wallet
  const result = await contract.functions.setDeveloperRights(walletAddress);
  // return the result
  return result;
};

export const setTransactionChargesWallet = async (walletAddress) => {
  // transactionFee is the transaction fee
  const result = await contract.functions.setTransactionCharges(walletAddress);
  // return the result
  return result;
};

// Function to set smart contract address
export const setContractAddress = async (contractAddress) => {
  // contractAddress is the address of the  staking contract
  const result = await contract.functions.setContractAddress(contractAddress);
  // return the result
  return result;
};

//  Function to get VLD balance of user
export const getVldBalance = async (userAddress) => {
  // userAddress is the address of the user
  const result = await contract.functions.balance(userAddress);
  // return the result
  return result;
};

/**
 * functions needed to be written
 * get user staking duration
 * get calculated reward for specific period/duration
 * get user staking status
 * get user staking amount/balance
 */
