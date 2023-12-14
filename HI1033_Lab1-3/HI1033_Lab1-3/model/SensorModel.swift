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
    private (set) var bluetoothFilteredDataArray : [FilteredData] = []
    private (set) var alpha : Double = 1.5
    private (set) var recordedData : [Measurement] = []


    
    
    init() {
        
    }
    
    
    mutating func setChosenDevice(_ pheriferal : CBPeripheral){
        chosenBluetoothDevice = pheriferal
    }
    
    mutating func setMode(_ mode: SensorMode){
        self.mode = mode
    }
    
    mutating func addBluetoothData(_ sensorData: FilteredData){
        bluetoothFilteredDataArray.append(sensorData)
    }
    
    mutating func addMeassurement(angle: Double, timestamp: Date){
        recordedData.append(Measurement(angle: angle, timestamp: timestamp))
    }
    
    mutating func filterDataA1(xSample: Int16, ySample: Int16, zSample: Int16) -> FilteredData{
        var filteredData : FilteredData = FilteredData(x: 0, y: 0, z: 0)

        if bluetoothFilteredDataArray.count>1{
            filteredData.x = filterAcceleration(currentInput: Double(xSample), previousOutput: bluetoothFilteredDataArray.last!.x)
            filteredData.y = filterAcceleration(currentInput: Double(ySample), previousOutput: bluetoothFilteredDataArray.last!.y)
            filteredData.z = filterAcceleration(currentInput: Double(zSample), previousOutput: bluetoothFilteredDataArray.last!.z)
            
            //theModel.alpha*Double(xSample) + (1 - theModel.alpha) * theModel.bluetoothDataArray.last
            
        } else{
            filteredData.x = Double(xSample)
            filteredData.y = Double(ySample)
            filteredData.z = Double(zSample)
        }
        //print("previous: \(String(describing: theModel.bluetoothFilteredDataArray.last))")
        //print("DATA: \( filteredData)")
        addBluetoothData(filteredData)
        return filteredData
    }

    mutating func filterDataA2(_ xGyro: Double,_ yGyro: Double,_ zGyro: Double,_ xAcc: Double,_ yAcc: Double,_ zAcc: Double) -> FilteredData {
        var filteredData = FilteredData(x: 0, y: 0, z: 0)

        if bluetoothFilteredDataArray.count > 1 {
            let lastFilteredData = bluetoothFilteredDataArray.last!

            filteredData.x = filterGyroAndAcceleration(linearAcceleration: xAcc, gyroscope: xGyro, alpha: alpha)
            filteredData.y = filterGyroAndAcceleration(linearAcceleration: yAcc, gyroscope: yGyro, alpha: alpha)
            filteredData.z = filterGyroAndAcceleration(linearAcceleration: zAcc, gyroscope: zGyro, alpha: alpha)
        } else {
            // If there's no previous data, just use the current samples
            filteredData.x = xAcc
            filteredData.y = yAcc
            filteredData.z = zAcc
        }

        addBluetoothData(filteredData)
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
        //csvWriter?.writeField("X-Value")
        //csvWriter?.writeField("Y-Value")
        //csvWriter?.writeField("Z-Value")
        csvWriter?.writeField("Computed angle")
        
        csvWriter?.finishLine()
        
        for index in 0..<recordedData.count {
            //csvWriter?.writeField(bluetoothFilteredDataArray[index].x)
            //csvWriter?.writeField(bluetoothFilteredDataArray[index].y)
            //csvWriter?.writeField(bluetoothFilteredDataArray[index].z)
            csvWriter?.writeField(recordedData[index].angle)
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
