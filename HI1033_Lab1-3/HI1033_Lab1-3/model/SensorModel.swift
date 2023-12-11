//
//  sensorModel.swift
//  HI1033_Lab1-3
//
//  Created by Niklas Roslund on 2023-12-11.
//

import Foundation
import CoreBluetooth


struct SensorModel {
    
    let BLEConnect = BluetoothConnect()
    
    init() {
        
    }
    
    mutating func buttonPressed() {
        BLEConnect.start()
        //bluetoothDevices = BLEConnect.getBlueToothDevices()
    }
    /*
    mutating func bluetoothConnectDidDiscoverPeripheral(_ peripheral: CBPeripheral) {
        bluetoothDevices.append(peripheral)
    }
     */
}
