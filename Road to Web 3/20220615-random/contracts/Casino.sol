//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract Casino {
    struct ProposedBet {
        address sideA;
        uint value;
        uint placedAt;
        bool accepted;
    }

    struct AcceptedBet {
        address sideB;
        uint acceptedAt;
        uint randomB;
    }

    mapping(uint => ProposedBet) public proposedBet;
    mapping(uint => AcceptedBet) public acceptedBet;

    event BetProposed(uint indexed _commitment, uint value);
    event BetAccepted(uint indexed _commitment, address indexed _sideA);
    event BetSettled(uint indexed _commitment, address winner, address loser, uint value);

    function proposeBet(uint _commitment) external payable {
        require(proposedBet[_commitment].value == 0, "there is already a bet on that commitment");
        require(msg.value > 0, "you need to actually bet something");

        proposedBet[_commitment].sideA = msg.sender;
        proposedBet[_commitment].value = msg.value;
        proposedBet[_commitment].placedAt = block.timestamp;

        emit BetProposed(_commitment, msg.value);
    }
    
    function acceptBet(uint _commitment, uint _random) external payable {
        require(!proposedBet[_commitment].accepted, "Bet has already been accepted");
        require(proposedBet[_commitment].sideA != address(0), "Nobody made that bet");
        require(msg.value == proposedBet[_commitment].value, "Need to bet the same amount as sideA");

        acceptedBet[_commitment].sideB = msg.sender;
        acceptedBet[_commitment].acceptedAt = block.timestamp;
        acceptedBet[_commitment].randomB = _random;
        proposedBet[_commitment].accepted = true;
        
        emit BetAccepted(_commitment, proposedBet[_commitment].sideA);
    }

    function reveal(uint _random) external {
        uint _commitment = uint256(keccak256(abi.encodePacked(_random)));

        address payable _sideA = payable(msg.sender);
        address payable _sideB = payable(acceptedBet[_commitment].sideB);

        uint _agreedRandom = _random ^ acceptedBet[_commitment].randomB;

        uint _value = proposedBet[_commitment].value;

        require(proposedBet[_commitment].sideA == msg.sender, "Not a bet you placed or wrong value");
        require(proposedBet[_commitment].accepted, "Bet has not been accepted yet");

        if (_agreedRandom % 2 == 0) {
            _sideA.transfer(2*_value);
            
            emit BetSettled(_commitment, _sideA, _sideB, _value);
        }
        else {
            _sideB.transfer(2*_value);

            emit BetSettled(_commitment, _sideB, _sideA, _value);
        }

        delete proposedBet[_commitment];
        delete acceptedBet[_commitment];
    }
}