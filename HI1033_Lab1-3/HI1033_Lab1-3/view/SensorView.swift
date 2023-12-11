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
        VStack {
            Button {
                theViewModel.ButtonClicked()
                print("Submit")
                
            }label: {
                Text("Submit")
                    .padding(7)
            }
            List {
                ForEach(theViewModel.devices, id: \.self) { device in
                    Text(device.name ?? "")
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
