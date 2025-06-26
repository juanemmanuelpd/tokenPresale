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
5. In the toolbar above, select "Terminal" > "New Terminal".
6. Select the "Git bash" terminal (previously installed).
7. Run the command `forge test -vvvv --fork-url https://arb1.arbitrum.io/rpc --match-test` followed by the name of a test function to test it and verify the smart contract functions are working correctly. For example, run `forge test -vvvv --fork-url https://arb1.arbitrum.io/rpc --match-test testUserCanBuyWithEther` to test the `testUserCanBuyWithEther` function.
8. Run `forge coverage --fork-url https://arb1.arbitrum.io/rpc` to generate a code coverage report. This helps identify areas outside the coverage that could be exposed to errors/vulnerabilities.
## Functions 📌
* `startPresale()` -> Send from the owner to the presale contract the entire amount of tokens that will be released in the presale.
* `blacklist()` -> The owner can block malicious users from purchasing or claiming their purchased tokens.
* `removeBlacklist()` -> The owner can remove users from the blacklist at any time.
* `checkCurrentPhase()` -> Verify that the conditions for limiting the amount of tokens to be purchased and the time limit per phase are met for each of the 3 phases of the presale.
* `buyWithStable()` -> The user can purchase tokens on the presale using USDT or USDC.
* `buyWithEther()` -> The user can purchase tokens on the presale using ETH.
* `claim()` -> Once the presale ends, the user can claim the tokens they purchased.
* `getEtherPrice()` -> The user can check the current price of ETH in USD at any time through the chainlink data feed before making their purchase.
* `emergencyERC2OWithdraw()` -> In case of emergency, the owner can withdraw all funds in stable coins to his account.
* `emergencyETHWithdraw()` -> In case of emergency the owner can withdraw all funds in ether to his account.

## Testing functions ⌨️
* `testMockTokenMintsCorrectly()` -> Verify that the contract correctly mint tokens for the presale.
* `testPresaleStartCorrectly()` -> Verify that the pre-sale starts correctly with the total amount of tokens to be sold.
* `testOnlyOwnerCanStartPresale()` -> Verify that only the owner can start the presale.
* `testUserCanBuyWithStableCoin()` -> Verify that the user can successfully purchase tokens using stable coins.
* `testUserCanBuyWithEther()` -> Verify that the user can successfully purchase tokens using Ethereum.
* `testUserCanClaim()` -> Verify that when the presale ends, users can claim the tokens that belong to them according to the phase in which they were purchased.
* `testUserBlokedCanNotBuyWithStable()` -> Ensures that blocked users cannot purchase tokens using stable coins.
* `testUserBlokedCanNotBuyWithEther()` -> Verify that blocked users cannot purchase tokens using Ethereum.
* `testUserBlokedCanNotClaim()` -> Verify that blocked users cannot claim their purchased tokens.
* `testOnlyOwnerCanWithdrawERC20()` -> Ensures that only the owner can withdraw all stable coins from the contract in case of emergency.
* `testOnlyOwnerCanWithdrawEther()` -> Ensure that only the owner can withdraw all ETH from the contract in case of emergency.
* `testUserGetETHPriceCorrectly()` -> Please verify that the current price of ETH in USD can be correctly retrieved.
## Forge Coverage ✅
![Forge Coverage](images/forgeCoverage.png)  

CODE IS LAW!
