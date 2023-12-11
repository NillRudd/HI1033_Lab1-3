//
//  SensorViewModel.swift
//  HI1033_Lab1-3
//
//  Created by Niklas Roslund on 2023-12-11.
//

import Foundation
import CoreBluetooth

class SensorViewModel: ObservableObject {
    
    @Published private var theModel: SensorModel
    
    var devices : [CBPeripheral] {
        theModel.BLEConnect.getBlueToothDevices()
    }
    
    
    init() {
        theModel = SensorModel()
    }
    
    func ButtonClicked() {
        theModel.buttonPressed()
    }
    
}
