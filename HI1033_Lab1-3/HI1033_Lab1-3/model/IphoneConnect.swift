//
//  IphoneConnect.swift
//  HI1033_Lab1-3
//
//  Created by Niklas Roslund on 2023-12-12.
//

import Foundation
import CoreMotion

class IphoneConnect {
    
    let manager = CMMotionManager()
    
    func start() {
        guard manager.isAccelerometerAvailable else {
            print("Accelerometer is not available.")
            return
        }

        manager.startAccelerometerUpdates()
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.captureAccelerometerData()
        }
    }
    
    func captureAccelerometerData() {
        if let data = self.manager.accelerometerData {
            let x = data.acceleration.x
            let y = data.acceleration.y
            let z = data.acceleration.z

            print("Accelerometer Data: x=\(x), y=\(y), z=\(z)")
        }
    }

    
    func stop() {
        manager.stopAccelerometerUpdates()
    }
}
