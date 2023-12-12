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
    private let IPHConnect = IphoneConnect()
    @Published var devices: [CBPeripheral] = []
    private var timer: Timer?
    var bluetoothDataArray : [FilteredData]{
        theModel.bluetoothFilteredDataArray
    }
    
    
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
    
    func internalButtonClicked() {
        // code to start the internal sensor
        theModel.setMode(SensorMode.INTERNAL)
        timer10BLuetooth()
        IPHConnect.start()
    }
    
    func bluetoothConnectDidDiscoverPeripheral(_ peripheral: CBPeripheral) {
        devices.append(peripheral)
    }
    
    func retriveSensorData(xSample: Int16, ySample: Int16, zSample: Int16){
        var filteredData : FilteredData = FilteredData(x: 0, y: 0, z: 0)

        if theModel.bluetoothFilteredDataArray.count>1{
            filteredData.x = filterData(currentInput: Double(xSample), previousOutput: theModel.bluetoothFilteredDataArray.last!.x)
            filteredData.y = filterData(currentInput: Double(ySample), previousOutput: theModel.bluetoothFilteredDataArray.last!.y)
            filteredData.z = filterData(currentInput: Double(zSample), previousOutput: theModel.bluetoothFilteredDataArray.last!.z)
            
            //theModel.alpha*Double(xSample) + (1 - theModel.alpha) * theModel.bluetoothDataArray.last
            
        } else{
            filteredData.x = Double(xSample)
            filteredData.y = Double(ySample)
            filteredData.z = Double(zSample)
        }
        
        let magnitude = sqrt(filteredData.x * filteredData.x + filteredData.y * filteredData.y + filteredData.z * filteredData.z)
        let cosElevationAngle = filteredData.z / magnitude
             let elevationAngleRadians = acos(cosElevationAngle)
             let elevationAngleDegrees = elevationAngleRadians * (180.0 / .pi)
            print("Elevation angles degrees: \(elevationAngleDegrees)")
        
        
            theModel.addBluetoothData(filteredData)
    
    }
    
    
    func filterData(currentInput: Double, previousOutput: Double) -> Double{
        return (theModel.alpha * currentInput) + (1 - theModel.alpha) * previousOutput
    }
    
}
