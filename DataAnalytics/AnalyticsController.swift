//
//  AnalyticsController.swift
//  AnalyticsApp
//
//  Created by Evgeny Mitko on 13/06/2022.
//

import Foundation
import UIKit

internal class AnalyticsController {
    
    
    internal static let shared: AnalyticsController = AnalyticsController()
    
    private var analyticsEventsService: AnalyticsEventsService = AnalyticsEventsService()
    private var networkService: NetworkService = NetworkService()
    private let appBundleId: String
    private let systemVersion: String
    private var currentAppState: String = "unknown"
    
    private var cachedEvents: [AppEvent] = []
    
    private var autoStateTrackEnabled: Bool = false

    private var uploadTimer: Timer?
    
    private init() {
        self.appBundleId = Bundle.main.bundleIdentifier ?? ""
        self.systemVersion = UIDevice.current.systemVersion
        self.configureAppStateTracking()
    }
    
    private func startTimer() {
        guard uploadTimer == nil else { return }
        uploadTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(uploadAnalyticsIfNeeded), userInfo: nil, repeats: true)
    }
    
    
    @objc private func uploadAnalyticsIfNeeded()  {
            Task {
                let events = await self.analyticsEventsService.getLatestEvents()
                if events.isEmpty {
                    print("No Current Events to send!")
                } else {
                    print("Sending Analytics Events!")
                    sendAnalytics(events: events)
                }
            }
    }
    
    private func sendAnalytics(events: [AppEvent]) {
        checkAppState()
        Task {
            do {
                let batchUpdate = AnalyticsBatchUpdate(requestDate: Date().timeIntervalSince1970,
                                                       bundleID: self.appBundleId,
                                                       appState: self.currentAppState,
                                                       systemVersion: self.systemVersion,
                                                       events: events)
                let data = try JSONEncoder().encode(batchUpdate)
                try await networkService.sendRequest(data)
            } catch (let error) {
                    print("Error: \(error.localizedDescription)")
                    print("Gonna cache those events and try again later")
                    await analyticsEventsService.cacheEvents(events)
            }
        }
    }
    
    private func checkAppState() {
        DispatchQueue.main.async {
            switch UIApplication.shared.applicationState {
            case .active:
                self.currentAppState = "active"
            case .inactive:
                self.currentAppState = "inactive"
            case .background:
                self.currentAppState = "background"
            @unknown default:
                self.currentAppState = "unknown"
            }
        }
    }
        
    //MARK: Functions for tracking state changes
    private func configureAppStateTracking() {
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc private func appDidEnterBackground() {
        if autoStateTrackEnabled {
            Analytics.track(.stateTransition, eventName: "Transition to background")
        }
    }
    
    @objc private func appDidEnterForeground() {
        if autoStateTrackEnabled {
            Analytics.track(.stateTransition, eventName: "Transition to foreground")
        }
    }
    
    //MARK: Internal functions
    ///Function to control automatic app state tracking
    internal func setAutoStateTrack(on: Bool) {
        autoStateTrackEnabled = on
    }
    
    ///Function to add new trackable event
    internal func addNewAppEvent(appEvent: AppEvent) {
        Task {
            await analyticsEventsService.addEvent(appEvent)
        }
        startTimer()
    }
    
    ///Function too get a list of all trackable events that await sending to the server
    internal func getListOfAllEvents() async -> [AppEvent] {
        return await analyticsEventsService.getListOfAllEvents()
    }
    
    
}
