//
//  IphoneConnect.swift
//  HI1033_Lab1-3
//
//  Created by Niklas Roslund on 2023-12-12.
//

import Foundation
import CoreMotion


protocol InternalConnectDelegate: AnyObject {
    //func returnAccelerometerDataInternal(_ x: Double,_ y: Double,_ z:Double)
    func returnBothDataInternal(_ xGyro: Double,_ yGyro: Double,_ zGyro:Double, _ xAcc: Double,_ yAcc: Double,_ zAcc:Double, _ timestamp: Double)
}

class InternalConnect {
    
    weak var delegate: InternalConnectDelegate?
    let manager = CMMotionManager()
    var accelerometerTimer: Timer?
    var timer: Timer?
    
    init(){
        
    }
    
    func start() {
        guard manager.isAccelerometerAvailable else {
            print("Accelerometer is not available.")
            return
        }
        
        manager.startAccelerometerUpdates()
        manager.startGyroUpdates()
        //satte intervallet till 0.1 men går att ändra
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            //self?.captureAccelerometerData()
            self?.captureBothData()
        }
    }
    /*
    func captureAccelerometerData() {
        if let data = self.manager.accelerometerData {
            let x = data.acceleration.x
            let y = data.acceleration.y
            let z = data.acceleration.z
            let timestamp = data.timestamp
            delegate?.returnAccelerometerDataInternal(x, y, z, timestamp)
            //print("Accelerometer Data: x=\(x), y=\(y), z=\(z)")
        }
    }
    */
    //captures gyro and accelerometer data
    func captureBothData() {
        if let gyroData = self.manager.gyroData, let accelerometerData = self.manager.accelerometerData {
            let xGyro = gyroData.rotationRate.x
            let yGyro = gyroData.rotationRate.y
            let zGyro = gyroData.rotationRate.z
            
            let xAcc = accelerometerData.acceleration.x
            let yAcc = accelerometerData.acceleration.y
            let zAcc = accelerometerData.acceleration.z
            let timestamp = accelerometerData.timestamp
            //print("Gyro Data: x=\(xGyro), y=\(yGyro), z=\(zGyro)")
            delegate?.returnBothDataInternal(xGyro, yGyro, zGyro, xAcc, yAcc, zAcc, timestamp)
        }
    }

    func stop() {
        manager.stopAccelerometerUpdates()
        manager.stopGyroUpdates()
        timer?.invalidate()
    }
}
