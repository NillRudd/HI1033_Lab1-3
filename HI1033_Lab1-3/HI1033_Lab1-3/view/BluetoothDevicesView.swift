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
            
            HStack{
                Button {
                    theViewModel.startData()
                    print("Data start")
                }label: {
                    HStack {
                        Text("Start")
                        }
                }
                
                Button {
                    theViewModel.stopData()
                    print("Data stopped")
                }label: {
                    HStack {
                        Text("Stop")
                        }
                }
                
                
                
                
                }
            
            
                
                
            }

            
            
            HStack{
                Text(String(format: "%.2f", theViewModel.recordedDataA1.last?.angle ?? 0.0))
                    .font(.title)
                Spacer()
                Text(String(format: "%.2f", theViewModel.recordedDataA2.last?.angle ?? 0.0))
                    .font(.title)
                
            }
            Spacer()
        }
    }


struct BluetoothDevicesView_Previews: PreviewProvider {
    static var previews: some View {
        BluetoothDevicesView().environmentObject(SensorViewModel())
    }
}
