//
//  GraphView.swift
//  HI1033_Lab1-3
//
//  Created by Niklas Roslund on 2023-12-14.
//

import SwiftUI

struct GraphView: View {
    @EnvironmentObject var theViewModel : SensorViewModel
    var dataA1: [Measurement]
    var dataA2: [Measurement]

    private func path(for measurements: [Measurement], in rect: CGRect) -> Path {
        var path = Path()

        guard let firstMeasurement = measurements.first,
              let lastMeasurement = measurements.last,
              let maxAngle = measurements.max(by: { $0.angle < $1.angle })?.angle,
              lastMeasurement.timestamp - firstMeasurement.timestamp != 0,
              maxAngle != 0 else {
            return path
        }

        let xScale = rect.width / (lastMeasurement.timestamp - firstMeasurement.timestamp)
        let yScale = rect.height / maxAngle

        let startPoint = CGPoint(
            x: 0,  // Start from the left edge
            y: rect.height - (firstMeasurement.angle * yScale)
        )
        path.move(to: startPoint)

        for measurement in measurements {
            let point = CGPoint(
                x: (measurement.timestamp - firstMeasurement.timestamp) * xScale,
                y: rect.height - (measurement.angle * yScale)
            )
            path.addLine(to: point)
        }

        return path
    }

    var body: some View {
        ZStack{
            VStack{
                GeometryReader { geometry in
                    ZStack {
                        path(for: dataA1, in: geometry.frame(in: .local))
                            .stroke(Color.blue, lineWidth: 2)
                        path(for: dataA2, in: geometry.frame(in: .local))
                            .stroke(Color.green, lineWidth: 2)
                    }
                }
                
            }.background(Color.white)
            
            VStack{
                Spacer()
                HStack{
                    Spacer()
                    VStack{
                        HStack{
                            Image(systemName:"circle.circle.fill").foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                            Text("Algorithm 1")
                        }
                        
                        HStack{
                            Image(systemName:"circle.circle.fill").foregroundColor(.green)
                            Text("Algorithm 2")
                        }
                        
                    }
                }
            }
        }
                
    }
}
/*
struct GraphView_Previews: PreviewProvider {
    static var previews: some View {
        GraphView()
    }
}
*/
