//
//  SensorViewModel.swift
//  HI1033_Lab1-3
//
//  Created by Niklas Roslund on 2023-12-11.
//

import Foundation
import CoreBluetooth

class SensorViewModel: ObservableObject {
    @Published var bluetoothConnect: BluetoothConnect
    
    @Published private var theModel: SensorModel
    
    var devices : [CBPeripheral] {
        bluetoothConnect.bluetoothDevices
    }
    
    
    init() {
        theModel = SensorModel()
        bluetoothConnect = BluetoothConnect()
    }
    
    func ButtonClicked() {
        bluetoothConnect.start()
    }
    
}
