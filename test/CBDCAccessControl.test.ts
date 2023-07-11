import { ethers } from "hardhat";
import { expect } from "chai";

describe("CBDCAccessControl", () => {
  async function deployFixture() {
    const [
      owner,
      pauser,
      minter,
      accessRole,
      mover,
      burner,
      freezer,
      account1,
    ] = await ethers.getSigners();

    const CBDCAccessControl = await ethers.getContractFactory(
      "CBDCAccessControl"
    );

    const contract = await CBDCAccessControl.deploy(
      owner.address,
      owner.address
    );

    return {
      contract,
      accounts: {
        owner,
        pauser,
        minter,
        accessRole,
        mover,
        burner,
        freezer,
        account1,
      },
    };
  }

  it("should enable and disable an account", async () => {
    const { contract, accounts } = await deployFixture();

    expect(await contract.verifyAccount(accounts.account1.address)).to.equal(
      false
    );

    await contract.enableAccount(accounts.account1.address);
    expect(await contract.verifyAccount(accounts.account1.address)).to.equal(
      true
    );

    await contract.disableAccount(accounts.account1.address);
    expect(await contract.verifyAccount(accounts.account1.address)).to.equal(
      false
    );
  });

  it("should verify an authorized account", async () => {
    const { contract, accounts } = await deployFixture();

    expect(await contract.verifyAccount(accounts.account1.address)).to.equal(
      false
    );

    await contract.enableAccount(accounts.account1.address);
    expect(await contract.verifyAccount(accounts.account1.address)).to.equal(
      true
    );

    await contract.disableAccount(accounts.account1.address);
    expect(await contract.verifyAccount(accounts.account1.address)).to.equal(
      false
    );
  });

  it("should set up roles correctly", async () => {
    const { contract, accounts } = await deployFixture();

    expect(
      await contract.hasRole(
        await contract.DEFAULT_ADMIN_ROLE(),
        accounts.owner.address
      )
    ).to.equal(true);
    expect(
      await contract.hasRole(
        await contract.PAUSER_ROLE(),
        accounts.owner.address
      )
    ).to.equal(true);
    expect(
      await contract.hasRole(
        await contract.MINTER_ROLE(),
        accounts.owner.address
      )
    ).to.equal(true);
    expect(
      await contract.hasRole(
        await contract.ACCESS_ROLE(),
        accounts.owner.address
      )
    ).to.equal(true);
    expect(
      await contract.hasRole(
        await contract.MOVER_ROLE(),
        accounts.owner.address
      )
    ).to.equal(true);
    expect(
      await contract.hasRole(
        await contract.BURNER_ROLE(),
        accounts.owner.address
      )
    ).to.equal(true);
    expect(
      await contract.hasRole(
        await contract.FREEZER_ROLE(),
        accounts.owner.address
      )
    ).to.equal(true);
  });

  it("should enforce access control modifier", async () => {
    const { contract, accounts } = await deployFixture();

    const DEFAULT_ADMIN_ROLE = await contract.DEFAULT_ADMIN_ROLE();

    await contract.enableAccount(accounts.account1.address);
    const invalidAccess = contract.connect(accounts.account1);

    await expect(
      invalidAccess.disableAccount(accounts.account1.address)
    ).to.be.revertedWith(
      `AccessControl: account ${accounts.account1.address.toLowerCase()} is missing role ${DEFAULT_ADMIN_ROLE}`
    );
  });
});
