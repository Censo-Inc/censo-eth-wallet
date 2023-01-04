import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const deploy: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, hardhatArguments, getNamedAccounts } = hre;
  const { deployer } = await getNamedAccounts();
  const { deploy } = deployments;

  await deploy("CensoSetup", {
    from: deployer,
    args: [],
    log: true,
    deterministicDeployment: false,
  });

  await deploy("CensoGuard", {
    from: deployer,
    args: [],
    log: true,
    deterministicDeployment: false,
  });

  await deploy("CensoTransfersOnlyGuard", {
    from: deployer,
    args: [],
    log: true,
    deterministicDeployment: false,
  });

  const fallback = await deploy("CensoFallbackHandler", {
    from: deployer,
    args: [],
    log: true,
    deterministicDeployment: false,
  });

  await deploy("CensoWhitelistingGuard", {
    from: deployer,
    args: [fallback.address],
    log: true,
    deterministicDeployment: false,
  });

  await deploy("CensoTransfersOnlyWhitelistingGuard", {
    from: deployer,
    args: [fallback.address],
    log: true,
    deterministicDeployment: false,
  });
};

deploy.tags = ["censo"];
export default deploy;
