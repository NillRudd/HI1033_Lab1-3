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
    private (set) var recordedData : [Measurement] = []
    private (set) var alpha : Double = 0.5
    private (set) var previousFilteredData : FilteredData = FilteredData(x: 0, y: 0, z: 0)


    
    
    init() {
        
    }
    
    
    mutating func setChosenDevice(_ pheriferal : CBPeripheral){
        chosenBluetoothDevice = pheriferal
    }
    
    mutating func setMode(_ mode: SensorMode){
        self.mode = mode
    }
    
    mutating func addMeassurement(angle: Double, timestamp: Date){
        recordedData.append(Measurement(angle: angle, timestamp: timestamp))
    }
    
    mutating func setPreviousFilteredData(_ previous : FilteredData){
        previousFilteredData.x = previous.x
        previousFilteredData.y = previous.y
        previousFilteredData.z = previous.z
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

struct Measurement {
    var angle: Double
    var timestamp: Date
            
    init(angle: Double, timestamp: Date){
        self.angle = angle
        self.timestamp = timestamp
    }
}


enum SensorMode {
    case INTERNAL
    case BLUETOOTH
}
