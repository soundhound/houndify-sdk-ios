//
//  SettingsViewController.swift
//  HoundifySDK Sample App (Swift)
//
//  Created by Ken Huang on 11/25/16.
//  Copyright © 2016 SoundHound. All rights reserved.
//

import Foundation
import HoundifySDK

class SettingsViewController: UIViewController {
	
	@IBOutlet weak var enableEndOfSpeechDetectionSwitch: UISwitch!
	@IBOutlet weak var enableHotPhraseSwitch: UISwitch!
	@IBOutlet weak var enableSpeechSwitch: UISwitch!
	
	//MARK: ViewController life cycle.
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		self.enableSpeechSwitch.isOn = HoundVoiceSearch.instance().enableSpeech
		self.enableHotPhraseSwitch.isOn = HoundVoiceSearch.instance().enableHotPhraseDetection
		self.enableEndOfSpeechDetectionSwitch.isOn = HoundVoiceSearch.instance().enableEndOfSpeechDetection
    }
	
	@IBAction func enableSpeechValueChanged(_ sender: AnyObject) {
		HoundVoiceSearch.instance().enableSpeech = self.enableSpeechSwitch.isOn
	}
	
	@IBAction func enableHotPhraseValueChanged(_ sender: AnyObject) {
		HoundVoiceSearch.instance().enableHotPhraseDetection = self.enableHotPhraseSwitch.isOn
	}
	
	@IBAction func enableEndOfSpeechDetectionValueChanged(_ sender: AnyObject) {
		HoundVoiceSearch.instance().enableEndOfSpeechDetection = self.enableEndOfSpeechDetectionSwitch.isOn
	}
	
	//MARK: Status Bar Style
	override var preferredStatusBarStyle : UIStatusBarStyle {
		return .lightContent
    }
}
