//
//  sensorModel.swift
//  HI1033_Lab1-3
//
//  Created by Niklas Roslund on 2023-12-11.
//

import Foundation
import CoreBluetooth


struct SensorModel {
    private (set ) var bluetoothDevices : [CBPeripheral] = []
    
    
    
    
    mutating func bluetoothConnectDidDiscoverPeripheral(_ peripheral: CBPeripheral) {
        bluetoothDevices.append(peripheral)
    }
}
