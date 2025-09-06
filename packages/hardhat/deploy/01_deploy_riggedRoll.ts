import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { ethers } from "hardhat/";
import { DiceGame, RiggedRoll } from "../typechain-types";

const deployRiggedRoll: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;

  const diceGame: DiceGame = await ethers.getContract("DiceGame");
  const diceGameAddress = await diceGame.getAddress();

  // Deploy RiggedRoll contract
  await deploy("RiggedRoll", {
    from: deployer,
    log: true,
    args: [diceGameAddress],
    autoMine: true,
  });

  const riggedRoll: RiggedRoll = await ethers.getContract("RiggedRoll", deployer);

  // Transfer ownership to your frontend wallet address
  // This address will be able to withdraw funds from the RiggedRoll contract
  try {
    await riggedRoll.transferOwnership("0xEe5fE4fB64003Fc1EA1Ed3927e8986C5FC2D04c6");
    console.log("RiggedRoll deployed successfully!");
    console.log("Ownership transferred to:", "0xEe5fE4fB64003Fc1EA1Ed3927e8986C5FC2D04c6");
    console.log("Current owner:", await riggedRoll.owner());
    console.log("DiceGame address:", diceGameAddress);
  } catch (err) {
    console.log(err);
  }
};

export default deployRiggedRoll;

deployRiggedRoll.tags = ["RiggedRoll"];
