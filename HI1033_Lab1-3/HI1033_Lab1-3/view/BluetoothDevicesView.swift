//
//  BluetoothDevicesView.swift
//  HI1033_Lab1-3
//
//  Created by Esteban Masaya on 2023-12-12.
//

import SwiftUI

struct BluetoothDevicesView: View {
    @EnvironmentObject var theViewModel : SensorViewModel

    var body: some View {
        VStack{
            List {
                if theViewModel.devices.count == 0{
                    Text("No devices found nearby.")
                }
                ForEach(theViewModel.devices, id: \.self) { device in
                    Button {
                        theViewModel.periferalChoosen(device)
                        print("Device chosen: \(String(describing: device.name))")
                    }label: {
                        HStack {
                            Text(device.name ?? "")
                            Spacer()
                            if device.identifier == theViewModel.chosenBluetoothDevice?.identifier {
                                Text("Connected")
                            }
                        }
                    }
                }
            }
        }
    }
}

struct BluetoothDevicesView_Previews: PreviewProvider {
    static var previews: some View {
        BluetoothDevicesView().environmentObject(SensorViewModel())
    }
}
