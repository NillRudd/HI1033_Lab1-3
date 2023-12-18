//
//  sensorModel.swift
//  HI1033_Lab1-3
//
//  Created by Niklas Roslund on 2023-12-11.
//

import Foundation
import CoreBluetooth


struct SensorModel {
    private (set) var chosenBluetoothDevice : CBPeripheral?
    private (set) var mode : SensorMode = SensorMode.INTERNAL
    private (set) var filteredDataArrayA1 : [FilteredData] = []
    private (set) var filteredDataArrayA2 : [FilteredData] = []
    private (set) var alpha : Double = 0.85
    private (set) var recordedDataA1 : [Measurement] = []
    private (set) var recordedDataA2 : [Measurement] = []
    private (set) var rawAngleAccArray : [Double] = []
    private (set) var rawAngleGyroArray : [Double] = []
    private (set) var timestampBluetooth : Double = 0.0
    
    
    init() {
        
    }
    
    mutating func clearData() {
        filteredDataArrayA1 = []
        filteredDataArrayA2 = []
        recordedDataA1 = []
        recordedDataA2 = []
        rawAngleAccArray = []
        rawAngleGyroArray = []
        timestampBluetooth = 0.0
    }
    
    mutating func setTimestampBluetooth(_ timestamp: Double){
        timestampBluetooth = timestamp
    }
    
    mutating func setChosenDevice(_ pheriferal : CBPeripheral){
        chosenBluetoothDevice = pheriferal
    }
    
    mutating func setMode(_ mode: SensorMode){
        self.mode = mode
    }
    
    mutating func addFilteredDataA1(_ sensorData: FilteredData){
        filteredDataArrayA1.append(sensorData)
    }
    
    mutating func addFilteredDataA2(_ sensorData: FilteredData){
        filteredDataArrayA2.append(sensorData)
    }
    
    mutating func addMeasurementA1(_ angle: Double, _ timestamp: Double){
        recordedDataA1.append(Measurement(angle: angle, timestamp: timestamp))
    }
    
    mutating func addMeasurementA2(_ angle: Double,_ timestamp: Double){
        recordedDataA2.append(Measurement(angle: angle, timestamp: timestamp))
    }
    
    mutating func addRawAngleAcc(_ rawAngleAcc: Double){
        rawAngleAccArray.append(rawAngleAcc)
    }

    mutating func addRawAngleGyro(_ rawAngleGyro: Double){
        rawAngleGyroArray.append(rawAngleGyro)
    }

    func calculateAngle(_ filteredData: FilteredData) -> Double{
        let magnitude = sqrt(filteredData.x * filteredData.x + filteredData.y * filteredData.y + filteredData.z * filteredData.z)
        let cosElevationAngle = filteredData.z / magnitude
        let elevationAngleRadians = acos(cosElevationAngle)
        let elevationAngleDegrees = elevationAngleRadians * (180.0 / .pi)
        return elevationAngleDegrees
    }
    
    func filterAcceleration(currentInput: Double) -> Double{
        var previousOutput = 0.0
        if !recordedDataA1.isEmpty {
            previousOutput = recordedDataA1[recordedDataA1.count-1].angle
        }
        return (alpha * currentInput) + (1 - alpha) * previousOutput
    }
    
    func filterAcceleration(currentInput: Double, previousOutput: Double) -> Double{
        return (alpha * currentInput) + (1 - alpha) * previousOutput
    }
    
    func filterGyroAndAcceleration(_ linearAcceleration: Double, _ gyroscope: Double) -> Double {
            return (alpha * linearAcceleration) + ((1 - alpha) * gyroscope)
        }
    
    mutating func filterDataA1New() -> Double{
        var filteredAngle: Double = 0.0

        if rawAngleAccArray.count>1{
            filteredAngle = filterAcceleration(currentInput: rawAngleAccArray[rawAngleAccArray.count-1], previousOutput: rawAngleAccArray[rawAngleAccArray.count-2])
        }

        return filteredAngle
    }
    
    
    mutating func filterDataA2New() -> Double {
        var filteredAngle = 0.0
        if(rawAngleAccArray.count > 0 && rawAngleGyroArray.count > 0){
            filteredAngle = filterGyroAndAcceleration(rawAngleAccArray.last!, rawAngleGyroArray.last!)

        }
        return filteredAngle
    }
    
    
    //Now only gives the user  the calculated angle in the csv file
    //The file could be found in files app on your iphone,
    func generateCSVFile() {
        print("generating csv file")
        let sFileName = "test.csv"
        
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        
        let documentURL = URL(fileURLWithPath: documentDirectoryPath).appendingPathComponent(sFileName)
        
        let output = OutputStream.toMemory()
        
        let csvWriter = CHCSVWriter(outputStream: output, encoding: String.Encoding.utf8.rawValue, delimiter: ",".utf16.first!)
        
        //Headers for the csv file
        csvWriter?.writeField("Computed angle Algorithm 1")
        csvWriter?.writeField("Computed angle Algorithm 2")
        csvWriter?.writeField("Timestamp")
        
        csvWriter?.finishLine()
        
        for index in 0..<recordedDataA1.count {
            csvWriter?.writeField(recordedDataA1[index].angle)
            csvWriter?.writeField(recordedDataA2[index].angle)
            csvWriter?.writeField(recordedDataA2[index].timestamp)
            csvWriter?.finishLine()
        }
        
        csvWriter?.closeStream()
        
        let buffer = (output.property(forKey: .dataWrittenToMemoryStreamKey) as? Data)!
        
        do{
            try buffer.write(to: documentURL)
            print("file generated")
        }
        catch {
            print("error")
        }
    }
}

struct Measurement: Codable {
    var angle: Double
    var timestamp: Double
            
    init(angle: Double, timestamp: Double) {
        self.angle = angle
        self.timestamp = timestamp
    }
}

struct FilteredData {
    var x: Double
    var y: Double
    var z: Double
    
    init(x: Double, y: Double, z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }
}


enum SensorMode {
    case INTERNAL
    case BLUETOOTH
}
