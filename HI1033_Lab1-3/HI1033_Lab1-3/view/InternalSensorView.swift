//
//  InternalSensorView.swift
//  HI1033_Lab1-3
//
//  Created by Esteban Masaya on 2023-12-12.
//

import SwiftUI
import Charts

struct InternalSensorView: View {
    @EnvironmentObject var theViewModel : SensorViewModel
    
    var body: some View {
        GraphView(dataA1: theViewModel.recordedDataA1, dataA2: theViewModel.recordedDataA2)
        Text("blue == algorithm 1")
        Text("green == algorithm 2")
    }
}

struct InternalSensorView_Previews: PreviewProvider {
    static var previews: some View {
        InternalSensorView().environmentObject(SensorViewModel())
    }
}
