//
//  SensorViewModel.swift
//  HI1033_Lab1-3
//
//  Created by Niklas Roslund on 2023-12-11.
//

import Foundation

class SensorViewModel: ObservableObject {
    private let BLEConnect = BluetoothConnect()
    
    func ButtonClicked() {
        BLEConnect.start()
    }
    
}
