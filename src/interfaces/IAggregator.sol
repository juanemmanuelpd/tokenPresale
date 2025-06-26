
// License
// SPDX-License-Identifier: MIT

// Solidity compiler version
pragma solidity 0.8.24;

// Interface
interface IAggregator{

    function latestRoundData() external view returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

}
