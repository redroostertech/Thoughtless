//
//  CurrentDateAndTimeHelper.swift
//  Thoughtless
//
//  Created by Yohannes Wijaya on 10/26/16.
//  Copyright © 2016 Yohannes Wijaya. All rights reserved.
//

import Foundation

protocol CurrentDateAndTimeHelper {
    func getCurrentDateAndTime() -> String
}

extension CurrentDateAndTimeHelper {
    func getCurrentDateAndTime() -> String {
        return DateFormatter.localizedString(from: Date(), dateStyle: .long, timeStyle: .short)
    }
}