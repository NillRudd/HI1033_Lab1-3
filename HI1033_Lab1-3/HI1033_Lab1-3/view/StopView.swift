//
//  StopView.swift
//  HI1033_Lab1-3
//
//  Created by Esteban Masaya on 2023-12-15.
//

import SwiftUI

struct StopView: View {
    @EnvironmentObject var theViewModel : SensorViewModel

    var body: some View {
        Button{
            if theViewModel.mode == SensorMode.INTERNAL{
                theViewModel.stopInternalSensor()
            }
            else if theViewModel.mode == SensorMode.BLUETOOTH{
                theViewModel.stopData()
                theViewModel.stopData()
            }
        }label:{
            ZStack{
                    Image(systemName:"stop.fill")
            }
        }
        .foregroundColor(Color.white)
        .padding(15)
        .imageScale(.large)
        .background(Color(red: 66/255, green: 139/255, blue: 221/255))
        .cornerRadius(200)
    }
}

struct StopView_Previews: PreviewProvider {
    static var previews: some View {
        PlayView()
            .environmentObject(SensorViewModel())
    }
}

