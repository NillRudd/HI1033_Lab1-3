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
    
    
    init() {
        
    }
    
    
    mutating func setChosenDevice(_ pheriferal : CBPeripheral){
        chosenBluetoothDevice = pheriferal
    }
    
    mutating func setMode(_ mode: SensorMode){
        self.mode = mode
    }
    
}



enum SensorMode {
    case INTERNAL
    case BLUETOOTH
}
