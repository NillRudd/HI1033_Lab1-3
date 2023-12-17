//
//  MenuView.swift
//  HI1033_Lab1-3
//
//  Created by Esteban Masaya on 2023-12-15.
//

import SwiftUI

struct MenuView: View {
    @EnvironmentObject var theViewModel : SensorViewModel
    var body: some View {
        
        /*
         let nValues : [Int32] = Array(1...10)
         let tickTimeValues : [Int] = Array(1...5)
         let sizeValues : [Int32] = [4, 9, 16, 32, 64, 81, 100]
         let numOfLettersValues: [Int32] = Array(4...100)
         */
        NavigationStack{
            
            ZStack {
                Color(red: 134/255, green: 185/255, blue: 237/255) .edgesIgnoringSafeArea(.all)
                
                VStack{
                    Spacer()
                    
                    VStack(spacing: 1) {
                        Text("Engineerd by Niklas Roslund & Esteban Masaya")
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .foregroundColor(.white)
                            .padding(.trailing)
                        Rectangle().fill(.yellow).frame(height: 6).cornerRadius(2)
                            .padding(.horizontal)
                        
                    }.shadow(color: .blue, radius: 1, x: 0.5, y: 0.5)
                    
                    Spacer()
                    
                    Text("Motion Sensor")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                        .shadow(color: .blue, radius: 2, x: 1, y: 1)
                    Text("〽️").font(.system(size: 70))
                    Spacer()
                    VStack{
                        NavigationLink(destination: DataPresentationView().onAppear{
                            theViewModel.setMode(mode: SensorMode.INTERNAL)
                                theViewModel.clearData()
                        }
                        ){
                            Text("Internal Sensor").font(.title)
                        }
                        .foregroundColor(Color(red: 66/255, green: 139/255, blue: 221/255))
                        .padding(5)
                        .background(.white)
                        .cornerRadius(8)
                        
                        NavigationLink(destination: DataPresentationView().onAppear{
                            theViewModel.setMode(mode: SensorMode.BLUETOOTH)
                            theViewModel.clearData()
                        }
                        ){
                            Text("Bluetooth").font(.title)
                        }
                        .foregroundColor(Color(red: 66/255, green: 139/255, blue: 221/255))
                        .padding(5)
                        .background(.white)
                        .cornerRadius(8)
                    }
                    .padding()
                    
                    
                }
                
            }
        }
    }
}



struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView().environmentObject(SensorViewModel())
    }
}
