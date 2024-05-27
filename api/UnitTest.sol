// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/V3.sol";

contract TestV3 {
    V3 v3 = V3(DeployedAddresses.V3());

    function testAddMedicine() public {
        v3.registerMedicine("MedicineA", 2, 8, 30, 70);
        (uint temperatureRangeMin, uint temperatureRangeMax, uint humidityRangeMin, 
        uint humidityRangeMax) = v3.getMedicineDetails("MedicineA");
        Assert.equal(temperatureRangeMin, 2, "Temperature Range Min should be 2");
        Assert.equal(temperatureRangeMax, 8, "Temperature Range Max should be 8");
        Assert.equal(humidityRangeMin, 30, "Humidity Range Min should be 30");
        Assert.equal(humidityRangeMax, 70, "Humidity Range Max should be 70");
    }

    function testRegisterManufacturer() public {
        v3.registerManufacturer("ManufacturerA");
        bool isRegistered = v3.isRegisteredUser("ManufacturerA");
        Assert.isTrue(isRegistered, "ManufacturerA should be registered");
    }

    function testAddBatch() public {
        v3.addBatch("MedicineA", "ManufacturerA", block.timestamp);
        uint numBatches = v3.getNumberBatchesForManufacturer("ManufacturerA");
        Assert.equal(numBatches, 1, "Number of batches should be 1");
    }

    function testAddSensorData() public {
        bool isValid = v3.addSensorData("ManufacturerA", 5, 50, block.timestamp);
        Assert.isTrue(isValid, "Sensor data should be valid");
    }

    function testGetSensorData() public {
        (uint[] memory temperatures, uint[] memory humidities, uint[] memory createdAts, 
        string memory medicineName) = v3.getSensorData("ManufacturerA$b0");
        Assert.equal(temperatures.length, 1, "Length of temperatures array should be 1");
        Assert.equal(humidities.length, 1, "Length of humidities array should be 1");
        Assert.equal(createdAts.length, 1, "Length of createdAts array should be 1");
        Assert.equal(medicineName, "MedicineA", "Medicine name should be MedicineA");
    }
}
