//
//  Date+Extensions.swift
//  Firebase-Demo
//
//  Created by Brendon Crowe on 4/18/23.
//  Copyright © 2023 Brendon Crowe. All rights reserved.
//

import Foundation

extension Date {
    public func dateString(_ format: String = "EEEE, MMM d, h:mm a") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        // self represents the Date object itself
        return dateFormatter.string(from: self)
    }
}
