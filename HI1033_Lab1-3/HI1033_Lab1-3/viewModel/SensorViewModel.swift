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
    private var timestampBluetooth : Double{
        theModel.timestampBluetooth
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
        theModel.clearData()
        theModel.setMode(SensorMode.BLUETOOTH)
        devices = []
        BLEConnect.start()
        
    }
    
    func setMode(mode: SensorMode){
        theModel.setMode(mode)
    }
    
    func stopInternalSensor(){
        IPHConnect.stop()
    }
    
    func internalButtonClicked() {
        timer10Internal()
        //TODO: true for both, false for accelerometer maybe change to enum?
        IPHConnect.start()
    }
    
    func periferalChoosen(_ pheriferal : CBPeripheral){
        BLEConnect.choosePeriferal(pheriferal)
        theModel.setChosenDevice(pheriferal)
    }
    
    func timer10BLuetooth(){
        timer = Timer.scheduledTimer(withTimeInterval: 15, repeats: false) { [weak self] _ in
            self?.cancelTimerBlueTooth()
        }
    }
    
    func timer10Internal(){
        timer = Timer.scheduledTimer(withTimeInterval: 15, repeats: false) { [weak self] _ in
            self?.cancelTimerInternal()
        }
    }
    
    func cancelTimerBlueTooth() {
        self.timer?.invalidate()
        self.BLEConnect.stopData()
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
    func retriveSensorAccData(xSample: Double, ySample: Double, zSample: Double){
        let rawAngle = theModel.calculateAngle(FilteredData(x: xSample, y: ySample, z: zSample))
        //print("AccRawAngle: \(rawAngle)")
        theModel.addRawAngleAcc(rawAngle)

        theModel.addMeasurementA1(theModel.filterDataA1New(), timestampBluetooth)
    }
    
    func retriveSensorGyroData(xSample: Double, ySample: Double, zSample: Double) {
            DispatchQueue.main.async {
                if self.theModel.rawAngleGyroArray.count == 0{
                    print("First")

                    self.theModel.addRawAngleGyro(0)
                }
                else{
                    self.theModel.addRawAngleGyro(self.theModel.rawAngleGyroArray.last! + ySample/52)
                }
            }

        }
    
    func filterBoth() {
        let filteredAngle = theModel.filterDataA2New()
        print("test \(filteredAngle)")
        
        if theModel.recordedDataA2.count == 0{
            theModel.setTimestampBluetooth(0.0)
        }
        else{
            theModel.setTimestampBluetooth(timestampBluetooth + 1/52)
        }
        if(theModel.recordedDataA2.count < theModel.recordedDataA1.count){
            theModel.addMeasurementA2(filteredAngle, timestampBluetooth)
        }
        
    }
    
    
    
    func returnBothDataInternal(_ xGyro: Double,_ yGyro: Double,_ zGyro:Double, _ xAcc: Double,_ yAcc: Double,_ zAcc:Double, _ timestamp: Double) {
        let rawDataA1 = FilteredData(x: xAcc, y: yAcc, z: zAcc)
        let rawDataA2 = FilteredData(x: xGyro, y: yGyro, z: zGyro)
        let elevationAngleDegreesAcc = theModel.calculateAngle(rawDataA1)
        let elevationAngleDegreesGyro = theModel.calculateAngle(rawDataA2)
        
        let filteredDataA1 = theModel.filterAcceleration(currentInput: elevationAngleDegreesAcc)
        let filteredDataA2 = theModel.filterGyroAndAcceleration(elevationAngleDegreesAcc, elevationAngleDegreesGyro)
        
        theModel.addMeasurementA1(filteredDataA1, timestamp)
        theModel.addMeasurementA2(filteredDataA2, timestamp)
        
    }
    
    func clearData(){
        theModel.clearData()
    }
    
    
    func stopData(){
        BLEConnect.stopData()
    }

    func startData(){
        DispatchQueue.main.async {
            self.theModel.clearData()
            self.BLEConnect.startData(timer: self.timer10BLuetooth)
        }
    }
    
}
