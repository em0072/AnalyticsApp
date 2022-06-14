//
//  ContentView.swift
//  AnalyticsApp
//
//  Created by Evgeny Mitko on 13/06/2022.
//

import SwiftUI

struct ContentView: View {
    
    
    
    var body: some View {
        VStack(spacing: 40) {
            Button("Track Screen View") {
                Analytics.track(.viewOpen, eventName: String(describing: type(of: self)))
            }
            Button("Track Button Click") {
                Analytics.track(.buttonClick, eventName: "Log In Button")
            }
            Button("Track Custom Event") {
                Analytics.track(.custom("DB Process"), eventName: "🤦🏼‍♂️ DB erased itself")
            }
            
            Button("print current list of events") {
                Analytics.getAllEvents { eventsList in
                    print(eventsList)
                }
            }
        }
        .onAppear {
            Analytics.startTrackingLifeCycleEvent()
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
