//
//  Analytics.swift
//  AnalyticsApp
//
//  Created by Evgeny Mitko on 13/06/2022.
//

import Foundation
import UIKit
import BackgroundTasks

 

public class Analytics {
    
    /// This function turns  automatic app state transition tracking on.
    ///
    public static func startTrackingLifeCycleEvent() {
        AnalyticsController.shared.setAutoStateTrack(on: true)
    }
    
    /// This function tells Analytics to track application event.
    ///
    /// ```
    ///Analytics.track(.buttonClick, eventName: "Log In Button") // Will Track 'Button Click' event with a "Log In Button" name
    ///Analytics.track(.custom("DB Event", eventName: "DB Force Delete") // Will Track custom 'DB Event' event with a "DB Force Delete" name
    /// ```
    ///
    /// - Parameter eventType: The type of the trackable event.
    /// - Parameter eventName: The name of the trackable event.
    public static func track(_ eventType: AppEventType, eventName: String) {
        let appEvent = AppEvent(type: eventType, name: eventName, date: Date().timeIntervalSince1970)
        AnalyticsController.shared.addNewAppEvent(appEvent: appEvent)
    }
    
    /// This function return a list of trackable app events that are currently await to be bundled and send to the server.
    ///
    /// - Returns: An array of objects  of type `AppEvent` representing trackable app event.
    public static func getAllEvents() async -> [AppEvent] {
        return await AnalyticsController.shared.getListOfAllEvents()
    }
    
    
    /// This function gets a list of trackable app events that are currently await to be bundled and send to the server and return it with a callback.
    ///
    /// - Parameter completion: The callback called after retrieval.
    public static func getAllEvents(completion: @escaping ([AppEvent])->()) {
        Task {
            let eventList = await AnalyticsController.shared.getListOfAllEvents()
            completion(eventList)
        }
    }
    
}