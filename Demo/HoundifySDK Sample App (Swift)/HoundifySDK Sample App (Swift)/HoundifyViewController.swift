//
//  HoundifyViewController.swift
//  HoundifySDK Sample App (Swift)
//
//  Created by Jeff Weitzel on 6/29/17.
//  Copyright © 2017 SoundHound. All rights reserved.
//

import UIKit
import HoundifySDK

class HoundifyViewController: UIViewController {
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var responseTextView: UITextView!
    @IBOutlet weak var listenButton: UIButton!
    @IBOutlet weak var houndifyButton: UIButton!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        listenButton.titleLabel?.numberOfLines = 0
        
        listenButton.isEnabled = HoundVoiceSearch.instance().state == .none || HoundVoiceSearch.instance().enableHotPhraseDetection == false
        resetTextView()
        
        //Add Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(handle(houndVoiceSearchStateChangeNotification:)), name: .HoundVoiceSearchStateChange, object: nil)
        
        // Observe HoundVoiceSearchHotPhrase to be notified of when the hot phrase is detected.
        NotificationCenter.default.addObserver(self, selector: #selector(handle(houndVoiceSearchHotPhraseNotification:)), name: .HoundVoiceSearchHotPhrase, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: - HoundifySDK
    
    private func startListeningForHotPhrase() {
        
        // Houndify.presentListingViewController(...) will activate audio if necessary, but
        // if you wish to support beginning voice queries with a hot phrase, you will need to
        // explicitly start HoundVoiceSearch listening.
        
        HoundVoiceSearch.instance().startListening(completionHandler: { (error: Error?) in
            if let error = error {
                self.updateText = error.localizedDescription
            } else {
                self.listenButton.isEnabled = false
                HoundVoiceSearch.instance().enableHotPhraseDetection = true
                self.refreshTextView()
            }
        })
    }

    @IBAction func beginListeningButtonPressed(_ sender: UIButton?) {
        tabBarController?.disableAllVoiceSearchControllers(except: self)
        
        if HoundVoiceSearch.instance().state == .none {
            startListeningForHotPhrase()
        } else {
            HoundVoiceSearch.instance().enableHotPhraseDetection = true
            listenButton.isEnabled = false
            refreshTextView()
        }
    }
    
    @IBAction func activateVoiceSearch(_ sender: UIButton?) {
        guard let tabBarController = tabBarController else { return }
        
        tabBarController.disableAllVoiceSearchControllers(except: self)
        
        resetTextView()
        
        // Launch the houndify listening UI using presentListeningViewController(in:, from:, style:, requestInfo:, responseHandler:)
        
        Houndify.instance().presentListeningViewController(in: tabBarController,
                                                           from: sender,
                                                           style: nil,
                                                           requestInfo: [:], 
                                                           responseHandler:
            
            { (error: Error?, response: Any?, dictionary: [String : Any]?, requestInfo: [String : Any]?) in
                if let error = error as NSError? {
                    self.updateText = "\(error.domain) \(error.code) \(error.localizedDescription)"
                } else if let dictionary = dictionary {
                    self.responseText = JSONAttributedFormatter.attributedString(from: dictionary, style: nil)
                }
                
                if  let serverData = response as? HoundDataHoundServer,
                    let commandResult = serverData.allResults?.firstObject() as? HoundDataCommandResult,
                    let nativeData = commandResult["NativeData"]
                {
                    print("NativeData: \(nativeData)")
                }
                
                self.dismissSearch()
            }
        )
    }
    
    fileprivate func dismissSearch() {
        Houndify.instance().dismissListeningViewController(animated: true, completionHandler: nil)
    }
    
    // MARK: - Notifications
    
    func handle(houndVoiceSearchStateChangeNotification notification: Notification) {
        var statusString = ""
        
        switch HoundVoiceSearch.instance().state {
        case .none:
            // Don't update UI when audio is disabled for backgrounding.
            if UIApplication.shared.applicationState == .active {
                statusString = ""
                listenButton.isEnabled = true
                refreshTextView()
            }
        case .ready:
            statusString = "Listening"
            listenButton.isEnabled = HoundVoiceSearch.instance().enableHotPhraseDetection == false
            refreshTextView()
        case .recording:
            statusString = "Recording"
            refreshTextView()
        case .searching:
            statusString = "Searching"
        case .speaking:
            statusString = "Speaking"
        }
        
        self.statusLabel.text = statusString
    }
    
    func handle(houndVoiceSearchHotPhraseNotification notification: Notification) {
        activateVoiceSearch(self.houndifyButton)
    }
    
    // MARK: - Displayed Text

    private var explanatoryText: String? {
        var text = ""
        
        if HoundVoiceSearch.instance().state == .none || HoundVoiceSearch.instance().state == .ready {
            text = "Houndify.h offers the simplest API for offering voice search in your app. It provides a UI and manages audio for you. Tap the microphone to begin a voice search with presentListeningViewController(...)"
        } else {
            return ""
        }
        
        if HoundVoiceSearch.instance().state == .none || HoundVoiceSearch.instance().enableHotPhraseDetection == false {
            text += "\n\nTo use a hot phrase with the Houndify UI, audio must first be explicitly activated. See startListeningForHotPhrase() in HoundifyViewController in this sample code. Tap \"Listen for Hot Phrase\""
        }
        
        return text
    }
    
    private var updateText: String? {
        didSet {
            refreshTextView()
        }
    }
    
    private var responseText: NSAttributedString?{
        didSet {
            refreshTextView()
        }
    }
    
    private func resetTextView() {
        updateText = nil
        responseText = nil
    }
    
    private func refreshTextView() {
        if let responseText = responseText {
            responseTextView.attributedText = responseText
        } else if let updateText = updateText {
            responseTextView.text = updateText
        } else {
            responseTextView.text = explanatoryText
        }
    }
}
