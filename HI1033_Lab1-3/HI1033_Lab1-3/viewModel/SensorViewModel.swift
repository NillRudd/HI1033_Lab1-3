//
//  SensorViewModel.swift
//  HI1033_Lab1-3
//
//  Created by Niklas Roslund on 2023-12-11.
//


//Polar Sense B36BE122

import Foundation
import CoreBluetooth

class SensorViewModel: ObservableObject, BluetoothConnectDelegate, InternalConnectDelegate {
    
    @Published private var theModel: SensorModel
    private let BLEConnect = BluetoothConnect()
    private let IPHConnect = InternalConnect()
    @Published var devices: [CBPeripheral] = []
    private var timer: Timer?
    
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
    
    func periferalChoosen(_ pheriferal : CBPeripheral){
        BLEConnect.choosePeriferal(pheriferal)
        theModel.setChosenDevice(pheriferal)
        timer10BLuetooth()
    }
    
    func timer10BLuetooth(){
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { [weak self] _ in
            self?.cancelTimerBlueTooth()
        }
    }
    
    func cancelTimerBlueTooth() {
        self.timer?.invalidate()
        self.BLEConnect.stop()
    }
    
    func timer10Internal(){
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { [weak self] _ in
            self?.cancelTimerInternal()
        }
    }
    
    func cancelTimerInternal(){
        self.timer?.invalidate()
        self.IPHConnect.stop()
    }
    
    func internalButtonClicked() {
        // code to start the internal sensor
        theModel.setMode(SensorMode.INTERNAL)
        timer10Internal()
        //true for both, false for accelerometer maybe change to enum?
        IPHConnect.start(true)
    }
    
    func bluetoothConnectDidDiscoverPeripheral(_ peripheral: CBPeripheral) {
        devices.append(peripheral)
    }
    
    func returnAccelerometerData(_ x: Double,_ y: Double,_ z:Double) {
        
    }
    
    func returnGyroData(_ x: Double,_ y: Double,_ z:Double) {

    }
}
