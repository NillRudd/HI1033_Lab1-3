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
    private let IPHConnect = IphoneConnect()
    @Published var devices: [CBPeripheral] = []
    private var timer: Timer?
    
    
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
        timer10BLuetooth()
    }
    
    func InternalChoosen() {
        timer10BLuetooth()
        IPHConnect.start()
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
    
    func timer10Iphone(){
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { [weak self] _ in
            self?.cancelTimerIphone()
        }
    }
    
    func cancelTimerIphone(){
        self.timer?.invalidate()
        self.IPHConnect.stop()
    }
    
    func bluetoothConnectDidDiscoverPeripheral(_ peripheral: CBPeripheral) {
        devices.append(peripheral)
    }
}
