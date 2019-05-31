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

class RawVoiceSearchViewController: UIViewController, UISearchBarDelegate, HoundVoiceSearchQueryDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var setupButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    private var query: HoundVoiceSearchQuery?
    
    var originalTextViewFont: UIFont?
    var originalTextViewColor: UIColor?

    
    // MARK: - State
    
    private enum SetupState {
        case notSetUp, settingUpAudio, settingUpHoundify, setUp
    }
    
    private var setupState = SetupState.notSetUp {
        didSet {
            DispatchQueue.main.async {
                self.setupButton.isHidden = self.setupState == .setUp
                self.setupButton.isEnabled = self.setupState == .notSetUp
            }
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
        
        // Observe HoundVoiceSearchHotPhrase to be notified of when the hot phrase is detected.
        NotificationCenter.default.addObserver(self, selector: #selector(hotPhrase), name: .HoundVoiceSearchHotPhrase, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive(_:)), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    private func refreshUI() {
        
        // Search button
        if let state = query?.state, state != .finished {
            searchButton.setTitle("Stop", for: .normal)
            searchButton.isEnabled = true
        } else {
            searchButton.setTitle("Search", for: .normal)
            searchButton.isEnabled = setupState == .setUp
        }
        
        if setupState != .setUp {
            searchButton.backgroundColor = self.view.tintColor.withAlphaComponent(0.5)
        } else if query?.state == .speaking {
            searchButton.backgroundColor = .red
        } else {
            searchButton.backgroundColor = self.view.tintColor
        }
        
        // Status Text
        var status: String
        
        if setupState != .setUp {
            status = "Not Ready"
        } else if let state = query?.state {
            switch state {
            case .recording: status = "Recording"
            case .searching: status = "Searching"
            case .speaking: status = "Speaking"
            default: status = "Ready"
            }
        } else {
            status = "Ready"
        }
        
        update(status: status)
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
                    self.refreshUI()
                    self.resetTextView()
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
        guard !(query?.isActive == true) && setupState == .setUp else { return }
        
        // To perform a voice search, create an instance of HoundVoiceSearchQuery
        // Configure it, including setting its delegate
        // And call start()
        
        query = HoundVoiceSearch.instance().newVoiceSearch()
        query?.delegate = self
        
        // An example of how to use RequestInfo: set the location to SoundHound HQ.
        // a real application, of course, one would use location services to determine
        // the device's location.
        
        query?.requestInfoBuilder.latitude = 37.4089054
        query?.requestInfoBuilder.longitude = -121.9849621
        query?.requestInfoBuilder.positionTime = Int(Date().timeIntervalSince1970)
        query?.requestInfoBuilder.positionHorizontalAccuracy = 10
        
        query?.start()
    }

    // MARK: - HoundVoiceSearchQueryDelegate
    
    public func houndVoiceSearchQuery(_ query: HoundVoiceSearchQuery, changedStateFrom oldState: HoundVoiceSearchQueryState, to newState: HoundVoiceSearchQueryState) {
        refreshUI()
        
        if newState == .finished {
            refreshTextView()
        }
    }
    
    public func houndVoiceSearchQuery(_ query: HoundVoiceSearchQuery, didReceivePartialTranscription partialTranscript: HoundDataPartialTranscript) {
        // While a voice query is being recorded, the HoundSDK will provide ongoing transcription
        // updates which can be displayed to the user.
        if query == self.query {
            self.updateText = partialTranscript.partialTranscript
        }
    }
    
    public func houndVoiceSearchQuery(_ query: HoundVoiceSearchQuery, didReceiveSearchResult houndServer: HoundDataHoundServer, dictionary: [AnyHashable : Any]) {
        guard query == self.query else { return }
        
        // Domains that work with client features often return incomplete results that need
        // to be completed by the application before they are ready to use. See this method for
        // an example
        tryUpdateQueryResponse(query)
        
        let commandResult = houndServer.allResults?.first
        
        // This sample app includes more detailed examples of how to use a CommandResult
        // for some queries. See HoundDataCommandResult-Extras.swift
        if let exampleText = commandResult?.exampleResultText() {
            responseText = exampleText
        } else {
            responseText = JSONAttributedFormatter.attributedString(from: dictionary, style: nil)
        }
        
        if let nativeData = commandResult?["NativeData"]
        {
            print("NativeData: \(nativeData)")
        }
        
        // It is the application's responsibility to initiate text-to-speech for the response
        // if it is desired.
        // The SDK provides the speakResponse() method on HoundVoiceSearchQuery, or the
        // the application may use its own TTS support.
        query.speakResponse()
    }
    
    public func houndVoiceSearchQuery(_ query: HoundVoiceSearchQuery, didFailWithError error: Error) {
        guard query == self.query else { return }
        
        let nserror = error as NSError
        self.updateText = "\(nserror.domain) \(nserror.code) \(nserror.localizedDescription)"
    }
    
    public func houndVoiceSearchQueryDidCancel(_ query: HoundVoiceSearchQuery) {
        guard query == self.query else { return }
        
        self.updateText = "Canceled"
    }
    
    // MARK: - Client Integration Example
    
    public func tryUpdateQueryResponse(_ query: HoundVoiceSearchQuery) {
        // Some HoundServer responses need information from the client before they are "complete"
        // For more general information, start here: https://www.houndify.com/docs#dynamic-responses
        
        // In this example, let's look at ClientClearScreenCommand. Make sure the "Client Control"
        // domain is enabled in your Houndify Dashboard while you try this example, and say
        // "Clear the screen" to try it.
        
        // First, let's make sure we've got a ClientClearScreenCommand to work with.
        let commandResult📦 = query.response?.allResults?.first
        
        // See HoundDataCommandResult-Extras.swift for the implementation of isClientClearScreenCommand
        guard let commandResult = commandResult📦, commandResult.isClientClearScreenCommand else {
            return
        }
        
        // ClientClearScreenCommand arrives from the server with a spoken response of
        // "This client does not support clearing the screen." by default.
        // This is because houndify does not know whether your application can clear
        // the screen when the command is received.
        
        // Let us suppose for the sake of this example that we'll only consider it a success
        // if the screen has contents to clear. (In this view controller, that will always be
        // true. Try clearing the screen twice in row in the Text Search example to see the
        // negative case.)
        
        if textView.text?.isEmpty == false {
            
            // CommandResult comes with a DynamicResponse in the clientActionSucceededResult
            // field which contains updates for the success case.
            
            if let clientActionSucceededResult = commandResult.clientActionSucceededResult {
                // Use Hound.handleDynamicResponse to copy values from clientActionSucceeded
                // to the command result, and to update the conversation state.
                Hound.handleDynamicResponse(clientActionSucceededResult, andUpdate: commandResult)
                
                // Now the spoken response is "Screen is now cleared."
            }
        } else if let clientActionFailedResult = commandResult.clientActionFailedResult {
            Hound.handleDynamicResponse(clientActionFailedResult, andUpdate: commandResult)
            
            // Now the spoken response is, "I couldn't clear the screen."
            // Just for fun, let's add our own explanation.
            commandResult.spokenResponse += " There was nothing to clear."
        }
    }

    // MARK: - Notifications
    @objc func hotPhrase() {
        blankTextView()
        
        // When the hot phrase is detected, it is the responsibility of the application to
        // begin a voice search in the style of its choosing.
        self.startSearch()
    }
    
    @objc func applicationWillResignActive(_ notification: Notification) {
        query?.cancel()
    }
    
    //MARK: IBActions
    @IBAction func setupButtonTapped(_ sender: AnyObject) {
        tabBarController?.disableAllVoiceSearchControllers(except: self)
        
        trySetupAudio()
    }
    
    @IBAction func searchButtonTapped(_ sender: AnyObject) {
        guard let query👍 = query else {
            blankTextView()
            startSearch()
            return
        }
        
        // The button performs different actions, depending on the state of the current query
        
        switch query👍.state {
        case .finished:
            blankTextView()
            startSearch()
            
        case .recording:
            query👍.finishRecording()
            resetTextView()
            
        case .searching:
            query👍.cancel()
            resetTextView()
            
        case .speaking:
            query👍.stopSpeaking()
            
        default:
            break
        }
    }
    
    // MARK: - Displayed Text
    
    private var explanatoryText: String? {
        let beginning = "HoundVoiceSearch.h offers voice search APIs with greater control."

        if setupState != .setUp {
            return beginning + "\n\nIf your app will be responsible for audio and will pass raw audio data to Houndify, you must first call setupRawMode(withInputSampleRate:, completionHandler:)\n\nTap \"Set Up\""
        } else if query == nil || query?.state == .finished {
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
        textView.font = originalTextViewFont
        textView.textColor = originalTextViewColor

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
