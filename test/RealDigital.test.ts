
import { expect } from "chai";
import { RealDigital } from "../typechain-types/contracts/RealDigital";
import { Signer, ContractFactory } from "ethers";
import { ethers } from "hardhat";

describe("RealDigital", function () {
  let realDigital: RealDigital;
  let owner: Signer;
  let minter: Signer;
  let burner: Signer;
  const initialSupply: BigNumber = ethers.utils.parseEther("1000000");

  before(async function () {
    // Deploy the RealDigital contract
    const RealDigital: ContractFactory = await ethers.getContractFactory("RealDigital");
    realDigital = await RealDigital.deploy("RealDigital", "RD");

    // Get signers from Hardhat
    [owner, minter, burner] = await ethers.getSigners();
  });

  it("should have correct name, symbol, and initial supply", async function () {
    expect(await realDigital.name()).to.equal("RealDigital");
    expect(await realDigital.symbol()).to.equal("RD");
    expect(await realDigital.totalSupply()).to.equal(initialSupply);
  });

  it("should mint tokens", async function () {
    // Grant the minter role to the minter account
    await realDigital.grantRole(await realDigital.MINTER_ROLE(), minter.address);

    // Mint 100 tokens to the minter account
    const amountToMint: BigNumber = ethers.utils.parseEther("100");
    await realDigital.mint(minter.address, amountToMint);

    // Check the minter's balance
    const minterBalance: BigNumber = await realDigital.balanceOf(minter.address);
    expect(minterBalance).to.equal(amountToMint);
  });

  it("should burn tokens", async function () {
    // Grant the burner role to the burner account
    await realDigital.grantRole(await realDigital.BURNER_ROLE(), burner.address);

    // Burn 50 tokens from the burner account
    const amountToBurn: BigNumber = ethers.utils.parseEther("50");
    await realDigital.burnFrom(burner.address, amountToBurn);

    // Check the burner's balance
    const burnerBalance: BigNumber = await realDigital.balanceOf(burner.address);
    expect(burnerBalance).to.equal(initialSupply.sub(amountToBurn));
  });
});
