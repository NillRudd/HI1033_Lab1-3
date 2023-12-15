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
                Text("blue == algorithm 1")
                Text("green == algorithm 2")
                
                
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
