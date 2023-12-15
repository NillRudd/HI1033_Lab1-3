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
                if theViewModel.mode == SensorMode.INTERNAL{
                    Text("Internal Mode")
                }
                else if theViewModel.mode == SensorMode.BLUETOOTH{
                    Text("Bluetooth Mode")
                }
                
                GraphView(dataA1: theViewModel.recordedDataA1, dataA2: theViewModel.recordedDataA2)
                
                HStack{
                    Spacer()
                    Text(String(format: "%.2f", theViewModel.recordedDataA1.last?.angle ?? 0.0)).font(Font.system(size: 50))
                    Spacer()
                    Text(String(format: "%.2f", theViewModel.recordedDataA2.last?.angle ?? 0.0)).font(Font.system(size: 50))
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
