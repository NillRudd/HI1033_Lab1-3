//
//  DataPresentationView.swift
//  HI1033_Lab1-3
//
//  Created by Esteban Masaya on 2023-12-15.
//

import SwiftUI

struct DataPresentationView: View {
    @EnvironmentObject var theViewModel : SensorViewModel

    var body: some View {

        
        ZStack {
            Color(red: 134/255, green: 185/255, blue: 237/255) .edgesIgnoringSafeArea(.all)
            
            VStack{
                
                HStack{
                    VStack{
                        if theViewModel.mode == SensorMode.INTERNAL{
                                Text("Internal Mode")
                            }
                            else if theViewModel.mode == SensorMode.BLUETOOTH{
                                Text("Bluetooth Mode")
                            }
                    }
                    Text("〽️")
                }.font(.title)
                    .foregroundColor(.white)
                    .shadow(color: .blue, radius: 2, x: 1, y: 1)
                
                
                GraphView(dataA1: theViewModel.recordedDataA1, dataA2: theViewModel.recordedDataA2)
                VStack{
                    if theViewModel.mode == SensorMode.BLUETOOTH{
                        NavigationLink(destination: BluetoothDevicesView()
                            .onAppear{
                                
                                theViewModel.bluetoothButtonClicked()
                            }){
                                
                                Text("\(theViewModel.chosenBluetoothDevice?.name ?? "Choose your device")").font(.title3)
                                    .foregroundColor(.white)
                                    .padding(5)
                                    .background(Color(red: 66/255, green: 139/255, blue: 221/255))
                                    .cornerRadius(8)
                                
                            }
                    }
                }
                
                
                HStack{
                    Spacer()
                    VStack{
                        Text("Filter 1")
                        Text(String(format: "%.2f", theViewModel.recordedDataA1.last?.angle ?? 0.0)).font(Font.system(size: 45))
                    }
                    
                    Spacer()
                    VStack{
                        Text("Filter 2")
                        Text(String(format: "%.2f", theViewModel.recordedDataA2.last?.angle ?? 0.0)).font(Font.system(size: 45))
                    }
                    
                    
                    
                    Spacer()
                }
                    .padding()
                
                
                
                HStack {
                    PlayView()
                    StopView()
                }
                
                
                
            }
        }
        
    }
}


struct DataPresentationView_Previews: PreviewProvider {
    static var previews: some View {
        DataPresentationView()
            .environmentObject(SensorViewModel())
    }
}
