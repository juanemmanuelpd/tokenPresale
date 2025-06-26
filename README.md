# Token Presale
## Overview 🪙
Run a presale of ERC20 tokens through 3 phases.
## Features 📃
* Presale begins in three phases. Each phase has a specific token quantity, price per token, and a fixed time limit.
* Purchase tokens using USDT or USDC. Note: For this occasion, these stable coins are represented using mock tokens.
* Purchase tokens using ETH. Note: For this occasion, the Arbitrum network was forked to obtain the current USD price of ETH using Chainlink data feeds.
* Once the presale is over, you can safely claim your tokens to the account from which you made the transaction.
* At any time you can check the price of ETH in USD through the chainlink data feed.
* In case of emergency, the owner can withdraw all funds from the smart contract, both in stable coins and in ether.
* The owner can block malicious users at any time so that they cannot buy (with stable coins or ether) or claim their tokens.
## Technical details ⚙️
* Forked network for testing -> Arbitrum.
* RPC Server Address -> https://arb1.arbitrum.io/rpc.
* Chainlink data feed-> ETH/USD in Arbitrum Mainnet (0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612).
* Framework CLI -> Foundry.
* Forge version -> 1.1.0-stable.
* Solidity compiler version -> 0.8.24.
## Deploying the contract 🛠️
1. Clone the GitHub repository.
2. Open Visual Studio Code (you should already have Foundry installed).
3. Select "File" > "Open Folder", select the cloned repository folder.
4. In the project navigation bar, open the "presaleTest.t.sol" file located in the "test" folder.
6. In the toolbar above, select "Terminal" > "New Terminal".
7. Select the "Git bash" terminal (previously installed).
8. Run the command `forge test -vvvv --fork-url https://arb1.arbitrum.io/rpc --match-test` followed by the name of a test function to test it and verify the smart contract functions are working correctly. For example, run `forge test -vvvv --fork-url https://arb1.arbitrum.io/rpc --match-test testUserCanBuyWithEther` to test the `testUserCanBuyWithEther` function.
12. Run `forge coverage --fork-url https://arb1.arbitrum.io/rpc` to generate a code coverage report. This helps identify areas outside the coverage that could be exposed to errors/vulnerabilities.
## Functions 📌
* `swapTokens()` -> Swap USDC for DAI.
* `addLiquidity()` -> Contribute USDC and DAI to the USDC-DAI liquidity pool to receive Liquidity Provider Tokens.
* `removeLiquidity()` -> Redeem your Liquidity Provider Tokens to receive USDC and DAI from the USDC-DAI liquidity pool.
## Testing functions ⌨️
* `testHasBeenDeployedCorrectly()` -> Verify that the swap app has been correctly initialized with the correct router address (`uniswapV2SwapRouterAddress`).
* `testSwapTokensCorrectly()` -> Verify that the 6 USDC to DAI swap was successful. Note: The amount of DAI you receive will vary depending on the liquidity in the USDC -> DAI liquidity pool.
* `testCanAddLiquidityCorrectly()` -> Verify that half of your USDC is swapped for DAI, that the USDC and DAI are contributed to the liquidity pool, and that you successfully obtain your Liquidity Provider Tokens.
* `testCanRemoveLiquidityCorrectly()` -> Verify that your Liquidity Provider Tokens are redeemed and that you are successfully receiving USDC and DAI from the liquidity pool.
## Forge Coverage ✅
![Forge Coverage](images/forgeCoverage.png)  

CODE IS LAW!
