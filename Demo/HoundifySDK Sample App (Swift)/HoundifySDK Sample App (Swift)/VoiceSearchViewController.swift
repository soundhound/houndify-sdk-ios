//
//  VoiceSearchViewController.swift
//  HoundifySDK Sample App (Swift)
//
//  Created by Ken Huang on 11/25/16.
//  Copyright © 2016 SoundHound. All rights reserved.
//

import Foundation
import HoundifySDK

class VoiceSearchViewController: UIViewController, UISearchBarDelegate {
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var listeningButton: UIButton!
    
    fileprivate var levelView: UIView = UIView()
    
    // MARK: - ViewController life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        levelView.backgroundColor = self.view.tintColor
        let levelHeight: CGFloat = 2.0
        let tabBarFrame = view.convert(tabBarController?.tabBar.bounds ?? CGRect.zero, from: tabBarController?.tabBar)
        levelView.frame = CGRect(x: 0, y: tabBarFrame.minY - levelHeight, width: 0, height: levelHeight)
        view.addSubview(self.levelView)
        refreshTextView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Add Notifications
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateState), name: .HoundVoiceSearchStateChange, object: nil)
        
        // Observe HoundVoiceSearchAudioLevel to visualize audio input
        NotificationCenter.default.addObserver(self, selector: #selector(audioLevel), name: .HoundVoiceSearchAudioLevel, object: nil)
        
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
    
    // MARK: - HoundVoiceSearch Lifecycle.
    
    private func startListening() {
        
        // If you are allowing the HoundifySDK to manage audio for you, call startListening(completionHandler:)
        // before making voice search available in your app. This configures and activates the AVAudioSession
        // as well as initiating listening for the hot phrase, if you are using it.
        
        HoundVoiceSearch.instance().startListening(completionHandler: { (error: Error?) in
            self.updateListeningButton()
            
            if let error = error {
                self.updateText = error.localizedDescription
            }
        })
    }
    
    private func stopListening() {
        
        // If you need to deactivate the HoundSDK AVAudioSession, call stopListening(completionHandler:)
        
        HoundVoiceSearch.instance().stopListening(completionHandler: { (error: Error?) in
            self.updateListeningButton()
            
            if let error = error {
                self.updateText = error.localizedDescription
            }
        })
    }
    
    func startSearch() {
        
        // To begin recording a voice query, call start(withRequestInfo:, responseHandler:)
        
        HoundVoiceSearch.instance().start(withRequestInfo:nil, responseHandler:
            
            { (error: Error?, responseType: HoundVoiceSearchResponseType, response: Any?, dictionary: [String : Any]?, requestInfo: [String : Any]?) in
                if let error = error as NSError? {
                    self.updateText = "\(error.domain) \(error.code) \(error.localizedDescription)"
                    return
                }
                
                if responseType == .partialTranscription, let partialResponse = response as? HoundDataPartialTranscript {
                    // While a voice query is being recorded, the HoundSDK will provide ongoing transcription
                    // updates which can be displayed to the user.
                    
                    self.updateText = partialResponse.partialTranscript
                }
                else if responseType == .houndServer {
                    if let dict = dictionary {
                        self.responseText = JSONAttributedFormatter.attributedString(from: dict, style: nil)
                    }
                    
                    if  let houndServer = response as? HoundDataHoundServer,
                        let commandResult = houndServer.allResults?.firstObject() as? HoundDataCommandResult,
                        let nativeData = commandResult["NativeData"]
                    {
                        print("NativeData: \(nativeData)")
                    }
                    
                }
            }
        )
    }
    
    //MARK: Notifications
    func updateState(_ notification: Notification) {
        switch HoundVoiceSearch.instance().state {
            case .none:
                // Don't update UI when audio is disabled for backgrounding.
                if UIApplication.shared.applicationState == .active {
                    updateListeningButton()
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
    
    func audioLevel(_ notification: Notification) {
        // The HoundVoiceSearchAudioLevel notification delivers the the audio level as an NSNumber between 0 and 1.0
        // in the object property of the notification. In Swift, this can be cast directly to CGFloat.
        
        guard let audioLevel = notification.object as? CGFloat else { return }
        
        UIView.animate(withDuration: 0.05, delay: 0.0, options: [.curveLinear, .beginFromCurrentState], animations: {
            self.levelView.frame = CGRect(x: 0, y: self.levelView.frame.minY, width: audioLevel * self.view.bounds.width, height: self.levelView.bounds.height)
        }, completion: nil)
    }
    
    func hotPhrase(_ notification: Notification) {
        blankTextView()
        
        // When the hot phrase is detected, it is the responsibility of the application to
        // begin a voice search in the style of its choosing.
        self.startSearch()
    }
    
    // MARK: - Action Handlers
    
    @IBAction func didTapListeningButton(_ sender: AnyObject) {
        self.listeningButton.isEnabled = false

        tabBarController?.disableAllVoiceSearchControllers(except: self)
        
        if HoundVoiceSearch.instance().state == .none {
            startListening()
        } else {
            stopListening()
        }
    }
    
    @IBAction func didTapStartButton(_ sender: AnyObject) {
        switch HoundVoiceSearch.instance().state {
            case .ready:
                blankTextView()
                startSearch()
            
            case .recording:
                HoundVoiceSearch.instance().stop()
                resetTextView()
            
            case .searching:
                HoundVoiceSearch.instance().cancel()
                resetTextView()
            
            case .speaking:
                HoundVoiceSearch.instance().stopSpeaking()
            
            default:
                break
        }
    }
    
    private func updateListeningButton() {
        listeningButton.isEnabled = true
        listeningButton.isSelected = HoundVoiceSearch.instance().state != .none
    }
    
    // MARK: - Displayed Text
    
    private var explanatoryText: String? {
        let beginning = "HoundVoiceSearch.h offers voice search APIs with greater control."
        
        switch HoundVoiceSearch.instance().state {
        case .none:
            return beginning + "\n\nIf you would like Houndify to manage audio, you must activate the audio session with startListening(completionHandler:)\n\nTap \"Listen\""
        case .ready:
            return beginning + "\n\nTap \"Search\" to begin a search with startSearch(requestInfo:...)\n\nTap \"Listen\" to deactivate the Hound audio session with stopListening(completionHandler:)"
        default:
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
