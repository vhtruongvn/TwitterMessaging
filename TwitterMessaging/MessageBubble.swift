//
//  MessageBubble.swift
//  TwitterMessaging
//
//  Created by Truong Vo on 1/21/17.
//  Copyright © 2017 Truong Vo. All rights reserved.
//

import UIKit

class MessageBubble: UIView {

    var imageViewBG: UIImageView?
    var text: String?
    var labelChatText: UILabel?
    
    init(data: Message, startY: CGFloat) {
        super.init(frame: MessageBubble.calculateFrame(data.type, startY: startY))
        
        self.backgroundColor = UIColor.clear
        let padding: CGFloat = 10.0
        
        // add Text if any
        if data.text != nil {
            // frame calculation
            let startX = padding
            let startY: CGFloat = 5.0
            labelChatText = UILabel(frame: CGRect(x: startX, y: startY, width: self.frame.width - 2 * startX , height: 5))
            labelChatText?.textAlignment = data.type == .mine ? .right : .left
            labelChatText?.font = UIFont.systemFont(ofSize: 14)
            labelChatText?.textColor = UIColor.white
            labelChatText?.numberOfLines = 0
            labelChatText?.text = data.text
            labelChatText?.sizeToFit() // getting fullsize of it
            self.addSubview(labelChatText!)
        }
        
        // calculate new width and height of the message bubble view
        var viewHeight: CGFloat = 0.0
        var viewWidth: CGFloat = 0.0
        viewHeight = labelChatText!.frame.maxY + padding/2
        viewWidth = labelChatText!.frame.width + labelChatText!.frame.minX + padding
        
        // adding new width and height of the message bubble view frame
        self.frame = CGRect(x: self.frame.minX, y: self.frame.minY, width: viewWidth, height: viewHeight)
        
        // adding the resizable image view to give it bubble like shape
        let bubbleImageFileName = data.type == .mine ? "right_bubble" : "left_bubble"
        imageViewBG = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: self.frame.width, height: self.frame.height))
        if data.type == .mine {
            imageViewBG?.image = UIImage(named: bubbleImageFileName)?.resizableImage(withCapInsets: UIEdgeInsetsMake(14, 14, 17, 28))
        } else {
            imageViewBG?.image = UIImage(named: bubbleImageFileName)?.resizableImage(withCapInsets: UIEdgeInsetsMake(14, 22, 17, 20))
        }
        self.addSubview(imageViewBG!)
        self.sendSubview(toBack: imageViewBG!)
        
        // frame recalculation for filling up the bubble with background bubble image
        let repsotionXFactor:CGFloat = data.type == .mine ? 0.0 : -8.0
        let bgImageNewX = imageViewBG!.frame.minX + repsotionXFactor
        let bgImageNewWidth = imageViewBG!.frame.width + CGFloat(12.0)
        let bgImageNewHeight = imageViewBG!.frame.height + CGFloat(6.0)
        imageViewBG?.frame = CGRect(x: bgImageNewX, y: 0.0, width: bgImageNewWidth, height: bgImageNewHeight)
        
        // keepping a minimum distance from the edge of the screen
        var newStartX:CGFloat = 0.0
        if data.type == .mine {
            // need to maintain the minimum right side padding from the right edge of the screen
            let extraWidthToConsider = imageViewBG!.frame.width
            newStartX = ScreenSize.SCREEN_WIDTH - extraWidthToConsider
        } else {
            // need to maintain the minimum left side padding from the left edge of the screen
            newStartX = -imageViewBG!.frame.minX + 3.0
        }
        
        self.frame = CGRect(x: newStartX, y: self.frame.minY, width: frame.width, height: frame.height)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func calculateFrame(_ type: MessageType, startY: CGFloat) -> CGRect {
        let paddingFactor: CGFloat = 0.02
        let sidePadding = ScreenSize.SCREEN_WIDTH * paddingFactor
        let maxWidth = ScreenSize.SCREEN_WIDTH * 0.65 // set message bubble's max width = 65% of the screen width
        let startX: CGFloat = type == .mine ? ScreenSize.SCREEN_WIDTH * (CGFloat(1.0) - paddingFactor) - maxWidth : sidePadding
        return CGRect(x: startX, y: startY, width: maxWidth, height: 5) // 5 is the primary height before drawing starts
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
