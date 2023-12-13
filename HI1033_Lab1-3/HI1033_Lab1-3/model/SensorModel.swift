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
