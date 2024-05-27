// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PharmaSupplyChain {
    struct Medicine {
        string name;
        uint temperatureRangeMin;
        uint temperatureRangeMax;
        uint humidityRangeMin;
        uint humidityRangeMax;
    }

    struct SensorData {
        uint temperature;
        uint humidity;
        uint createdAt; 
    }

    struct Manufacturer {
        string name;
        bool isRegistered;
    }

     function registerManufacturer(string memory _name) external {
        require(!manufacturers[_name].isRegistered, "Manufacturer already registered");

        manufacturers[_name] = Manufacturer(_name, true);
    }

    function isRegisteredUser(string memory _name) external view returns (bool) {
        return manufacturers[_name].isRegistered;
    }

    struct Batch {
        string batchId;
        string medicineName;
        SensorData[] sensorData;
        uint createdAt;
    }

    mapping(string => string[]) public manufacturerBatches;
    mapping(string => Batch) public batches;
    event BatchAdded(address indexed manufacturer, string batchId, string medicineName);
    mapping(string => Medicine) public medicines;
    string[] public medicineNames;
    mapping(string => Manufacturer) public manufacturers;

    function registerMedicine(
        string memory _name,
        uint _temperatureRangeMin,
        uint _temperatureRangeMax,
        uint _humidityRangeMin,
        uint _humidityRangeMax
    ) external {
        require(medicines[_name].temperatureRangeMin == 0, "Medicine already registered");

        Medicine storage newMedicine = medicines[_name];
        newMedicine.name = _name;
        newMedicine.temperatureRangeMin = _temperatureRangeMin;
        newMedicine.temperatureRangeMax = _temperatureRangeMax;
        newMedicine.humidityRangeMin = _humidityRangeMin;
        newMedicine.humidityRangeMax = _humidityRangeMax;

        medicineNames.push(_name);
    }

   

    function addBatch(
        string memory _medicineName, 
        string memory _manufacturerName,
        uint _createdAt
    ) external {
        require(bytes(medicines[_medicineName].name).length != 0, "Medicine not registered");
        uint batchIndex = manufacturerBatches[_manufacturerName].length;
        string memory batchId;

        if (batchIndex == 0) {
            batchId = string(abi.encodePacked(_manufacturerName, "$b0"));
        } else {
            batchId = string(abi.encodePacked(_manufacturerName, "$b", uintToString(batchIndex)));
        }

        require(bytes(batches[batchId].batchId).length == 0, "BatchId already exists");

        Batch storage newBatch = batches[batchId];
        newBatch.batchId = batchId;
        newBatch.medicineName = _medicineName;
        newBatch.createdAt = _createdAt;
        manufacturerBatches[_manufacturerName].push(batchId);
        emit BatchAdded(msg.sender, batchId, _medicineName);
    }

    function uintToString(uint v) internal pure returns (string memory) {
        uint maxlength = 100;
        bytes memory reversed = new bytes(maxlength);
        uint i = 0;
        while (v != 0) {
            uint remainder = v % 10;
            v = v / 10;
            reversed[i++] = bytes1(uint8(48 + remainder));
        }
        bytes memory s = new bytes(i);
        for (uint j = 0; j < i; j++) {
            s[j] = reversed[i - j - 1];
        }
        return string(s);
    }

    function addSensorData(
        string memory _manufacturerName, uint _temperature, 
        uint _humidity, uint _createdAt
    ) external returns (bool) {
        require(manufacturerBatches[_manufacturerName].length != 0, "Batch does not exist");
        uint lastIndex = manufacturerBatches[_manufacturerName].length - 1;
        string memory batchId = manufacturerBatches[_manufacturerName][lastIndex];
        Batch storage batch = batches[batchId];
        bool isValid = true;

        if (_temperature < medicines[batch.medicineName].temperatureRangeMin || _temperature > medicines[batch.medicineName].temperatureRangeMax) {
            isValid = false;
        }
        if (_humidity < medicines[batch.medicineName].humidityRangeMin || _humidity > medicines[batch.medicineName].humidityRangeMax) {
            isValid = false;
        }

        SensorData storage newSensorData = batch.sensorData.push();
        newSensorData.temperature = _temperature;
        newSensorData.humidity = _humidity;
        newSensorData.createdAt = _createdAt;
        return isValid;
    }

    function getSensorData(string memory _batchId) external view returns (
        uint[] memory temperatures, uint[] memory humidities, uint[] memory createdAts, 
        string memory medicineName) {
        Batch storage batch = batches[_batchId];
        require(bytes(batch.batchId).length != 0, "Batch does not exist");

        uint length = batch.sensorData.length;
        temperatures = new uint[](length);
        humidities = new uint[](length);
        createdAts = new uint[](length);
        medicineName = batch.medicineName;

        for (uint i = 0; i < length; i++) {
            SensorData storage data = batch.sensorData[i];
            temperatures[i] = data.temperature;
            humidities[i] = data.humidity;
            createdAts[i] = data.createdAt;
        }
    }

    function getAllMedicineNames() external view returns (string[] memory) {        
        return medicineNames;
    }

    function getAllBatchDetailsOfManufacturer(string memory _manufacturerName) 
    external view returns (
        string[] memory, string[] memory, uint[] memory, uint[] memory
    ) {
        string[] memory batchIds = manufacturerBatches[_manufacturerName];
        string[] memory batchIdDetails = new string[](batchIds.length);
        string[] memory medicineNamesArr = new string[](batchIds.length);
        uint[] memory numReadings = new uint[](batchIds.length);
        uint[] memory createdAts = new uint[](batchIds.length);

        for (uint i = 0; i < batchIds.length; i++) {
            Batch storage batch = batches[batchIds[i]];
            batchIdDetails[i] = batch.batchId;
            medicineNamesArr[i] = batch.medicineName;
            numReadings[i] = batch.sensorData.length;
            createdAts[i] = batch.createdAt;
        }

        return (batchIdDetails, medicineNamesArr, numReadings, createdAts);
    }

    function getNumberBatchesForManufacturer(string memory _manufacturerName) external view returns(uint) {
        return manufacturerBatches[_manufacturerName].length;
    }

    function getMedicineDetails(string memory _medicineName) external view returns (
        uint temperatureRangeMin,
        uint temperatureRangeMax,
        uint humidityRangeMin,
        uint humidityRangeMax
    ) {
        Medicine storage medicine = medicines[_medicineName];
        require(bytes(medicine.name).length != 0, "Medicine not found");
        temperatureRangeMin = medicine.temperatureRangeMin;
        temperatureRangeMax = medicine.temperatureRangeMax;
        humidityRangeMin = medicine.humidityRangeMin;
        humidityRangeMax = medicine.humidityRangeMax;
    }
}
