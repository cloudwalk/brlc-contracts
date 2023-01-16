import { ethers, network, upgrades } from "hardhat";
import { expect } from "chai";
import { Contract, ContractFactory } from "ethers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signer-with-address";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { proveTx } from "../../test-utils/eth";

async function setUpFixture(func: any) {
  if (network.name === "hardhat") {
    return loadFixture(func);
  } else {
    return func();
  }
}

describe("Contract 'access-ownable/WhitelistableUpgradeable'", async () => {
  const EVENT_NAME_WHITELISTED = "Whitelisted";
  const EVENT_NAME_WHITELISTER_CHANGED = "WhitelisterChanged";
  const EVENT_NAME_TEST_ONLY_WHITELISTED_MODIFIER_SUCCEEDED = "TestOnlyWhitelistedModifierSucceeded";
  const EVENT_NAME_UNWHITELISTED = "UnWhitelisted";

  const REVERT_MESSAGE_IF_CONTRACT_IS_ALREADY_INITIALIZED = "Initializable: contract is already initialized";
  const REVERT_MESSAGE_IF_CONTRACT_IS_NOT_INITIALIZING = "Initializable: contract is not initializing";
  const REVERT_MESSAGE_IF_CALLER_IS_NOT_OWNER = "Ownable: caller is not the owner";

  const REVERT_ERROR_IF_CALLER_IS_NOT_WHITELISTER = "UnauthorizedWhitelister";
  const REVERT_ERROR_IF_ACCOUNT_IS_NOT_WHITELISTED = "NotWhitelistedAccount";

  let whitelistableMockFactory: ContractFactory;

  let deployer: SignerWithAddress;
  let whitelister: SignerWithAddress;
  let user: SignerWithAddress;

  before(async () => {
    [deployer, whitelister, user] = await ethers.getSigners();
    whitelistableMockFactory = await ethers.getContractFactory(
      "contracts/mocks/access-ownable/WhitelistableUpgradeableMock.sol:WhitelistableUpgradeableMock");
  });

  async function deployWhitelistableMock(): Promise<{ whitelistableMock: Contract }> {
    const whitelistableMock: Contract = await upgrades.deployProxy(whitelistableMockFactory);
    await whitelistableMock.deployed();
    return { whitelistableMock };
  }

  async function deployAndConfigureWhitelistableMock(): Promise<{ whitelistableMock: Contract }> {
    const { whitelistableMock } = await deployWhitelistableMock();
    await proveTx(whitelistableMock.setWhitelister(whitelister.address));
    return { whitelistableMock };
  }

  describe("Initializers", async () => {
    it("The external initializer configures the contract as expected", async () => {
      const { whitelistableMock } = await setUpFixture(deployWhitelistableMock);
      expect(await whitelistableMock.owner()).to.equal(deployer.address);
      expect(await whitelistableMock.whitelister()).to.equal(ethers.constants.AddressZero);
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

  describe("Function 'setWhitelister()'", async () => {
    it("Executes as expected and emits the correct event", async () => {
      const { whitelistableMock } = await setUpFixture(deployWhitelistableMock);

      await expect(
        whitelistableMock.setWhitelister(whitelister.address)
      ).to.emit(
        whitelistableMock,
        EVENT_NAME_WHITELISTER_CHANGED
      ).withArgs(whitelister.address);
      expect(await whitelistableMock.whitelister()).to.equal(whitelister.address);

      // The second call with the same argument should not emit an event
      await expect(
        whitelistableMock.setWhitelister(whitelister.address)
      ).not.to.emit(whitelistableMock, EVENT_NAME_WHITELISTER_CHANGED);
    });

    it("Is reverted if it is called not by the owner", async () => {
      const { whitelistableMock } = await setUpFixture(deployWhitelistableMock);
      await expect(
        whitelistableMock.connect(whitelister).setWhitelister(whitelister.address)
      ).to.be.revertedWith(REVERT_MESSAGE_IF_CALLER_IS_NOT_OWNER);
    });
  });

  describe("Function 'whitelist()'", async () => {
    it("Executes as expected and emits the correct event if it is called by the whitelister", async () => {
      const { whitelistableMock } = await setUpFixture(deployAndConfigureWhitelistableMock);
      expect(await whitelistableMock.isWhitelisted(user.address)).to.equal(false);

      await expect(
        whitelistableMock.connect(whitelister).whitelist(user.address)
      ).to.emit(
        whitelistableMock,
        EVENT_NAME_WHITELISTED
      ).withArgs(user.address);
      expect(await whitelistableMock.isWhitelisted(user.address)).to.equal(true);

      // The second call with the same argument should not emit an event
      await expect(
        whitelistableMock.connect(whitelister).whitelist(user.address)
      ).not.to.emit(whitelistableMock, EVENT_NAME_WHITELISTED);
    });

    it("Is reverted if it is called not by the whitelister", async () => {
      const { whitelistableMock } = await setUpFixture(deployAndConfigureWhitelistableMock);
      await expect(
        whitelistableMock.whitelist(user.address)
      ).to.be.revertedWithCustomError(whitelistableMock, REVERT_ERROR_IF_CALLER_IS_NOT_WHITELISTER);
    });
  });

  describe("Function 'unWhitelist()'", async () => {
    it("Executes as expected and emits the correct event if it is called by the whitelister", async () => {
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

    it("Is reverted if it is called not by the whitelister", async () => {
      const { whitelistableMock } = await setUpFixture(deployAndConfigureWhitelistableMock);
      await expect(
        whitelistableMock.unWhitelist(user.address)
      ).to.be.revertedWithCustomError(whitelistableMock, REVERT_ERROR_IF_CALLER_IS_NOT_WHITELISTER);
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
