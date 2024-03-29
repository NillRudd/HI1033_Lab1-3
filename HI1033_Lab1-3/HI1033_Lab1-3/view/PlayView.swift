//
//  PlayView.swift
//  HI1033_Lab1-3
//
//  Created by Esteban Masaya on 2023-12-15.
//

import SwiftUI

struct PlayView: View {
    @EnvironmentObject var theViewModel : SensorViewModel

    var body: some View {
        Button{
            if theViewModel.mode == SensorMode.INTERNAL{
                theViewModel.internalButtonClicked()
            }
            else if theViewModel.mode == SensorMode.BLUETOOTH{
                theViewModel.startData()
            }
        }label:{
            ZStack{
                    Image(systemName:"play.fill")
            }
        }
        .foregroundColor(Color.white)
        .padding(15)
        .imageScale(.large)
        .background(Color(red: 66/255, green: 139/255, blue: 221/255))
        .cornerRadius(200)

    }
}

struct PlayView_Previews: PreviewProvider {
    static var previews: some View {
        PlayView()
            .environmentObject(SensorViewModel())
    }
}
