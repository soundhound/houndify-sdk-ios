//
//  RawVoiceSearchViewController.m
//  HoundifySDK Sample App (Objective-C)
//
//  Created by Cyril Austin on 6/2/15.
//  Copyright (c) 2017 SoundHound, Inc. All rights reserved.
//

#import "RawVoiceSearchViewController.h"
#import "JSONAttributedFormatter.h"
#import "UITabBarController+HoundifySample.h"
#import "AudioTester.h"
@import HoundifySDK;
@import AVFoundation;

#define SAMPLE_RATE                             44100

typedef NS_ENUM(NSUInteger, RawVoiceSearchViewControllerSetupState) {
    RawVoiceSearchViewControllerSetupStateNotSetUp,
    RawVoiceSearchViewControllerSetupStateSettingUpAudio,
    RawVoiceSearchViewControllerSetupStateSettingUpHoundify,
    RawVoiceSearchViewControllerSetupStateSetUp,
};

#pragma mark - RawVoiceSearchViewController

@interface RawVoiceSearchViewController()

@property(nonatomic, strong) IBOutlet UIButton* setupButton;
@property(nonatomic, weak) IBOutlet UIButton* searchButton;
@property(nonatomic, weak) IBOutlet UITextView* textView;
@property(nonatomic, weak) IBOutlet UILabel* statusLabel;

@property(nonatomic, assign) RawVoiceSearchViewControllerSetupState setupState;

@property (nonatomic, readonly) NSString *explanatoryText;
@property (nonatomic, copy) NSString *updateText;
@property (nonatomic, copy) NSAttributedString *responseText;

@end

@implementation RawVoiceSearchViewController

- (void)setSetupState:(RawVoiceSearchViewControllerSetupState)setupState
{
    _setupState = setupState;
    
    self.setupButton.hidden = _setupState == RawVoiceSearchViewControllerSetupStateSetUp;
    self.setupButton.enabled = _setupState == RawVoiceSearchViewControllerSetupStateNotSetUp;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self refreshTextView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Add notifications
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleHoundVoiceSearchStateChangeNotification:)
                                                 name:HoundVoiceSearchStateChangeNotification
                                               object:nil];
    
    // Observe HoundVoiceSearchHotPhraseNotification to be notified of when the hot phrase is detected.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hotPhrase)
                                                 name:HoundVoiceSearchHotPhraseNotification
                                               object:nil];
    
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


#pragma mark - HoundVoiceSearch Lifecycle.

- (void)trySetupAudio
{
    if (self.setupState != RawVoiceSearchViewControllerSetupStateNotSetUp) {
        return;
    }
    
    self.setupState = RawVoiceSearchViewControllerSetupStateSettingUpAudio;
    
    [[AudioTester instance] startAudioWithSampleRate:SAMPLE_RATE dataHandler:^(NSError *error, NSData *data) {
        if (error) {
            NSString *errorString = [NSString stringWithFormat:@"Audio Setup Error: %@", error.localizedDescription];
            self.updateText = errorString;
            NSLog(@"%@", errorString);
            if (self.setupState != RawVoiceSearchViewControllerSetupStateSetUp) {
                self.setupState = RawVoiceSearchViewControllerSetupStateNotSetUp;
            }
        } else if (self.setupState == RawVoiceSearchViewControllerSetupStateSettingUpAudio) {
            [self setupHoundifySDK];
        } else if (self.setupState == RawVoiceSearchViewControllerSetupStateSetUp) {
            // startAudioWithSampleRate's handler is used to return audio data.
            // Pass this data to HoundVoiceSearch
            [self passAudioData:data];
        }
    }];
}

- (void)setupHoundifySDK
{
    self.setupState = RawVoiceSearchViewControllerSetupStateSettingUpHoundify;
    
    // When using HoundVoiceSearch in raw mode, call -setupRawModeWithInputSampleRate:completionHandler:
    // before making voice search available in your app.

    [[HoundVoiceSearch instance] setupRawModeWithInputSampleRate:[AVAudioSession sharedInstance].sampleRate completionHandler:
     
     ^(NSError * _Nullable error) {
         if (error) {
             NSString *errorString = [NSString stringWithFormat:@"Error: %@", error.localizedDescription];
             self.updateText = errorString;
             NSLog(@"%@", errorString);
             self.setupState = RawVoiceSearchViewControllerSetupStateNotSetUp;
         } else {
             self.setupState = RawVoiceSearchViewControllerSetupStateSetUp;
             [self houndVoiceSearchStateDidChange];
         }
     }];
}

- (void)passAudioData:(NSData *)data {
    
    // When using HoundVoiceSearch in raw mode, the application is responsible for continuously passing audio data
    // to the SDK
    
    [[HoundVoiceSearch instance] writeRawAudioData:data];
}

- (void)startSearch
{
    [[HoundVoiceSearch instance] startSearchWithRequestInfo:nil responseHandler:
     
     ^(NSError * _Nullable error, HoundVoiceSearchResponseType responseType, id  _Nullable response, NSDictionary<NSString *,id> * _Nullable dictionary, NSDictionary<NSString *,id> * _Nullable requestInfo) {
         
         if (error)
         {
             [[AudioTester instance] stopAudioWithHandler:nil];
             
             self.updateText = [NSString stringWithFormat:@"%@ (%d)\n%@",
                                error.domain,
                                (int)error.code,
                                error.localizedDescription
                                ];
             return;
         }
         
         if (responseType == HoundVoiceSearchResponseTypePartialTranscription) {
             // While a voice query is being recorded, the HoundSDK will provide ongoing transcription
             // updates which can be displayed to the user.
             
             HoundDataPartialTranscript* partialTranscript = (HoundDataPartialTranscript*)response;
             
             self.updateText = partialTranscript.partialTranscript;
         } else if (responseType == HoundVoiceSearchResponseTypeHoundServer) {
             
             self.responseText = [JSONAttributedFormatter
                                  attributedStringFromObject:dictionary
                                  style:nil];
             
         }
     }];
}

