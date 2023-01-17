import { ethers, network, upgrades } from "hardhat";
import { expect } from "chai";
import { Contract, ContractFactory } from "ethers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signer-with-address";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { proveTx } from "../../test-utils/eth";
import { createRevertMessageDueToMissingRole } from "../../test-utils/misc";

async function setUpFixture(func: any) {
  if (network.name === "hardhat") {
    return loadFixture(func);
  } else {
    return func();
  }
}

describe("Contract 'access-control/WhitelistableUpgradeable'", async () => {
  const EVENT_NAME_WHITELISTED = "Whitelisted";
  const EVENT_NAME_TEST_ONLY_WHITELISTED_MODIFIER_SUCCEEDED = "TestOnlyWhitelistedModifierSucceeded";
  const EVENT_NAME_UNWHITELISTED = "UnWhitelisted";

  const REVERT_MESSAGE_IF_CONTRACT_IS_ALREADY_INITIALIZED = "Initializable: contract is already initialized";
  const REVERT_MESSAGE_IF_CONTRACT_IS_NOT_INITIALIZING = "Initializable: contract is not initializing";

  const REVERT_ERROR_IF_ACCOUNT_IS_NOT_WHITELISTED = "NotWhitelistedAccount";

  const ownerRole: string = ethers.utils.id("OWNER_ROLE");
  const whitelisterRole: string = ethers.utils.id("WHITELISTER_ROLE");

  let whitelistableMockFactory: ContractFactory;

  let deployer: SignerWithAddress;
  let whitelister: SignerWithAddress;
  let user: SignerWithAddress;

  before(async () => {
    [deployer, whitelister, user] = await ethers.getSigners();
    whitelistableMockFactory = await ethers.getContractFactory(
      "contracts/mocks/access-control/WhitelistableUpgradeableMock.sol:WhitelistableUpgradeableMock");
  });

  async function deployWhitelistableMock(): Promise<{ whitelistableMock: Contract }> {
    const whitelistableMock: Contract = await upgrades.deployProxy(whitelistableMockFactory);
    await whitelistableMock.deployed();
    return { whitelistableMock };
  }

  async function deployAndConfigureWhitelistableMock(): Promise<{ whitelistableMock: Contract }> {
    const { whitelistableMock } = await deployWhitelistableMock();
    await proveTx(whitelistableMock.grantRole(whitelisterRole, whitelister.address));
    return { whitelistableMock };
  }

  describe("Initializers", async () => {
    it("The external initializer configures the contract as expected", async () => {
      const { whitelistableMock } = await setUpFixture(deployWhitelistableMock);

      // The roles
      expect(await whitelistableMock.OWNER_ROLE()).to.equal(ownerRole);
      expect(await whitelistableMock.WHITELISTER_ROLE()).to.equal(whitelisterRole);

      // The role admins
      expect(await whitelistableMock.getRoleAdmin(ownerRole)).to.equal(ethers.constants.HashZero);
      expect(await whitelistableMock.getRoleAdmin(whitelisterRole)).to.equal(ownerRole);

      // The deployer should have the owner role, but not the other roles
      expect(await whitelistableMock.hasRole(ownerRole, deployer.address)).to.equal(true);
      expect(await whitelistableMock.hasRole(whitelisterRole, deployer.address)).to.equal(false);
    });

    it("The external initializer is reverted if it is called a second time", async () => {
      const { whitelistableMock } = await setUpFixture(deployWhitelistableMock);
      await expect(
        whitelistableMock.initialize()
      ).to.be.revertedWith(REVERT_MESSAGE_IF_CONTRACT_IS_ALREADY_INITIALIZED);
    });

    it("The internal initializer is reverted if it is called outside the init process", async () => {
      const { whitelistableMock } = await setUpFixture(deployWhitelistableMock);
      await expect(
        whitelistableMock.call_parent_initialize()
      ).to.be.revertedWith(REVERT_MESSAGE_IF_CONTRACT_IS_NOT_INITIALIZING);
    });

    it("The internal unchained initializer is reverted if it is called outside the init process", async () => {
      const { whitelistableMock } = await setUpFixture(deployWhitelistableMock);
      await expect(
        whitelistableMock.call_parent_initialize_unchained()
      ).to.be.revertedWith(REVERT_MESSAGE_IF_CONTRACT_IS_NOT_INITIALIZING);
    });
  });

  describe("Function 'whitelist()'", async () => {
    it("Executes as expected and emits the correct event if it is called by a whitelister", async () => {
      const { whitelistableMock } = await setUpFixture(deployAndConfigureWhitelistableMock);
      expect(await whitelistableMock.isWhitelisted(user.address)).to.equal(false);

      await expect(
        whitelistableMock.connect(whitelister).whitelist(user.address)
      ).to.emit(
        whitelistableMock,
        EVENT_NAME_WHITELISTED
      ).withArgs(user.address);
      expect(await whitelistableMock.isWhitelisted(user.address)).to.equal(true);

      // Second call with the same argument should not emit an event
      await expect(
        whitelistableMock.connect(whitelister).whitelist(user.address)
      ).not.to.emit(whitelistableMock, EVENT_NAME_WHITELISTED);
    });
  });

  it("Is reverted if it is called by an account without the whitelister role", async () => {
    const { whitelistableMock } = await setUpFixture(deployAndConfigureWhitelistableMock);
    await expect(
      whitelistableMock.whitelist(user.address)
    ).to.be.revertedWith(createRevertMessageDueToMissingRole(deployer.address, whitelisterRole));
  });

  describe("Function 'unWhitelist()'", async () => {
    it("Executes as expected and emits the correct event if it is called by a whitelister", async () => {
      const { whitelistableMock } = await setUpFixture(deployAndConfigureWhitelistableMock);
      await proveTx(whitelistableMock.connect(whitelister).whitelist(user.address));

      expect(await whitelistableMock.isWhitelisted(user.address)).to.equal(true);

      await expect(
        whitelistableMock.connect(whitelister).unWhitelist(user.address)
      ).to.emit(
        whitelistableMock,
        EVENT_NAME_UNWHITELISTED
      ).withArgs(user.address);
      expect(await whitelistableMock.isWhitelisted(user.address)).to.equal(false);

      // The second call with the same argument should not emit an event
      await expect(
        whitelistableMock.connect(whitelister).unWhitelist(user.address)
      ).not.to.emit(whitelistableMock, EVENT_NAME_UNWHITELISTED);
    });

    it("Is reverted if it is called by an account without the whitelister role", async () => {
      const { whitelistableMock } = await setUpFixture(deployAndConfigureWhitelistableMock);
      await expect(
        whitelistableMock.unWhitelist(user.address)
      ).to.be.revertedWith(createRevertMessageDueToMissingRole(deployer.address, whitelisterRole));
    });
  });

  describe("Modifier 'onlyWhitelisted'", async () => {
    it("Reverts the target function if the caller is not whitelisted", async () => {
      const { whitelistableMock } = await setUpFixture(deployAndConfigureWhitelistableMock);
      await expect(
        whitelistableMock.testOnlyWhitelistedModifier()
      ).to.be.revertedWithCustomError(whitelistableMock, REVERT_ERROR_IF_ACCOUNT_IS_NOT_WHITELISTED);
    });

    it("Does not revert the target function if the caller is whitelisted", async () => {
      const { whitelistableMock } = await setUpFixture(deployAndConfigureWhitelistableMock);
      await proveTx(whitelistableMock.connect(whitelister).whitelist(deployer.address));

      await expect(
        whitelistableMock.testOnlyWhitelistedModifier()
      ).to.emit(whitelistableMock, EVENT_NAME_TEST_ONLY_WHITELISTED_MODIFIER_SUCCEEDED);
    });
  });
});
