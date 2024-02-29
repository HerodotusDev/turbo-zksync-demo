import { deployContract } from "./utils";

export default async function () {
  if (!process.env.TURBO_SWAP_PROXY_ADDRESS) {
    throw new Error("TURBO_SWAP_PROXY_ADDRESS is not set");
  }

  const contractArtifactName = "TurboAccountActivityChecker";
  const constructorArguments = [process.env.TURBO_SWAP_PROXY_ADDRESS];

  await deployContract(contractArtifactName, constructorArguments);
}
