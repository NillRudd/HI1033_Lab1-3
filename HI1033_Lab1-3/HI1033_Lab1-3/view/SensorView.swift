//
//  SensorView.swift
//  HI1033_Lab1-3
//
//  Created by Niklas Roslund on 2023-12-11.
//

import SwiftUI

struct SensorView: View {
    @EnvironmentObject var theViewModel : SensorViewModel
    var body: some View {
        NavigationStack{
            
            HStack {
                NavigationLink(destination: BluetoothDevicesView()
                    .onAppear{
                        
                        theViewModel.bluetoothButtonClicked()
                    }){

                            Text("Bluetooth")
                }
                
                NavigationLink(destination: InternalSensorView()
                    .onAppear{
                        theViewModel.internalButtonClicked()
                    }){
                            Text("Internal")
                }
            }
        }
    }
}

struct SensorView_Previews: PreviewProvider {
    static var previews: some View {
        SensorView().environmentObject(SensorViewModel())
    }
}
