//
//  GameViewController.swift
//  multipeer_game
//
//  Created by Timothy on 3/20/19.
//  Copyright © 2019 Timothy. All rights reserved.
//

import UIKit

let ServiceType = "mycrazyapp"

class GameViewController: UIViewController, MultipeerServiceDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var textView: UITextView!
    
    var alert : UIAlertController!
    var multipeerService: MultipeerService?
    
    var username = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set delegate for input field.
        inputTextField.delegate = self

        
        // Setting for text view to allow auto scroll to bottom.
        textView.layoutManager.allowsNonContiguousLayout = false
        
        // Prompt user to input username and start P2P communication.
    }
    
    override func viewDidAppear(_ animated: Bool) {
    

        restart()
        
    }
    
    // Show popup for entering username, P2P servic will start when name entered.
    func restart() {
        // Clear text view.
        textView.text = ""
        
        // Create alert popup.
        alert = UIAlertController(title: "Enter your username", message: nil, preferredStyle: .alert)
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Username..."
            textField.addTarget(self, action: #selector(self.alertTextFieldDidChange(_:)), for: .editingChanged)
        })
        
        // Create action on OK press.
        let action = UIAlertAction(title: "OK", style: .default, handler: { action in
            if let name = self.alert.textFields?.first?.text {
                // Save username and set to title.
                self.username = name
                self.navigationItem.title = name
                
                ///////////////////////////////////////////////////////
                // NOTE: Start P2P.
                self.startMultipeerService(displayName: name)
                ///////////////////////////////////////////////////////
                
            }
        })
        action.isEnabled = false
        alert.addAction(action)
        
        // Show alert popup.
        self.present(alert, animated: true)
    }
    
    // Disable okay button when text field is empty.
    @objc func alertTextFieldDidChange(_ sender: UITextField) {
        alert.actions[0].isEnabled = sender.text!.count > 0
    }
    func startMultipeerService(displayName: String) {
        self.multipeerService = nil
        self.multipeerService = MultipeerService(dispayName: displayName)
        self.multipeerService?.delegate = self
        
    }
    
    @IBAction func didTapSendButton(_ sender: UIButton) {
        guard let text = inputTextField.text, text.count > 0 else { return }
        
        // Prepend usename to msg.
        let msg = self.username + ": " + text
        
        // NOTE: Send msg to other peers.
        multipeerService?.send(msg: msg)
        
        // Append msg to text view.
        processText(msg)
        
        // Clear input field.
        inputTextField.text = ""
    }
    
    // Dismisses keyboard when done is pressed.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
    
    // Append text and scroll to bottom of text view.
    func processText(_ string: String) {
        
        // Construct the text that will be in the field if this change is accepted
        let updatedString = string.replacingOccurrences(of: ",", with: "")
        let result = updatedString.split(separator: " ")
        
        var newResult:[String] = []
        var activeText = false
        for (index,subItem) in result.enumerated(){
            var item = String(subItem)
                    if activeText {
                        newResult.append(item)
                    }else if translations[item.lowercased()] != nil && index != 0  {
                        newResult.append(translations[item.lowercased()]!)
                    }else if index == 0 {
                        newResult.append(item)
                    }else if item.contains("impersonate") {
                        item = item.replacingOccurrences(of: "impersonate", with: "")
                        newResult[0] = item + ":"
                    }else if item.contains("activeText") {
                        activeText = true
                    }else if item.contains("?"){
                        item = item.replacingOccurrences(of: "?", with: "")
                        if translations[item.lowercased()] != nil {
                            newResult.append(translations[item.lowercased()]!)
                        } else {
                            newResult.append(randomEmoji())
                        }
                        newResult.append("?")
                    } else {
                        newResult.append(randomEmoji())
                    }
        }
        var resultString = ""
        if (activeText){
            resultString = newResult.joined(separator: " ")
        } else {
            resultString = newResult.joined(separator: "")
        }
        textView.text += "\n" + resultString
        textView.scrollRangeToVisible(NSMakeRange(textView.text.count, 0))
    }
    
    @IBAction func didTapRestartButton(_ sender: UIBarButtonItem) {
        restart()
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////////
    // MARK: - MultipeerServiceDelegate
    
    func connectedDevicesChanged(manager: MultipeerService, connectedDevices: [String]) {
        // something happens
    }
    
    // NOTE: Process recieved msg.
    func receivedMsg(manager: MultipeerService, msg: String) {
        DispatchQueue.main.async {
            self.processText(msg)
            
        }
    }
    
    func randomEmoji()->String{
        let rangeArray = [[UInt32](0x1F601...0x1F64F),[UInt32](0x2702...0x27B0),[UInt32](0x1F680...0x1F6C0),[UInt32](0x1F170...0x1F251)]
        let range = rangeArray.randomElement()!
        let ascii = range[Int(drand48() * (Double(range.count)))]
        let emoji = UnicodeScalar(ascii)?.description
        return emoji!
    }
    

}

