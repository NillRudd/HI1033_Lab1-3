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
    
    var DataArrayA1 : [FilteredData]{
        theModel.filteredDataArrayA1
    }
    
    var DataArrayA2 : [FilteredData]{
        theModel.filteredDataArrayA2
    }
    
    var recordedDataA1 : [Measurement]{
        theModel.recordedDataA1
    }

    var recordedDataA2 : [Measurement]{
        theModel.recordedDataA2
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
        IPHConnect.delegate = self
    }
    
    func bluetoothButtonClicked() {
        theModel.setMode(SensorMode.BLUETOOTH)
        BLEConnect.start()
        devices = []
    }
    
    func internalButtonClicked() {
        theModel.setMode(SensorMode.INTERNAL)
        timer10Internal()
        //TODO: true for both, false for accelerometer maybe change to enum?
        IPHConnect.start(false)
    }
    
    func periferalChoosen(_ pheriferal : CBPeripheral){
        BLEConnect.choosePeriferal(pheriferal)
        theModel.setChosenDevice(pheriferal)
        //timer10BLuetooth()
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
    
    func returnAccelerometerDataInternal(_ x: Double,_ y: Double,_ z:Double) {
        let filteredData: FilteredData = theModel.filterDataA1(xSample: Int16(x*1024), ySample: Int16(y*1024), zSample: Int16(z*1024))
        let elevationAngleDegrees = theModel.calculateAngle(filteredData)
        print("Elevation angles degrees: \(elevationAngleDegrees)")
        theModel.addMeassurementA1(angle: elevationAngleDegrees, timestamp: Date.now)
    }
    //domhär funktionerna går säkert att slå ihop till en. alltså retrivesensordata och returnaccelerometerdatainternal
    func retriveSensorAccData(xSample: Double, ySample: Double, zSample: Double){
        let rawAngle = theModel.calculateAngleNew(xSample, ySample, zSample)
        print("AccRawAngle: \(rawAngle)")
        theModel.addRawAngleAcc(rawAngle)
        theModel.filterDataA1New()
    }
    
    func retriveSensorGyroData(xSample: Double, ySample: Double, zSample: Double) {
        let rawAngle = theModel.calculateAngleNew(xSample, ySample, zSample)
        print("GyroRawAngle: \(rawAngle)")
        theModel.addRawAngleGyro(rawAngle)
        
    }
    
    func filterBoth() {
        let filteredAngle = theModel.filterDataA2New()
        theModel.addMeassurementA2(angle: filteredAngle, timestamp: Date.now)
    }
    
    
    
    func returnBothDataInternal(_ xGyro: Double,_ yGyro: Double,_ zGyro:Double, _ xAcc: Double,_ yAcc: Double,_ zAcc:Double) {
        //TODO: implement the second algorithm for both types of data
        let filteredData: FilteredData = theModel.filterDataA2(xGyro, yGyro, zGyro, xAcc, yAcc, zAcc)
        let elevationAngleDegrees = theModel.calculateAngle(filteredData)
        print("Elevation angles degrees: \(elevationAngleDegrees)")
        theModel.addMeassurementA1(angle: elevationAngleDegrees, timestamp: Date.now)
    }
    
    func returnBothDataBluetooth(_ xGyro: Double,_ yGyro: Double,_ zGyro:Double, _ xAcc: Double,_ yAcc: Double,_ zAcc:Double) {
        //TODO: implement the second algorithm for both types of data
        let filteredData: FilteredData = theModel.filterDataA2(xGyro, yGyro, zGyro, xAcc, yAcc, zAcc)
        let elevationAngleDegrees = theModel.calculateAngle(filteredData)
        print("Elevation angles degrees: \(elevationAngleDegrees)")
        theModel.addMeassurementA2(angle: elevationAngleDegrees, timestamp: Date.now)
    }
    
    
}
