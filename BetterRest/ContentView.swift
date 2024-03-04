//
//  ContentView.swift
//  BetterRest
//
//  Created by Igor Florentino on 01/03/24.
//

import CoreML
import SwiftUI

struct ContentView: View {
    
    @State private var wakeUp = Self.deafultWakeUp
    @State private var sleepAmount = 8.0
    @State private var coffeAmount = 0
    
    private static var deafultWakeUp: Date{
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    var sleeptime: String {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            let components = Calendar.current.dateComponents(([.hour,.minute]), from: wakeUp)
            let hourInSeconds = (components.hour ?? 0) * 60 * 60
            let minuteInSeconds = (components.minute ?? 0) * 60
            let prediction = try model.prediction(wake: Int64(hourInSeconds + minuteInSeconds), estimatedSleep: sleepAmount, coffee: Int64(coffeAmount))
            let sleepTime = wakeUp-prediction.actualSleep
            return "Your ideal sleep time is\n" + sleepTime.formatted(date: .omitted, time: .shortened)
            
        } catch {
            return "Something went wrong"
        }
    }
    
    var body: some View {
        NavigationStack{
            VStack{
                Form() {
                    Section("When do you want to wake"){
                        DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }.foregroundStyle(.primary)
                    Section("Desired amount of sleep"){
                        Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                    }.foregroundStyle(.primary)
                    Section("Daily coffee intake"){
                        Picker(coffeAmount == 1 ? "cup" : "cups", selection: $coffeAmount) {
                            ForEach(0..<21) {
                                Text(String($0))
                            }
                        }
                    }.foregroundStyle(.primary)
                    
                    Text(sleeptime)
                        .font(.title)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                }
            }.navigationTitle("BetterRest")
        }
    }
}
#Preview {
    ContentView()
}
