//
//  SensorDataProcessor.swift
//  HI1033_Lab1-3
//
//  Created by Niklas Roslund on 2023-12-12.
//

import Foundation

struct SensorDataProcessor{
    
    private var theModel : SensorModel
    private var filteredData : FilteredData = FilteredData(x: 0, y: 0, z: 0)
    init(theModel: SensorModel) {
        self.theModel = theModel
    }
    
    mutating func filterData1(xSample: Int16, ySample: Int16, zSample: Int16) -> FilteredData{
        DispatchQueue.main.async {
            print("previous: \(theModel.previousFilteredData)")
            print("DATA: \( filteredData)")
            if theModel.recordedData.count>1{
                print("AQUI!!")
                filteredData.x = filterEach(currentInput: Double(xSample), previousOutput: theModel.previousFilteredData.x)
                filteredData.y = filterEach(currentInput: Double(ySample), previousOutput: theModel.previousFilteredData.y)
                filteredData.z = filterEach(currentInput: Double(zSample), previousOutput: theModel.previousFilteredData.z)
                
                //theModel.alpha*Double(xSample) + (1 - theModel.alpha) * theModel.bluetoothDataArray.last
                
            } else{
                filteredData.x = Double(xSample)
                filteredData.y = Double(ySample)
                filteredData.z = Double(zSample)
            }
            theModel.setPreviousFilteredData(filteredData)
        }
        
        return filteredData
    }
    
    func filterEach(currentInput: Double, previousOutput: Double) -> Double{
        return (theModel.alpha * currentInput) + (1 - theModel.alpha) * previousOutput
    }
    
    func calculateAngle(_ filteredData: FilteredData) -> Double{
        let magnitude = sqrt(filteredData.x * filteredData.x + filteredData.y * filteredData.y + filteredData.z * filteredData.z)
        let cosElevationAngle = filteredData.z / magnitude
        let elevationAngleRadians = acos(cosElevationAngle)
        let elevationAngleDegrees = elevationAngleRadians * (180.0 / .pi)
        return elevationAngleDegrees
        
        
    }
    
    
    
}



