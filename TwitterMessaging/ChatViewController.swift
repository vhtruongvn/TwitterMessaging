//
//  ChatViewController.swift
//  TwitterMessaging
//
//  Created by Truong Vo on 1/20/17.
//  Copyright © 2017 Truong Vo. All rights reserved.
//

import UIKit
import TwitterKit
import AFNetworking

class ChatViewController: UIViewController {

    @IBOutlet var messageComposingView: UIView!
    @IBOutlet weak var messageCointainerScroll: UIScrollView!
    @IBOutlet weak var buttomLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    var selectedFollower: Follower!
    var lastChatBubbleY: CGFloat = 10.0
    var internalPadding: CGFloat = 8.0
    var lastMessageType: MessageType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set follower's name & screen name as screen title
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 260, height: 44))
        label.backgroundColor = UIColor.clear
        label.numberOfLines = 2
        label.font = UIFont.boldSystemFont(ofSize: 16.0)
        label.textAlignment = .center
        label.textColor = UIColor.white
        let string = "\(self.selectedFollower.name!)\n@\(self.selectedFollower.screen_name!)" as NSString
        let attributedString = NSMutableAttributedString(string: string as String, attributes: [NSFontAttributeName:UIFont.boldSystemFont(ofSize: 16.0)])
        let smallFontAttribute = [NSFontAttributeName: UIFont.systemFont(ofSize: 12.0)]
        attributedString.addAttributes(smallFontAttribute, range: string.range(of: "@\(self.selectedFollower.screen_name!)"))
        label.attributedText = attributedString
        self.navigationItem.titleView = label
        
        // Tap to dismiss keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ChatViewController.dismissKeyboard))
        self.messageCointainerScroll.addGestureRecognizer(tap)
        
        // Separator line
        self.messageComposingView.layer.borderColor = UIColor.lightGray.cgColor
        self.messageComposingView.layer.borderWidth = 0.5
        
        // Disable send button by default
        self.sendButton.isEnabled = false
        
        // Observe keyboard open/dismiss events
        self.addKeyboardNotifications()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    // MARK: - Private Methods
    
    private func addKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func addSenderMessageBubble() {
        let messageText = self.textField.text
        let message = Message(text: messageText, date: Date(), type: .mine)
        self.addMessageBubble(message)
        
        // delay 1 second
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.addOpponentMessageBubble(messageText)
        }
    }
    
    func addOpponentMessageBubble(_ text: String?) {
        let message = Message(text: "\(text!) \(text!)", date: Date(), type: .opponent)
        self.addMessageBubble(message)
    }
    
    func addMessageBubble(_ data: Message) {
        let padding: CGFloat = lastMessageType == data.type ? internalPadding/3.0 :  internalPadding
        let messageubble = MessageBubble(data: data, startY:lastChatBubbleY + padding)
        self.messageCointainerScroll.addSubview(messageubble)
        
        lastChatBubbleY = messageubble.frame.maxY
        
        self.messageCointainerScroll.contentSize = CGSize(width: messageCointainerScroll.frame.width, height: lastChatBubbleY + internalPadding)
        self.moveToLastMessage()
        lastMessageType = data.type
        textField.text = ""
        sendButton.isEnabled = false
    }
    
    func moveToLastMessage() {
        if messageCointainerScroll.contentSize.height > messageCointainerScroll.frame.height {
            let contentOffSet = CGPoint(x: 0.0, y: messageCointainerScroll.contentSize.height - messageCointainerScroll.frame.height)
            self.messageCointainerScroll.setContentOffset(contentOffSet, animated: true)
        }
    }
    
    func getRandomMessageType() -> MessageType {
        return MessageType(rawValue: Int(arc4random() % 2))!
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    // MARK: - Notification
    
    func keyboardWillShow(notification: Notification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        UIView.animate(withDuration: 1.0, animations: { () -> Void in
            self.buttomLayoutConstraint.constant = keyboardFrame.size.height
        }, completion: { (completed: Bool) -> Void in
            self.moveToLastMessage()
        })
    }
    
    func keyboardWillHide(notification: Notification) {
        UIView.animate(withDuration: 1.0, animations: { () -> Void in
            self.buttomLayoutConstraint.constant = 0.0
        }, completion: { (completed: Bool) -> Void in
            self.moveToLastMessage()
        })
    }
    
    // MARK: - IBActions
    
    @IBAction func sendButtonClicked(_ sender: AnyObject) {
        self.addSenderMessageBubble()
        textField.resignFirstResponder()
    }

}

extension ChatViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.addSenderMessageBubble()
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var text: String
        if string.characters.count > 0 {
            text = String(format:"%@%@",textField.text!, string);
        } else {
            let string = NSString(string: textField.text!)
            text = string.substring(to: string.length - 1) as String
        }
        if text.characters.count > 0 {
            sendButton.isEnabled = true
        } else {
            sendButton.isEnabled = false
        }
        
        return true
    }
    
}