- (void)houndVoiceSearchStateDidChange
{
    switch (HoundVoiceSearch.instance.state)
    {
        case HoundVoiceSearchStateNone:
            
            // Don't update UI when audio is disabled for backgrounding.
            if (UIApplication.sharedApplication.applicationState == UIApplicationStateActive) {
                self.statusLabel.text = @"Not Ready";
                self.searchButton.enabled = NO;
                [self.searchButton setTitle:@"Search" forState:UIControlStateNormal];
                self.searchButton.backgroundColor = [self.view.tintColor colorWithAlphaComponent:0.5];
                [self resetTextView];
            }
            break;
            
        case HoundVoiceSearchStateReady:
            
            self.statusLabel.text = @"Ready";
            self.searchButton.enabled = YES;
            [self.searchButton setTitle:@"Search" forState:UIControlStateNormal];
            self.searchButton.backgroundColor = self.view.tintColor;
            [self refreshTextView];
            break;
            
        case HoundVoiceSearchStateRecording:
            
            self.statusLabel.text = @"Recording";
            self.searchButton.enabled = YES;
            [self.searchButton setTitle:@"Stop" forState:UIControlStateNormal];
            self.searchButton.backgroundColor = self.view.tintColor;
            [self refreshTextView];
            break;
            
        case HoundVoiceSearchStateSearching:
            
            self.statusLabel.text = @"Searching";
            self.searchButton.enabled = YES;
            [self.searchButton setTitle:@"Stop" forState:UIControlStateNormal];
            self.searchButton.backgroundColor = self.view.tintColor;
            break;
            
        case HoundVoiceSearchStateSpeaking:
            
            self.statusLabel.text = @"Speaking";
            self.searchButton.enabled = YES;
            [self.searchButton setTitle:@"Stop" forState:UIControlStateNormal];
            self.searchButton.backgroundColor = UIColor.redColor;
            break;
    }
}

#pragma mark - Notifications

- (void)handleHoundVoiceSearchStateChangeNotification:(NSNotification *)notification
{
    [self houndVoiceSearchStateDidChange];
}

- (void)hotPhrase
{
    [self blankTextView];
    
    // When the hot phrase is detected, it is the responsibility of the application to
    // begin a voice search in the style of its choosing.
    [self startSearch];
}

#pragma mark - IBActions

- (IBAction)setupButtonTapped:(id)sender
{
    [self.tabBarController disableAllVoiceSearchControllersExcept:self];
    
    [self trySetupAudio];
}



- (IBAction)searchButtonTapped:(id)sender
{
    // Take action based on current voice search state
    
    switch (HoundVoiceSearch.instance.state)
    {
        case HoundVoiceSearchStateNone:
        case HoundVoiceSearchStateReady:
            
            [self blankTextView];
            [self startSearch];
            break;
        
        case HoundVoiceSearchStateRecording:
        
            [HoundVoiceSearch.instance stopSearch];
            [self resetTextView];
            break;
        
        case HoundVoiceSearchStateSearching:
        
            [HoundVoiceSearch.instance cancelSearch];
            [self resetTextView];
            break;
        
        case HoundVoiceSearchStateSpeaking:
        
            [HoundVoiceSearch.instance stopSpeaking];
            break;
    }
}

#pragma mark - Displayed Text

- (NSString *)explanatoryText
{
    NSMutableString *text = [@"HoundVoiceSearch.h offers voice search APIs with greater control." mutableCopy];
    
    if (self.setupState != RawVoiceSearchViewControllerSetupStateSetUp) {
        [text appendString:@"\n\nIf your app will be responsible for audio and will pass raw audio data to Houndify, you must first call -setupRawModeWithInputSampleRate:completionHandler:\n\nTap \"Set Up\""];
    } else if ([HoundVoiceSearch instance].state == HoundVoiceSearchStateReady) {
        [text appendString:@"\n\nTap \"Search\" to begin a search with -startSearchWithRequestInfo:..."];
    } else {
        return nil;
    }
    
    return text;
}

- (void)setUpdateText:(NSString *)updateText
{
    if (![_updateText isEqual:updateText]) {
        _updateText = [updateText copy];
        
        [self refreshTextView];
    }
}

- (void)setResponseText:(NSAttributedString *)responseText
{
    if (![_responseText isEqual:responseText]) {
        _responseText = [responseText copy];
        
        [self refreshTextView];
    }
}

- (void)blankTextView
{
    self.updateText = @"";
    self.responseText = nil;
}

- (void)resetTextView
{
    self.updateText = nil;
    self.responseText = nil;
}

- (void)refreshTextView
{
    if (self.responseText.length > 0) {
        self.textView.attributedText = self.responseText;
    } else if (self.updateText.length > 0) {
        self.textView.text = self.updateText;
    } else {
        self.textView.text = self.explanatoryText;
    }
}

@end
