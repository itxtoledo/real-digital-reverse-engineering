import { ethers } from "hardhat";
import { expect } from "chai";

describe("RealDigital", () => {
  async function deployFixture() {
    const [admin, authority, addr1, addr2] = await ethers.getSigners();

    const RealDigitalFactory = await ethers.getContractFactory("RealDigital");

    const RealDigital = await RealDigitalFactory.deploy(
      "RealDigital Token",
      "RDT",
      authority.address,
      admin.address
    );

    return {
      realDigital: RealDigital,
      accounts: { admin, authority, addr1, addr2 },
    };
  }

  describe("Deployment", () => {
    it("Should set the correct name and symbol", async () => {
      const { realDigital } = await deployFixture();

      expect(await realDigital.name()).to.equal("RealDigital Token");
      expect(await realDigital.symbol()).to.equal("RDT");
    });

    it("Should have initial total supply of 0", async () => {
      const { realDigital } = await deployFixture();

      expect(await realDigital.totalSupply()).to.equal(0);
    });
  });

  describe("Minting", () => {
    it("Should allow the authority to mint tokens", async () => {
      const { realDigital, accounts } = await deployFixture();

      const amount = 100;
      await realDigital
        .connect(accounts.authority)
        .mint(accounts.addr2.address, amount);
      expect(await realDigital.balanceOf(accounts.addr2.address)).to.equal(
        amount
      );
    });

    it("Should not allow non-authority accounts to mint tokens", async () => {
      const { realDigital, accounts } = await deployFixture();

      const amount = 100;
      await expect(
        realDigital.connect(accounts.admin).mint(accounts.addr1.address, amount)
      ).to.be.revertedWith("RealDigital: must have minter role to mint");
    });
  });

  describe("Burning", () => {
    it("Should allow the burner to burn tokens", async () => {
      const { realDigital, accounts } = await deployFixture();

      const amount = 100;
      await realDigital
        .connect(accounts.authority)
        .mint(accounts.addr2.address, amount);
      await realDigital
        .connect(accounts.authority)
        .burnFrom(accounts.addr2.address, amount);
      expect(await realDigital.balanceOf(accounts.addr2.address)).to.equal(0);
    });

    it("Should not allow non-burner accounts to burn tokens", async () => {
      const { realDigital, accounts } = await deployFixture();

      const amount = 100;
      await realDigital
        .connect(accounts.authority)
        .mint(accounts.addr2.address, amount);
      await expect(
        realDigital
          .connect(accounts.admin)
          .burnFrom(accounts.addr2.address, amount)
      ).to.be.revertedWith("RealDigital: must have burner role to burn");
    });
  });

  describe("Token Transfers", () => {
    it("Should transfer tokens between accounts", async () => {
      const { realDigital, accounts } = await deployFixture();

      const amount = 100;
      await realDigital
        .connect(accounts.authority)
        .mint(accounts.admin.address, amount);
      await realDigital.transfer(accounts.addr2.address, amount);
      expect(await realDigital.balanceOf(accounts.admin.address)).to.equal(0);
      expect(await realDigital.balanceOf(accounts.addr2.address)).to.equal(
        amount
      );
    });

    it("Should not allow transfers when the contract is paused", async () => {
      const { realDigital, accounts } = await deployFixture();

      await realDigital.pause();
      const amount = 100;
      await realDigital
        .connect(accounts.authority)
        .mint(accounts.admin.address, amount);
      await expect(
        realDigital.transfer(accounts.addr2.address, amount)
      ).to.be.revertedWith("Pausable: paused");
    });
  });
});
