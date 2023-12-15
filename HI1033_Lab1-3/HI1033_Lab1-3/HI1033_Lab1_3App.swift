//
//  HI1033_Lab1_3App.swift
//  HI1033_Lab1-3
//
//  Created by Niklas Roslund on 2023-12-11.
//

import SwiftUI

@main
struct HI1033_Lab1_3App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MenuView().environmentObject(SensorViewModel())
            //ContentView()
            //    .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
