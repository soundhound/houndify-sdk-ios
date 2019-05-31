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
    
    var originalTextViewFont: UIFont?
    var originalTextViewColor: UIColor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        originalTextViewFont = responseTextView.font
        originalTextViewColor = responseTextView.textColor
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        listenButton.titleLabel?.numberOfLines = 0
        
        listenButton.isEnabled = !HoundVoiceSearch.instance().isListening || HoundVoiceSearch.instance().enableHotPhraseDetection == false
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
        
        if !HoundVoiceSearch.instance().isListening {
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
        
        if Houndify.instance().currentQuery?.state == .speaking {
            Houndify.instance().currentQuery?.stopSpeaking()
            return
        }
        
        resetTextView()
        
        // Launch the houndify listening UI using presentListeningViewController(in:, from:, style:, configureQuery:, completion:)
        
        Houndify.instance().presentListeningViewController(in: tabBarController,
                                                           from: sender,
                                                           style: nil,
                                                           configureQuery:
            
            { (query) in
                // If not using the default, Set the end point URL here.
                // query.endPointURL = URL(string: "custom.url.com")
                
                // Example of setting location, hardcoded to Santa Clara
                query.requestInfoBuilder.latitude = 37.387390
                query.requestInfoBuilder.longitude = -121.974447
                query.requestInfoBuilder.positionTime = Int(Date().timeIntervalSince1970)
                query.requestInfoBuilder.positionHorizontalAccuracy = 10
            },
                                                           
                                                           completion:
            
            { (query) in
                if let error = query.error as NSError? {
                    self.updateText = "\(error.domain) \(error.code) \(error.localizedDescription)"
                } else if let dictionary = query.dictionary {
                    let commandResult = query.response?.allResults?.first
                    
                    // This sample app includes more detailed examples of how to use a CommandResult
                    // for some queries. See HoundDataCommandResult-Extras.swift
                    if let exampleText = commandResult?.exampleResultText() {
                        self.responseText = exampleText
                    } else {
                        self.responseText = JSONAttributedFormatter.attributedString(from: dictionary, style: nil)
                    }
                }
                
                // Any commandResult properties from the documentation can be accessed through the keyed accessors, e.g.:
                
                if  let serverData = query.response,
                    let commandResult = serverData.allResults?.first,
                    let nativeData = commandResult["NativeData"]
                {
                    print("NativeData: \(nativeData)")
                }
                
                // It is the application's responsibility to initiate text-to-speech for the response
                // if it desired.
                // The SDK provides the speakResponse() method on HoundVoiceSearchQuery, or the
                // the application may use its own TTS support.
                query.speakResponse()
        })
        
    }
    
    // MARK: - Notifications
    
    @objc func handle(houndVoiceSearchStateChangeNotification notification: Notification) {
        
        // Check whether listening has been disabled.
        guard HoundVoiceSearch.instance().isListening else {
            // Don't update UI when audio is disabled for backgrounding.
            if UIApplication.shared.applicationState == .active {
                self.statusLabel.text = ""
                listenButton.isEnabled = true
                refreshTextView()
            }
            return
        }
        
        listenButton.isEnabled = HoundVoiceSearch.instance().enableHotPhraseDetection == false
        
        // Check whether there is a current query
        guard let query = notification.userInfo?[HoundVoiceSearchQueryKey] as? HoundVoiceSearchQuery else {
            self.statusLabel.text = "Listening"
            refreshTextView()
            return
        }
        
        var statusString = ""
        
        switch query.state {
        case .notStarted, .finished:
            statusString = "Listening"
            refreshTextView()
        case .recording:
            statusString = "Recording"
            refreshTextView()
        case .searching:
            statusString = "Searching"
        case .speaking:
            statusString = "Speaking"
        @unknown default:
            break
        }
        
        self.statusLabel.text = statusString
    }
    
    @objc func handle(houndVoiceSearchHotPhraseNotification notification: Notification) {
        activateVoiceSearch(self.houndifyButton)
    }
    
    // MARK: - Displayed Text

    private var explanatoryText: String {
        var text = ""
        
        if !HoundVoiceSearch.instance().isListening || !(Houndify.instance().currentQuery?.isActive == true) {
            text = "Houndify.h offers the simplest API for offering voice search in your app. It provides a UI and manages audio for you. Tap the microphone to begin a voice search with presentListeningViewController(...)"
        } else {
            return ""
        }
        
        if !HoundVoiceSearch.instance().isListening || HoundVoiceSearch.instance().enableHotPhraseDetection == false {
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
        responseTextView.font = originalTextViewFont
        responseTextView.textColor = originalTextViewColor
        
        if let responseText = responseText {
            responseTextView.attributedText = responseText
        } else if let updateText = updateText {
            responseTextView.text = updateText
        } else {
            responseTextView.text = explanatoryText
        }
    }
}
