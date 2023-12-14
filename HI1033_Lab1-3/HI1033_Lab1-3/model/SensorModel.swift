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
    private (set) var alpha : Double = 0.5
    private (set) var recordedDataA1 : [Measurement] = []
    private (set) var recordedDataA2 : [Measurement] = []
    private (set) var rawAngleAccArray : [Double] = []
    private (set) var rawAngleGyroArray : [Double] = []

    


    
    
    init() {
        
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
    
    mutating func addMeassurementA1(angle: Double, timestamp: Date){
        recordedDataA1.append(Measurement(angle: angle, timestamp: timestamp))
    }
    
    mutating func addMeassurementA2(angle: Double, timestamp: Date){
        recordedDataA2.append(Measurement(angle: angle, timestamp: timestamp))
    }
    
    
    
    mutating func addRawAngleAcc(_ rawAngleAcc: Double){
        rawAngleAccArray.append(rawAngleAcc)
    }    
    
    mutating func addRawAngleGyro(_ rawAngleGyro: Double){
        rawAngleGyroArray.append(rawAngleGyro)
    }
    
    mutating func filterDataA1(xSample: Int16, ySample: Int16, zSample: Int16) -> FilteredData{
        var filteredData : FilteredData = FilteredData(x: 0, y: 0, z: 0)

        if filteredDataArrayA1.count>1{
            filteredData.x = filterAcceleration(currentInput: Double(xSample), previousOutput: filteredDataArrayA1.last!.x)
            filteredData.y = filterAcceleration(currentInput: Double(ySample), previousOutput: filteredDataArrayA1.last!.y)
            filteredData.z = filterAcceleration(currentInput: Double(zSample), previousOutput: filteredDataArrayA1.last!.z)
            
            //theModel.alpha*Double(xSample) + (1 - theModel.alpha) * theModel.bluetoothDataArray.last
            
        } else{
            filteredData.x = Double(xSample)
            filteredData.y = Double(ySample)
            filteredData.z = Double(zSample)
        }
        //print("previous: \(String(describing: theModel.bluetoothFilteredDataArray.last))")
        //print("DATA: \( filteredData)")
        addFilteredDataA1(filteredData)
        return filteredData
    }
    
    
    
    mutating func filterDataA1New(){
        var filteredAngle: Double = 0.0
        
        if rawAngleAccArray.count>1{
            filteredAngle = filterAcceleration(currentInput: rawAngleAccArray[rawAngleAccArray.count-1], previousOutput: rawAngleAccArray[rawAngleAccArray.count-2])
        }
        
        recordedDataA1.append(Measurement(angle: filteredAngle, timestamp: Date.now))
    }
    
    func calculateAngleNew(_ x: Double, _ y: Double, _ z: Double) -> Double{
        let magnitude = sqrt(x * x + y * y + z * z)
        let cosElevationAngle = z / magnitude
        let elevationAngleRadians = acos(cosElevationAngle)
        let elevationAngleDegrees = elevationAngleRadians * (180.0 / .pi)
        return elevationAngleDegrees
    }
    
    
    mutating func filterDataA2New() -> Double {
        var filteredAngle = 0.0
        if(rawAngleAccArray.count > 0 && rawAngleGyroArray.count > 0){
            filteredAngle = filterGyroAndAccelerationNew(angleAcc: rawAngleAccArray.last!, angleGyro: rawAngleGyroArray.last!, alpha: alpha)
   
        }
        return filteredAngle
    }
    
    func filterGyroAndAccelerationNew(angleAcc: Double, angleGyro: Double, alpha: Double) -> Double {
        return (alpha * angleAcc) + ((1 - alpha) * angleGyro)
    }
    

    mutating func filterDataA2(_ xGyro: Double,_ yGyro: Double,_ zGyro: Double,_ xAcc: Double,_ yAcc: Double,_ zAcc: Double) -> FilteredData {
        var filteredData = FilteredData(x: 0, y: 0, z: 0)

        if filteredDataArrayA2.count > 1 {
            filteredData.x = filterGyroAndAcceleration(linearAcceleration: xAcc, gyroscope: xGyro, alpha: alpha)
            filteredData.y = filterGyroAndAcceleration(linearAcceleration: yAcc, gyroscope: yGyro, alpha: alpha)
            filteredData.z = filterGyroAndAcceleration(linearAcceleration: zAcc, gyroscope: zGyro, alpha: alpha)
        } else {
            // If there's no previous data, just use the current samples
            filteredData.x = xAcc
            filteredData.y = yAcc
            filteredData.z = zAcc
        }

        addFilteredDataA2(filteredData)
        return filteredData
    }

    func calculateAngle(_ filteredData: FilteredData) -> Double{
        let magnitude = sqrt(filteredData.x * filteredData.x + filteredData.y * filteredData.y + filteredData.z * filteredData.z)
        let cosElevationAngle = filteredData.z / magnitude
        let elevationAngleRadians = acos(cosElevationAngle)
        let elevationAngleDegrees = elevationAngleRadians * (180.0 / .pi)
        return elevationAngleDegrees
    }
    
    func filterAcceleration(currentInput: Double, previousOutput: Double) -> Double{
        return (alpha * currentInput) + (1 - alpha) * previousOutput
    }
    
    func filterGyroAndAcceleration(linearAcceleration: Double, gyroscope: Double, alpha: Double) -> Double {
        return (alpha * linearAcceleration) + ((1 - alpha) * gyroscope)
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
        //csvWriter?.writeField("Computed angle Algorithm 2")
        
        csvWriter?.finishLine()
        
        for index in 0..<recordedDataA1.count {
            csvWriter?.writeField(recordedDataA1[index].angle)
            //csvWriter?.writeField(recordedDataA2[index].angle)
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

struct Measurement {
    var angle: Double
    var timestamp: Date
            
    init(angle: Double, timestamp: Date){
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
