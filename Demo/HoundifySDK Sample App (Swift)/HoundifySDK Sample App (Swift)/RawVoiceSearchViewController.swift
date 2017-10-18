//
//  RawVoiceSearchViewController.swift
//  HoundifySDK Sample App (Swift)
//
//  Created by Ken Huang on 11/25/16.
//  Copyright © 2016 SoundHound. All rights reserved.
//

import Foundation
import AVFoundation
import HoundifySDK

class RawVoiceSearchViewController: UIViewController, UISearchBarDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var setupButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    // MARK: - State
    
    private enum SetupState {
        case notSetUp, settingUpAudio, settingUpHoundify, setUp
    }
    
    private var setupState = SetupState.notSetUp {
        didSet {
            self.setupButton.isHidden = setupState == .setUp
            self.setupButton.isEnabled = setupState == .notSetUp
        }
    }
    
    let SAMPLE_RATE:Double = 44100
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshTextView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handle(houndVoiceSearchStateChangeNotification:)), name: .HoundVoiceSearchStateChange, object: nil)
        
        // Observe HoundVoiceSearchHotPhrase to be notified of when the hot phrase is detected.
        NotificationCenter.default.addObserver(self, selector: #selector(hotPhrase), name: .HoundVoiceSearchHotPhrase, object: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: UIStatusBar
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - HoundifySDK Lifecycle
    
    func trySetupAudio() {
        guard setupState == .notSetUp else {
            return
        }
        
        setupState = .settingUpAudio
        
        AudioTester.instance.startAudioWithSampleRate(SAMPLE_RATE) { error, data in
            if let error = error as NSError? {
                let errorString = "Audio Setup Error: \(error.localizedDescription)"
                self.updateText = errorString
                print(errorString)
                if self.setupState != .setUp {
                    self.setupState = .notSetUp
                }
            } else if self.setupState == .settingUpAudio {
                self.setupHoundifySDK()
            } else if self.setupState == .setUp, let data = data {
                
                // startAudioWithSampleRate's handler is used to return audio data.
                // Pass this data to HoundVoiceSearch
                self.passAudioData(data)
            }
        }
    }
    
    func setupHoundifySDK() {
        
        setupState = .settingUpHoundify
        
        // When using HoundVoiceSearch in raw mode, call setupRawMode(withInputSampleRate:, completionHandler:)
        // before making voice search available in your app.
        
        HoundVoiceSearch.instance().setupRawMode(withInputSampleRate: AVAudioSession.sharedInstance().sampleRate, completionHandler:
            
            { (error: Error?) in
                if let error = error as NSError? {
                    let errorString = "Error: \(error.localizedDescription)"
                    self.updateText = errorString
                    print(errorString)
                    self.setupState = .notSetUp
                } else {
                    self.setupState = .setUp
                    self.houndVoiceSearchStateDidChange()
                }
            }
        )
    }
    
    func passAudioData(_ data: Data) {
        
        // When using HoundVoiceSearch in raw mode, the application is responsible for continuously passing audio data
        // to the SDK
        
        HoundVoiceSearch.instance().writeRawAudioData(data)
    }
    
    func startSearch() {
        
        HoundVoiceSearch.instance().start(withRequestInfo: nil, responseHandler:
            
            { (error: Error?, responseType: HoundVoiceSearchResponseType, response: Any?, dictionary: [String : Any]?, requestInfo: [String : Any]?) in
                if let error = error as NSError? {
                    
                    AudioTester.instance.stopAudioWithHandler(nil)
                    self.updateText = "\(error.domain) \(error.code) \(error.localizedDescription)"
                    
                } else if responseType == .partialTranscription, let partialResponse = response as? HoundDataPartialTranscript {

                    // While a voice query is being recorded, the HoundSDK will provide ongoing transcription
                    // updates which can be displayed to the user.
                    
                    self.updateText = partialResponse.partialTranscript
                    
                } else if responseType == .houndServer, let dictionary = dictionary {
                    
                    self.responseText = JSONAttributedFormatter.attributedString(from: dictionary, style: nil)
                }
            }
        )
    }
    
    func houndVoiceSearchStateDidChange() {
        switch HoundVoiceSearch.instance().state {
        case .none:
            // Don't update UI when audio is disabled for backgrounding.
            if UIApplication.shared.applicationState == .active {
                update(status: "Not Ready")
                searchButton.setTitle("Search", for: UIControlState())
                searchButton.isEnabled = false
                searchButton.backgroundColor = self.view.tintColor.withAlphaComponent(0.5)
                resetTextView()
            }
        case .ready:
            update(status: "Ready")
            searchButton.setTitle("Search", for: UIControlState())
            searchButton.isEnabled = true
            searchButton.backgroundColor = self.view.tintColor
            refreshTextView()
            
        case .recording:
            update(status: "Recording")
            searchButton.setTitle("Stop", for: UIControlState())
            searchButton.isEnabled = true
            searchButton.backgroundColor = self.view.tintColor
            
        case .searching:
            update(status: "Searching")
            searchButton.isEnabled = true
            searchButton.setTitle("Stop", for: UIControlState())
            searchButton.backgroundColor = self.view.tintColor
            
        case .speaking:
            update(status: "Speaking")
            searchButton.isEnabled = true
            searchButton.setTitle("Stop", for: UIControlState())
            searchButton.backgroundColor = .red
        }
    }
    
    // MARK: Notifications
    func handle(houndVoiceSearchStateChangeNotification _: Notification) {
        houndVoiceSearchStateDidChange()
    }
    
    func hotPhrase() {
        blankTextView()
        
        // When the hot phrase is detected, it is the responsibility of the application to
        // begin a voice search in the style of its choosing.
        self.startSearch()
    }
    
    //MARK: IBActions
    @IBAction func setupButtonTapped(_ sender: AnyObject) {
        tabBarController?.disableAllVoiceSearchControllers(except: self)
        
        trySetupAudio()
    }
    
    @IBAction func searchButtonTapped(_ sender: AnyObject) {
        // Take action based on current voice search state.
        switch HoundVoiceSearch.instance().state {
        case .none, .ready:
            blankTextView()
            self.startSearch()
            
        case .recording:
            HoundVoiceSearch.instance().stop()
            resetTextView()
            
        case .searching:
            HoundVoiceSearch.instance().cancel()
            resetTextView()
            
        case .speaking:
            HoundVoiceSearch.instance().stopSpeaking()
        }
    }
    
    // MARK: - Displayed Text
    
    private var explanatoryText: String? {
        let beginning = "HoundVoiceSearch.h offers voice search APIs with greater control."

        if setupState != .setUp {
            return beginning + "\n\nIf your app will be responsible for audio and will pass raw audio data to Houndify, you must first call setupRawMode(withInputSampleRate:, completionHandler:)\n\nTap \"Set Up\""
        } else if HoundVoiceSearch.instance().state == .ready {
            return beginning + "\n\nTap \"Search\" to begin a search with startSearch(requestInfo:...)"
        } else {
            return nil
        }
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
    
    private func blankTextView() {
        updateText = ""
        responseText = nil
    }
    
    private func resetTextView() {
        updateText = nil
        responseText = nil
    }
    
    private func refreshTextView() {
        if let responseText = responseText {
            textView.attributedText = responseText
        } else if let updateText = updateText {
            textView.text = updateText
        } else {
            textView.text = explanatoryText
        }
    }
    
    private func update(status: String?) {
        statusLabel.text = status
    }
}
