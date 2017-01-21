//
//  Message.swift
//  TwitterMessaging
//
//  Created by Truong Vo on 1/21/17.
//  Copyright © 2017 Truong Vo. All rights reserved.
//

import Foundation
import UIKit

enum MessageType: Int {
    case mine = 0
    case opponent
}

class Message {
    
    var text: String?
    var date: Date?
    var type: MessageType
    
    init(text: String?, date: Date? , type: MessageType = .mine) {
        self.text = text
        self.date = date
        self.type = type
    }
}
