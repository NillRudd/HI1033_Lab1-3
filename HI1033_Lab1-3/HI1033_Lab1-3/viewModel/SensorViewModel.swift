//
//  SensorViewModel.swift
//  HI1033_Lab1-3
//
//  Created by Niklas Roslund on 2023-12-11.
//


//Polar Sense B36BE122

import Foundation
import CoreBluetooth

class SensorViewModel: ObservableObject, BluetoothConnectDelegate {
    
    @Published private var theModel: SensorModel
    private let BLEConnect = BluetoothConnect()
    @Published var devices: [CBPeripheral] = []
    var chosenBluetoothDevice : CBPeripheral?{
        theModel.chosenBluetoothDevice
    }
    
    var mode : SensorMode{
        theModel.mode
    }
    
    init() {
        theModel = SensorModel()
        BLEConnect.delegate = self
    }
    
    func bluetoothButtonClicked() {
        theModel.setMode(SensorMode.BLUETOOTH)
        BLEConnect.start()
        devices = []
    }
    
    
    func internalButtonClicked() {
        // code to start the internal sensor
        theModel.setMode(SensorMode.INTERNAL)
        
    }
    
    func periferalChoosen(_ pheriferal : CBPeripheral){
        BLEConnect.choosePeriferal(pheriferal)
        theModel.setChosenDevice(pheriferal)
    }
    
    func bluetoothConnectDidDiscoverPeripheral(_ peripheral: CBPeripheral) {
        devices.append(peripheral)
        print("successfull call")
    }
    
    
    
}
