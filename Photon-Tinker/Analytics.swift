//
//  Analytics.swift
//  Particle
//
//  No-op analytics shim.
//
//  The app previously used Segment (SEGAnalytics) forwarding to Firebase, plus
//  Fabric/Crashlytics. Those SDKs were removed during the 2026 modernisation
//  (Fabric is discontinued; the old Segment/Firebase pods no longer build).
//
//  This shim keeps the existing `SEGAnalytics.shared().track(...)` / `identify(...)`
//  call sites compiling and behaving as harmless no-ops, so analytics can be
//  re-introduced later (e.g. Segment Analytics-Swift + Firebase Crashlytics)
//  by replacing this single file, without touching the call sites.
//

import Foundation

class SEGAnalytics {

    private static let instance = SEGAnalytics()

    static func shared() -> SEGAnalytics {
        return instance
    }

    func track(_ event: String, properties: [String: Any]? = nil) {
        // no-op
    }

    func identify(_ userId: String) {
        // no-op
    }
}
