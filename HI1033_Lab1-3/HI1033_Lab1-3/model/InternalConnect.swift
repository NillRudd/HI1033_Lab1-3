//
//  IphoneConnect.swift
//  HI1033_Lab1-3
//
//  Created by Niklas Roslund on 2023-12-12.
//

import Foundation
import CoreMotion


protocol InternalConnectDelegate: AnyObject {
    func returnAccelerometerData(_ x: Double,_ y: Double,_ z:Double)
    func returnGyroData(_ x: Double,_ y: Double,_ z:Double)
}

class InternalConnect {
    
    weak var delegate: InternalConnectDelegate?
    let manager = CMMotionManager()
    
    func start(_ mode : Bool) {
        guard manager.isAccelerometerAvailable else {
            print("Accelerometer is not available.")
            return
        }
        if mode {
            manager.startAccelerometerUpdates()
            manager.startGyroUpdates()
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                self?.captureAccelerometerData()
                self?.captureGyroData()
            }
        }else {
            manager.startAccelerometerUpdates()
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                self?.captureAccelerometerData()
            }
        }
    }
    
    func captureAccelerometerData() {
        if let data = self.manager.accelerometerData {
            let x = data.acceleration.x
            let y = data.acceleration.y
            let z = data.acceleration.z
            
            print("Accelerometer Data: x=\(x), y=\(y), z=\(z)")
            delegate?.returnAccelerometerData(x, y, z)
        }
    }
    
    func captureGyroData() {
        if let gyroData = self.manager.gyroData {
            let x = gyroData.rotationRate.x
            let y = gyroData.rotationRate.y
            let z = gyroData.rotationRate.z
            
            print("Gyro Data: x=\(x), y=\(y), z=\(z)")
            delegate?.returnGyroData(x, y, z)
        }
    }

    func stop() {
        manager.stopAccelerometerUpdates()
        manager.stopGyroUpdates()
    }
}
