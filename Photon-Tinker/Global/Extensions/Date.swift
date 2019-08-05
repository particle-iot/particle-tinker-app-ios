//
// Created by Raimundas Sakalauskas on 2019-08-02.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

extension Date {

    func eventTimeFormattedString() -> String {

        // convert weird UTC stamp to human readable local time
        let utcDateStr = self.description.replacingOccurrences(of: "+0000", with: "")

        // create dateFormatter with UTC time format
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        let date = dateFormatter.date(from: utcDateStr)!

        return "\(DateFormatter.localizedString(from: date, dateStyle: .none, timeStyle: .medium)), \(DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none))"
    }

    func tinkerFormattedString() -> String {

        // convert weird UTC stamp to human readable local time
        let utcDateStr = self.description.replacingOccurrences(of: "+0000", with: "")

        // create dateFormatter with UTC time format
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        let date = dateFormatter.date(from: utcDateStr)!

        return "\(DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)), \(DateFormatter.localizedString(from: date, dateStyle: .none, timeStyle: .short))"
    }

}