//
//  SensorViewModel.swift
//  HI1033_Lab1-3
//
//  Created by Niklas Roslund on 2023-12-11.
//

import Foundation
import CoreBluetooth

class SensorViewModel: ObservableObject, BluetoothConnectDelegate {
    
    @Published private var theModel: SensorModel
    private let BLEConnect = BluetoothConnect()
    @Published var devices: [CBPeripheral] = []
    
    init() {
        theModel = SensorModel()
        BLEConnect.delegate = self
    }
    
    func ButtonClicked() {
        BLEConnect.start()
        devices = []
    }
    
    func periferalChoosen(){
        //BLEConnect.choosePeriferal()
    }
    
    func bluetoothConnectDidDiscoverPeripheral(_ peripheral: CBPeripheral) {
        devices.append(peripheral)
        print("successfull call")
    }
}
