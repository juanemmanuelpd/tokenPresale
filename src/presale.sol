// License
// SPDX-License-Identifier: MIT

// Solidity compiler version
pragma solidity 0.8.24;

// Libraries
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interfaces/IAggregator.sol";

// Contract 
contract presale is Ownable{

    using SafeERC20 for IERC20;

    // Variables
    address public saleTokenAddress;
    address public USDTAddress;
    address public USDCAddress;
    address public fundsReceiverAddress;
    address public dataFeedAddress;
    uint256 public maxSellingAmount;
    uint256[][3] public phases;
    uint256 public startingTime;
    uint256 public endingTime;
    uint256 public totalSold;
    uint256 public currentPhase;
    mapping(address => bool) public isBlacklisted;
    mapping(address => uint256) public userTokenBalance;

    // Events
    event e_TokenBuy(address user, uint256 amount);

    // Constructor
    constructor(address saleTokenAddress_, address USDTAddress_, address USDCAddress_, address fundsReceiverAddress_, address dataFeedAddress_, uint256 maxSellingAmount_, uint256 startingTime_, uint256 endingTime_, uint256[][3] memory phases_) Ownable(msg.sender){
        saleTokenAddress = saleTokenAddress_;
        USDTAddress = USDTAddress_;
        USDCAddress = USDCAddress_;
        fundsReceiverAddress = fundsReceiverAddress_;
        maxSellingAmount = maxSellingAmount_;
        startingTime = startingTime_;
        endingTime = endingTime_;
        phases = phases_;
        dataFeedAddress = dataFeedAddress_;
        require(endingTime > startingTime, "Incorrect presale times");
    }

    // Functions

    function startPresale() external onlyOwner {
        IERC20(saleTokenAddress).safeTransferFrom(msg.sender, address(this), maxSellingAmount);
    }

    /**
     * Used to blacklist users
     * @param user_ The address of the blacklisted user
     */

    function blacklist(address user_) onlyOwner() external {
        isBlacklisted[user_] = true;
    }

    function removeBlacklist(address user_) onlyOwner() external {
        isBlacklisted[user_] = false;
    }

    function checkCurrentPhase(uint256 amount_) private returns (uint256 phase){
        if((totalSold + amount_ >= phases[currentPhase][0] || (block.timestamp >= phases[currentPhase][2])) && currentPhase < 3){
            currentPhase++;
            phase = currentPhase;
        } else {
            phase = currentPhase;
        }
    }

    /**
     * Used to buy tokens with stable coin
     * @param tokenUsedToBuy_ The address of the token used to buy
     * @param amount_ The amount of tokens for buying
     */

    function buyWithStable(address tokenUsedToBuy_, uint256 amount_) external {
        require(!isBlacklisted[msg.sender], "User is blacklisted");
        require(block.timestamp >= startingTime, "Presale not started yet");
        require(block.timestamp <= endingTime, "Presale ended");
        require(tokenUsedToBuy_ == USDTAddress || tokenUsedToBuy_ == USDCAddress, "Incorrect token");
        
        uint256 tokenAmountToReceive;
        if(ERC20(tokenUsedToBuy_).decimals() == 18) tokenAmountToReceive = amount_ * 1e6 / phases[currentPhase][1];
        else tokenAmountToReceive = amount_ * 10**(18 - ERC20(tokenUsedToBuy_).decimals()) * 1e6 / phases[currentPhase][1];
        checkCurrentPhase(tokenAmountToReceive);
        totalSold += tokenAmountToReceive;
        require(totalSold <= maxSellingAmount, "Sold out");

        userTokenBalance[msg.sender] += tokenAmountToReceive;

        IERC20(tokenUsedToBuy_).safeTransferFrom(msg.sender, fundsReceiverAddress, amount_);
        
        emit e_TokenBuy(msg.sender, tokenAmountToReceive);
    }

    function buyWithEther() external payable{
        require(!isBlacklisted[msg.sender], "User is blacklisted");
        require(block.timestamp >= startingTime && block.timestamp <= endingTime, "Presale not started yet");
              
        uint256 usdValue = msg.value * getEtherPrice() / 1e18;
        uint256 tokenAmountToReceive = usdValue * 1e6 / phases[currentPhase][1];
        checkCurrentPhase(tokenAmountToReceive);

        totalSold += tokenAmountToReceive;
        require(totalSold <= maxSellingAmount, "Sold out");

        userTokenBalance[msg.sender] += tokenAmountToReceive;

        (bool success, )= fundsReceiverAddress.call{value: msg.value}("");
        require(success, "Transfer fail");
        
        emit e_TokenBuy(msg.sender, tokenAmountToReceive);    
    } 

    function claim() external {
        require(!isBlacklisted[msg.sender], "User is blacklisted");
        require(block.timestamp > endingTime, "Presale not ended");
        uint256 amount = userTokenBalance[msg.sender];
        delete userTokenBalance[msg.sender];
        IERC20(saleTokenAddress).safeTransfer(msg.sender, amount);
    }

    function getEtherPrice() public view returns (uint256){
        (,int256 price,,,) = IAggregator(dataFeedAddress).latestRoundData();
        price = price * (10 ** 10);
        return uint256(price);
    }

    function emergencyERC2OWithdraw(address tokenAddress_, uint256 amount_) onlyOwner() external {
        IERC20(tokenAddress_).safeTransfer(msg.sender, amount_);
    }

    function emergencyETHWithdraw() onlyOwner() external {
        uint256 balance = address(this).balance;
        (bool success, ) = msg.sender.call{value: balance}("");
        require(success, "Transfer fail");
    }

}