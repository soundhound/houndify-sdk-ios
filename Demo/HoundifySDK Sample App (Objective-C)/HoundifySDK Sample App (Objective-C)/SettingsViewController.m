//
//  SettingsViewController.m
//  HoundSDK Test Application
//
//  Created by Cyril Austin on 5/22/15.
//  Copyright (c) 2015 SoundHound, Inc. All rights reserved.
//

#import "SettingsViewController.h"
@import HoundifySDK;

#pragma mark - SettingsViewController

@interface SettingsViewController()

@property(nonatomic, strong) IBOutlet UISwitch* enableSpeechSwitch;
@property(nonatomic, strong) IBOutlet UISwitch* enableSpeechActivationDetectionSwitch;
@property(nonatomic, strong) IBOutlet UISwitch* enableEndOfSpeechDetectionSwitch;

@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Update UI based on current settings
    
    self.enableSpeechSwitch.on = HoundVoiceSearch.instance.enableSpeech;
    self.enableSpeechActivationDetectionSwitch.on = HoundVoiceSearch.instance.enableHotPhraseDetection;
    self.enableEndOfSpeechDetectionSwitch.on = HoundVoiceSearch.instance.enableEndOfSpeechDetection;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (IBAction)enableSpeechValueChanged
{
    HoundVoiceSearch.instance.enableSpeech = self.enableSpeechSwitch.on;
}

- (IBAction)enableSpeechActivationDetectionValueChanged
{
    HoundVoiceSearch.instance.enableHotPhraseDetection = self.enableSpeechActivationDetectionSwitch.on;
}

- (IBAction)enableEndOfSpeechDetectionValueChanged
{
    HoundVoiceSearch.instance.enableEndOfSpeechDetection = self.enableEndOfSpeechDetectionSwitch.on;
}

@end
