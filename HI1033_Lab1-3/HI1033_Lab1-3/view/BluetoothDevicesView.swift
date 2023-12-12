//
//  BluetoothDevices.swift
//  HI1033_Lab1-3
//
//  Created by Esteban Masaya on 2023-12-11.
//

import SwiftUI


struct BluetoothDevicesView: View {
    @EnvironmentObject var theViewModel : SensorViewModel

    var body: some View {
        VStack{
            List {
                ForEach(theViewModel.devices, id: \.self) { device in
                    Text(device.name ?? "")
                }
            }
            
        }
    }
}

#Preview {
    BluetoothDevicesView().environmentObject(SensorViewModel())
}
