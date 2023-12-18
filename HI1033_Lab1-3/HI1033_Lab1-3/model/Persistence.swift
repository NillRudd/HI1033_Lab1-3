//
//  Persistence.swift
//  HI1033_Lab1-3
//
//  Created by Niklas Roslund on 2023-12-11.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    let container: NSPersistentContainer

    func saveMeasurements(measurementsA1: [Measurement], measurementsA2: [Measurement]) {
        let context = container.viewContext

        let newMeasurementRecord = MeasurementEntity(context: context)
        let encoder = JSONEncoder()

        if let encodedA1 = try? encoder.encode(measurementsA1),
           let encodedA2 = try? encoder.encode(measurementsA2) {
            newMeasurementRecord.measurementsA1Data = String(data: encodedA1, encoding: .utf8)
            newMeasurementRecord.measurementsA2Data = String(data: encodedA2, encoding: .utf8)
        }

        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    func retrieveMeasurements() -> ([Measurement], [Measurement]) {
        let context = container.viewContext
        let fetchRequest = MeasurementEntity.fetchRequest()

        do {
            let result = try context.fetch(fetchRequest)
            var measurementsA1: [Measurement] = []
            var measurementsA2: [Measurement] = []

            for entity in result {
                if let measurementsA1Data = entity.measurementsA1Data,
                   let measurementsA2Data = entity.measurementsA2Data,
                   let dataA1 = measurementsA1Data.data(using: .utf8),
                   let dataA2 = measurementsA2Data.data(using: .utf8) {
                    let decoder = JSONDecoder()
                    let decodedMeasurementsA1 = try decoder.decode([Measurement].self, from: dataA1)
                    let decodedMeasurementsA2 = try decoder.decode([Measurement].self, from: dataA2)
                    measurementsA1.append(contentsOf: decodedMeasurementsA1)
                    measurementsA2.append(contentsOf: decodedMeasurementsA2)
                }
            }

            return (measurementsA1, measurementsA2)
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "HI1033_Lab1_3")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
