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
    @Published var recordedDataA1 : [Measurement] = []
    @Published var recordedDataA2 : [Measurement] = []
    /*
    var recordedDataA1 : [Measurement]{
        theModel.recordedDataA1
    }
    
    var recordedDataA2 : [Measurement]{
        theModel.recordedDataA2
    }
     */
    
    var chosenBluetoothDevice : CBPeripheral?{
        theModel.chosenBluetoothDevice
    }
    
    var mode : SensorMode{
        theModel.mode
    }
    
    init() {
        theModel = SensorModel()
        BLEConnect.delegate = self
        IPHConnect.delegate = self
    }
    
    func bluetoothButtonClicked() {
        theModel.setMode(SensorMode.BLUETOOTH)
        BLEConnect.start()
        devices = []
    }
    
    func internalButtonClicked() {
        theModel.clearData()
        recordedDataA1 = []
        recordedDataA2 = []
        theModel.setMode(SensorMode.INTERNAL)
        timer10Internal()
        //TODO: true for both, false for accelerometer maybe change to enum?
        IPHConnect.start()
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
    
    func timer10Internal(){
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { [weak self] _ in
            self?.cancelTimerInternal()
        }
    }
    
    func cancelTimerBlueTooth() {
        self.timer?.invalidate()
        self.BLEConnect.stop()
        self.theModel.generateCSVFile()
    }
    
    func cancelTimerInternal(){
        self.timer?.invalidate()
        self.IPHConnect.stop()
        self.theModel.generateCSVFile()
    }
    
    func bluetoothConnectDidDiscoverPeripheral(_ peripheral: CBPeripheral) {
        devices.append(peripheral)
    }
    
    /*
    func returnAccelerometerDataInternal(_ x: Double,_ y: Double,_ z:Double) {
        let filteredData: FilteredData = theModel.filterDataA1(xSample: Int16(x*1024), ySample: Int16(y*1024), zSample: Int16(z*1024))
        let elevationAngleDegrees = theModel.calculateAngle(filteredData)
        print("Elevation angles degrees: \(elevationAngleDegrees)")
        theModel.addMeassurement(angle: elevationAngleDegrees, timestamp: Date.now)
    }
     */
    func retriveSensorData(xSample: Int16, ySample: Int16, zSample: Int16){
        let filteredData: FilteredData = theModel.filterDataA1(xSample: xSample, ySample: ySample, zSample: zSample)
        let elevationAngleDegrees = theModel.calculateAngle(filteredData)
            print("Elevation angles degrees: \(elevationAngleDegrees)")
        theModel.addMeassurementA1(elevationAngleDegrees, 0.0)
    }
    
    func returnBothDataInternal(_ xGyro: Double,_ yGyro: Double,_ zGyro:Double, _ xAcc: Double,_ yAcc: Double,_ zAcc:Double, _ timestamp: Double) {
        //TODO: implement the second algorithm for both types of data
        let filteredDataA1: FilteredData = theModel.filterDataA1(xSample: Int16(xAcc*1024), ySample: Int16(yAcc*1024), zSample: Int16(zAcc*1024))
        let filteredDataA2: FilteredData = theModel.filterDataA2(xGyro, yGyro, zGyro, xAcc, yAcc, zAcc)
        let elevationAngleDegreesA1 = theModel.calculateAngle(filteredDataA1)
        let elevationAngleDegreesA2 = theModel.calculateAngle(filteredDataA2)
        theModel.addMeassurementA1(elevationAngleDegreesA1, timestamp)
        theModel.addMeassurementA2(elevationAngleDegreesA2, timestamp)
        recordedDataA1.append(Measurement(angle: elevationAngleDegreesA1, timestamp: timestamp))
        recordedDataA2.append(Measurement(angle: elevationAngleDegreesA2, timestamp: timestamp))
    }
}
