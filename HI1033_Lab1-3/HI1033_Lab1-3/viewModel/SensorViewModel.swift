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
        theModel.clearData()
        recordedDataA1 = []
        recordedDataA2 = []
        theModel.setMode(SensorMode.BLUETOOTH)
        BLEConnect.start()
        devices = []
    }
    
    func setMode(mode: SensorMode){
        theModel.setMode(mode)
    }
    
    func stopInternalSensor(){
        IPHConnect.stop()
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
        let rawData = FilteredData(x: Double(xSample), y: Double(ySample), z: Double(zSample))
        let elevationAngleDegreesAcc = theModel.calculateAngle(rawData)
                
        let filteredData = theModel.filterAcceleration(currentInput: elevationAngleDegreesAcc)
                
        theModel.addMeasurementA1(filteredData, 0.0)
        recordedDataA1.append(Measurement(angle: filteredData, timestamp: 0.0))
    }
    
    func returnBothDataInternal(_ xGyro: Double,_ yGyro: Double,_ zGyro:Double, _ xAcc: Double,_ yAcc: Double,_ zAcc:Double, _ timestamp: Double) {
        let rawDataA1 = FilteredData(x: xAcc, y: yAcc, z: zAcc)
        let rawDataA2 = FilteredData(x: xGyro, y: yGyro, z: zGyro)
        let elevationAngleDegreesAcc = theModel.calculateAngle(rawDataA1)
        let elevationAngleDegreesGyro = theModel.calculateAngle(rawDataA2)
        
        let filteredDataA1 = theModel.filterAcceleration(currentInput: elevationAngleDegreesAcc)
        let filteredDataA2 = theModel.filterGyroAndAcceleration(linearAcceleration: elevationAngleDegreesAcc, gyroscope: elevationAngleDegreesGyro)
        
        theModel.addMeasurementA1(filteredDataA1, timestamp)
        theModel.addMeasurementA2(filteredDataA2, timestamp)
        recordedDataA1.append(Measurement(angle: filteredDataA1, timestamp: timestamp))
        recordedDataA2.append(Measurement(angle: filteredDataA2, timestamp: timestamp))
    }
}
