// install and import ethers.js library for connecting to the blockchain
import { ethers } from "ethers";

// import VLD smart contract address and ABI(metadata Interface)
import { VLDAddress } from "../contractAddresses";
import VLD from "../abis/VLD.json";

// Get the provider from window.ethereum
const provider = new ethers.providers.Web3Provider(window.ethereum);
const signer = provider.getSigner();

// Create a new instance of the contract
const contract = new ethers.Contract(VLDAddress, VLD.abi, signer);

/**
 * @dev Functions to call the contract's function
 *
 */

/**
 * @dev approve function should be called by investor to approve the staking contract to spend the VLD
 * @param {address} contractAddress
 * @param {amount} amount
 */
export const approve = async (contractAddress, amount) => {
  // contractAddress is the address of the contract(Staking contract address) to be approved
  // amount is the amount of VLD to be approved
  const tx = await contract.functions.approve(contractAddress, amount);
  const result = await tx.wait();
  // return the result
  return result;
};
