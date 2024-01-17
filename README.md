## Herodotus Turbo Smart Contract Boilerplate

**Give superpowers to your Solidity contracts leveraging Herodotus Turbo, an on-chain interface to get instant access to historical & cross-chain data.**

## Documentation

https://docs.herodotus.dev

## Usage

This repository is a template demonstrating how to use Herodotus Turbo in your Solidity contracts.

It gives you a basic contract named `TurboAccountActivityChecker` that uses Herodotus Turbo to get retrieve historical nonces from the chain history and use them to prove account activity and inactivity.

## Turbo Interface

The Turbo interface is defined in `src/turbo/ITurboSwap.sol` alongside other useful content in the same directory.

## Important Notes

- In order to make the test suite pass and to be able to make your contracts functions interacting with Turbo work, you need to instantiate a TurboSwap contract from the deployed proxy address on supported chains. Please refer to the Herodotus [documentation](https://docs.herodotus.dev) for more information.

- To be able access to access some data from the TurboSwap, the underlying storage proofs must have been proven on-chain. Trying to access data from the TurboSwap that has not been proven yet will result in a revert.

- To request a storage proof to be proven on-chain, you either need to use the Herodotus Turbo RPC (documentation coming soon) or use the [Herodotus API](<(https://api.herodotus.cloud/docs/static/index.html)>).

### Build

```shell
$ forge install && forge build
```

### Test

To run the tests, you need to fork a network where the TurboSwap contract has been deployed and instantiate a TurboSwap contract from the deployed proxy address. Create a `.env` file based on `.env.example`.

Also, accessed data must have been previously been proven on-chain.

You may need to adapt `TurboAccountActivityChecker` to your needs.

```shell
$ source .env; forge test --fork-url $GOERLI_FORK_URL
```

## Deployed Contracts

- [Deployed Contracts Addresses](https://docs.herodotus.dev/herodotus-docs/deployed-contracts)

## Documentation

Here are some useful links for further reading:

- [Herodotus Documentation](https://docs.herodotus.dev)
- [Herodotus Builder Guide](https://herodotus.notion.site/herodotus/Herodotus-Hands-On-Builder-Guide-5298b607069f4bcfba9513aa75ee74d4)

## License

Copyright 2024 - Herodotus Dev Ltd
