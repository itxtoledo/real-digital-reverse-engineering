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

      await realDigital.enableAccount(accounts.addr2.address);

      await realDigital
        .connect(accounts.authority)
        .mint(accounts.addr2.address, amount);
      expect(await realDigital.balanceOf(accounts.addr2.address)).to.equal(
        amount
      );
    });

    it("Should not allow non-authority accounts to mint tokens", async () => {
      const { realDigital, accounts } = await deployFixture();

      const MINTER_ROLE = await realDigital.MINTER_ROLE();

      const amount = 100;
      await expect(
        realDigital.connect(accounts.admin).mint(accounts.addr1.address, amount)
      ).to.be.revertedWith(
        `AccessControl: account ${accounts.admin.address.toLowerCase()} is missing role ${MINTER_ROLE}`
      );
    });
  });

  describe("Burning", () => {
    it("Should allow the burner to burn tokens", async () => {
      const { realDigital, accounts } = await deployFixture();

      const amount = 100;

      await realDigital.enableAccount(accounts.addr2.address);

      await realDigital
        .connect(accounts.authority)
        .mint(accounts.addr2.address, amount);

      await realDigital
        .connect(accounts.addr2)
        .increaseAllowance(accounts.authority.address, amount);

      await realDigital
        .connect(accounts.authority)
        .burnFrom(accounts.addr2.address, amount);
      expect(await realDigital.balanceOf(accounts.addr2.address)).to.equal(0);
    });

    it("Should not allow non-mover accounts to burn tokens", async () => {
      const { realDigital, accounts } = await deployFixture();

      const MOVER_ROLE = await realDigital.MOVER_ROLE();

      const amount = 100;

      await realDigital.enableAccount(accounts.addr2.address);

      await realDigital
        .connect(accounts.authority)
        .mint(accounts.addr2.address, amount);

      await expect(
        realDigital
          .connect(accounts.admin)
          .moveAndBurn(accounts.addr2.address, amount)
      ).to.be.revertedWith(
        `AccessControl: account ${accounts.admin.address.toLowerCase()} is missing role ${MOVER_ROLE}`
      );
    });
  });

  describe("Token Transfers", () => {
    it("Should transfer tokens between accounts", async () => {
      const { realDigital, accounts } = await deployFixture();

      const amount = 100;

      await realDigital.enableAccount(accounts.admin.address);
      await realDigital.enableAccount(accounts.addr2.address);

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

      const amount = 100;

      await realDigital.enableAccount(accounts.admin.address);

      await realDigital
        .connect(accounts.authority)
        .mint(accounts.admin.address, amount);
      await realDigital.connect(accounts.authority).pause();
      await expect(
        realDigital.transfer(accounts.addr2.address, amount)
      ).to.be.revertedWith("Pausable: paused");
    });
  });
});
