// License
// SPDX-License-Identifier: MIT

// Solidity compiler version
pragma solidity 0.8.24;

// Libraries
import "forge-std/Test.sol";
import "../src/presale.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

// Contracts

contract mockToken is ERC20 {
    constructor() ERC20("MockToken", "MTKN") {}
    function mint(address to_, uint256 amount_) external {
        _mint(to_, amount_);
    }
}

contract mockUSDT is ERC20 {
    constructor() ERC20("MockUSDT", "MUSDT") {}
    function mint(address to_, uint256 amount_) external {
        _mint(to_, amount_);
    }
}

contract mockUSDC is ERC20 {
    constructor() ERC20("MockUSDC", "MUSDC") {}
    function mint(address to_, uint256 amount_) external {
        _mint(to_, amount_);
    }
}
contract presaleTest is Test {

    presale presaleTesting;
    mockToken mockTokenTestig;
    mockUSDT mockUSDTTesting;
    mockUSDC mockUSDCTesting;

    address owner_ = vm.addr(1);
    address user_ = vm.addr(2);
    address fundsReceiverAddress_ = vm.addr(5); 
    address dataFeedAddress_ = 0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612; 
    uint256 maxSellingAmount_ = 300000000 * 1e18; 
    uint256 startingTime_ = block.timestamp; 
    uint256 endingTime_ = block.timestamp + 5000;  
    uint256[][3] phases_;
    function setUp() public {
      
        phases_[0] = [10000000 * 1e18, 5000, block.timestamp + 1000];
        phases_[1] = [10000000 * 1e18, 500, block.timestamp + 1000];
        phases_[2] = [10000000 * 1e18, 50, block.timestamp + 1000];
        
        vm.startPrank(owner_);
        mockTokenTestig = new mockToken();
        mockUSDTTesting = new mockUSDT();
        mockUSDCTesting = new mockUSDC();
        address saleTokenAddress_ = address(mockTokenTestig);
        presaleTesting = new presale(saleTokenAddress_, address(mockUSDTTesting), address(mockUSDCTesting), fundsReceiverAddress_, dataFeedAddress_, maxSellingAmount_, startingTime_, endingTime_, phases_);
        vm.stopPrank();
    }

    function testMockTokenMintsCorrectly() public {
        vm.startPrank(owner_);
        uint256 balanceBefore_ = IERC20(address(mockTokenTestig)).balanceOf(address(owner_));
        mockTokenTestig.mint(owner_, maxSellingAmount_);
        uint256 balanceAfter_ = IERC20(address(mockTokenTestig)).balanceOf(address(owner_));
        assert(balanceAfter_ - balanceBefore_ == maxSellingAmount_);
        vm.stopPrank();
    }

    function testPresaleStartCorrectly() public {
        vm.startPrank(owner_);
        uint256 balanceBefore = IERC20(address(mockTokenTestig)).balanceOf(address(presaleTesting));
        mockTokenTestig.mint(owner_, maxSellingAmount_);
        mockTokenTestig.approve(address(presaleTesting), maxSellingAmount_);
        presaleTesting.startPresale();
        uint256 balanceAfter = IERC20(address(mockTokenTestig)).balanceOf(address(presaleTesting));
        assert(balanceAfter - balanceBefore == maxSellingAmount_);
        vm.stopPrank();
    }

    function testOnlyOwnerCanStartPresale() public {
        vm.startPrank(user_);
        mockTokenTestig.mint(user_, maxSellingAmount_);
        mockTokenTestig.approve(address(presaleTesting), maxSellingAmount_);
        vm.expectRevert();
        presaleTesting.startPresale();
        vm.stopPrank();        
    }

    function testUserCanBuyWithStableCoin() public {
        
        vm.startPrank(owner_);
        uint256 balanceBefore = IERC20(address(mockTokenTestig)).balanceOf(address(presaleTesting));
        mockTokenTestig.mint(owner_, maxSellingAmount_);
        mockTokenTestig.approve(address(presaleTesting), maxSellingAmount_);
        presaleTesting.startPresale();
        uint256 balanceAfter = IERC20(address(mockTokenTestig)).balanceOf(address(presaleTesting));
        assert(balanceAfter - balanceBefore == maxSellingAmount_);
        vm.stopPrank();

        uint256 amount_ = 0.05 * 1e6;
        deal(address(mockUSDTTesting), user_, amount_);
        vm.startPrank(user_);
        IERC20(address(mockUSDTTesting)).approve(address(presaleTesting),amount_);
        presaleTesting.buyWithStable(address(mockUSDTTesting), amount_);
        vm.stopPrank();

    }

        function testUserCanBuyWithEther() public {
        
        vm.startPrank(owner_);
        uint256 balanceBefore = IERC20(address(mockTokenTestig)).balanceOf(address(presaleTesting));
        mockTokenTestig.mint(owner_, maxSellingAmount_);
        mockTokenTestig.approve(address(presaleTesting), maxSellingAmount_);
        presaleTesting.startPresale();
        uint256 balanceAfter = IERC20(address(mockTokenTestig)).balanceOf(address(presaleTesting));
        assert(balanceAfter - balanceBefore == maxSellingAmount_);
        vm.stopPrank();

        uint256 etherAmount = 0.00003 * 1e18;
        deal(user_, etherAmount);
        vm.startPrank(user_);
        presaleTesting.buyWithEther{value: etherAmount}();
        vm.stopPrank();

    }

        function testUserCanClaim() public {
       
        vm.startPrank(owner_);
        uint256 balanceBefore = IERC20(address(mockTokenTestig)).balanceOf(address(presaleTesting));
        mockTokenTestig.mint(owner_, maxSellingAmount_);
        mockTokenTestig.approve(address(presaleTesting), maxSellingAmount_);
        presaleTesting.startPresale();
        uint256 balanceAfter = IERC20(address(mockTokenTestig)).balanceOf(address(presaleTesting));
        assert(balanceAfter - balanceBefore == maxSellingAmount_);
        vm.stopPrank();

        uint256 etherAmount = 0.00003 * 1e18;
        deal(user_, etherAmount);
        vm.startPrank(user_);
        presaleTesting.buyWithEther{value: etherAmount}();
        vm.warp(endingTime_ + 1000);
        uint256 balance2Before = IERC20(address(mockTokenTestig)).balanceOf(user_);
        uint256 claimedTokens = presaleTesting.userTokenBalance(user_);
        presaleTesting.claim();
        uint256 balance2After = IERC20(address(mockTokenTestig)).balanceOf(user_);
        assert(balance2After - balance2Before == claimedTokens);
        vm.stopPrank();

    } 

    function testUserBlokedCanNotBuyWithStable() public {
       
        vm.startPrank(owner_);
        presaleTesting.blacklist(user_);
        vm.stopPrank();

        vm.startPrank(user_);
        vm.expectRevert();
        presaleTesting.buyWithStable(address(mockUSDCTesting), 0.05 * 1e6);
        vm.stopPrank();
    }

    function testUserBlokedCanNotBuyWithEther() public {
       
        vm.startPrank(owner_);
        presaleTesting.blacklist(user_);
        vm.stopPrank();

        uint256 etherAmount = 1 ether;
        deal(user_, etherAmount);
       
        vm.startPrank(user_);
        vm.expectRevert();
        presaleTesting.buyWithEther{value: etherAmount}();
        vm.stopPrank();
    }    



    function testUserBlokedCanNotClaim() public {
       
        vm.startPrank(owner_);
        uint256 balanceBefore = IERC20(address(mockTokenTestig)).balanceOf(address(presaleTesting));
        mockTokenTestig.mint(owner_, maxSellingAmount_);
        mockTokenTestig.approve(address(presaleTesting), maxSellingAmount_);
        presaleTesting.startPresale();
        uint256 balanceAfter = IERC20(address(mockTokenTestig)).balanceOf(address(presaleTesting));
        assert(balanceAfter - balanceBefore == maxSellingAmount_);
        vm.stopPrank();

        uint256 etherAmount = 0.00003 * 1e18;
        deal(user_, etherAmount);
        vm.startPrank(user_);
        presaleTesting.buyWithEther{value: etherAmount}();
        vm.stopPrank();

        vm.startPrank(owner_);
        presaleTesting.blacklist(user_);
        vm.stopPrank();

        vm.startPrank(user_);
        vm.warp(endingTime_ + 1000);
        vm.expectRevert();
        presaleTesting.claim();
        vm.stopPrank();

    }    

    function testOnlyOwnerCanWithdrawERC20() public {
        uint256 amount = 1 * 1e6;
        vm.startPrank(user_);
        vm.expectRevert();
        presaleTesting.emergencyERC2OWithdraw(address(mockUSDCTesting), amount);
        vm.stopPrank();
    }

        function testOnlyOwnerCanWithdrawEther() public {
        vm.startPrank(user_);
        vm.expectRevert();
        presaleTesting.emergencyETHWithdraw();
        vm.stopPrank();
    }

    function testUserGetETHPriceCorrectly() public {
        vm.startPrank(user_);
        uint256 price = presaleTesting.getEtherPrice();
        assert(price > 0);
        vm.stopPrank();        
    }

}