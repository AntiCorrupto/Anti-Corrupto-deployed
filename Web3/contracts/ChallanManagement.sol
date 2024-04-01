// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ChallanManagement {
    address public owner;
    uint64 public userChallanCount;
    uint64 public vehicleChallanCount;

    struct Challan {
        uint256 challanId;
        uint256 vehicleId;
        uint256 amount;
        bool paid;
        string reason;
        uint256 issueDate;
        string location;
    }

    mapping(address => Challan[]) public Challans;

    event ChallanIssued(
        address indexed user,
        uint256 challanId,
        uint256 vehicleId,
        uint256 amount,
        string reason,
        string location,
        uint256 issueDate
    );

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function issueChallan(
        uint256 _vehicleId,
        uint256 _amount,
        string memory _reason,
        string memory _location
    ) public {
        uint256 challanId = uint256(
            keccak256(abi.encodePacked(msg.sender, block.timestamp))
        );

        uint256 issueDate = timeCall();

        Challan memory newChallan = Challan(
            challanId,
            _vehicleId,
            _amount,
            false,
            _reason,
            issueDate,
            _location
        );
        userChallanCount += 1;

        Challans[msg.sender].push(newChallan);

        emit ChallanIssued(
            msg.sender,
            challanId,
            _vehicleId,
            _amount,
            _reason,
            _location,
            issueDate
        );
    }

    function timeCall() public view returns (uint256) {
        return block.number;
    }

    function payChallan(uint256 _challanId) public payable {
        Challan storage challan = Challans[msg.sender][_challanId];

        require(!challan.paid, "Challan already paid");
        require(
            msg.value >= challan.amount,
            "Insufficient funds to pay challan"
        );

        challan.paid = true;
        payable(owner).transfer(msg.value);

        emit ChallanIssued(
            msg.sender,
            challan.challanId,
            challan.vehicleId,
            challan.amount,
            challan.reason,
            challan.location,
            challan.issueDate
        );
    }

    function getUserChallans(
        address _userAddress
    ) public view returns (Challan[] memory) {
        return Challans[_userAddress];
    }

    function getChallanDetails(
        uint256 _challanId
    ) public view returns (Challan memory) {
        return Challans[msg.sender][_challanId];
    }

    function getUserChallanCount() public view returns (uint64) {
        return userChallanCount;
    }

    function getVehicleChallanCount(
        uint256 _vehicleId
    ) public view returns (uint256) {
        uint256 count = 0;
        for (uint256 i = 0; i < Challans[msg.sender].length; i++) {
            if (Challans[msg.sender][i].vehicleId == _vehicleId) {
                count++;
            }
        }
        return count;
    }

    function getChallansForVehicle(
        uint256 _vehicleId
    ) public view returns (Challan[] memory) {
        Challan[] memory vehicleChallans = new Challan[](
            getVehicleChallanCount(_vehicleId)
        );
        uint256 index = 0;
        for (uint256 i = 0; i < Challans[msg.sender].length; i++) {
            if (Challans[msg.sender][i].vehicleId == _vehicleId) {
                vehicleChallans[index] = Challans[msg.sender][i];
                index++;
            }
        }
        return vehicleChallans;
    }
}
