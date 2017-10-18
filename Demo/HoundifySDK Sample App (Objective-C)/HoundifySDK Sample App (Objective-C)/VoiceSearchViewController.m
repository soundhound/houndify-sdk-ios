//
//  VoiceSearchViewController.m
//  HoundifySDK Sample App (Objective-C)
//
//  Created by Cyril Austin on 5/20/15.
//  Copyright (c) 2017 SoundHound, Inc. All rights reserved.
//

#import "VoiceSearchViewController.h"
#import "JSONAttributedFormatter.h"
#import "UITabBarController+HoundifySample.h"
@import HoundifySDK;
@import AVFoundation;

#pragma mark - VoiceSearchViewController

@interface VoiceSearchViewController()

@property(nonatomic, weak) IBOutlet UIButton* listeningButton;
@property(nonatomic, weak) IBOutlet UIButton* searchButton;
@property(nonatomic, weak) IBOutlet UITextView* textView;
@property(nonatomic, weak) IBOutlet UILabel* statusLabel;

@property(nonatomic, strong) UIView* levelView;

@property (nonatomic, readonly) NSString *explanatoryText;
@property (nonatomic, copy) NSString *updateText;
@property (nonatomic, copy) NSAttributedString *responseText;

@end

@implementation VoiceSearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Setup Level View
    
    self.levelView = [[UIView alloc] init];
    
    self.levelView.backgroundColor = self.view.tintColor;
    
    CGFloat levelHeight = 2.0;
    
    CGRect tabBarFrame = [self.view convertRect:self.tabBarController.tabBar.bounds fromView:self.tabBarController.tabBar];
    
    self.levelView.frame = CGRectMake(
        0,
        CGRectGetMinY(tabBarFrame) - levelHeight,
        0,
        levelHeight
    );
    
    [self.view addSubview:self.levelView];
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
    
    // Observe HoundVoiceSearchAudioLevelNotification to visualize audio input
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioLevel:)
                                                 name:HoundVoiceSearchAudioLevelNotification
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

- (void)startListening
{
    // If you are allowing the HoundifySDK to manage audio for you, call -startListeningWithCompletionHandler:
    // before making voice search available in your app. This configures and activates the AVAudioSession
    // as well as initiating listening for the hot phrase, if you are using it.
    
    [[HoundVoiceSearch instance] startListeningWithCompletionHandler:^(NSError * _Nullable error) {
        [self updateListeningButton];
        
        if (error) {
            self.updateText = error.localizedDescription;
        }
    }];
}

- (void)stopListening
{
    // If you need to deactivate the HoundSDK AVAudioSession, call stopListening(completionHandler:)

    [[HoundVoiceSearch instance] stopListeningWithCompletionHandler:^(NSError * _Nullable error) {
        [self updateListeningButton];
        
        if (error) {
            self.updateText = error.localizedDescription;
        }
    }];
}


- (void)startSearch
{
    
    // To begin recording a voice query, call -startSearchWithRequestInfo:responseHandler:
    
    [[HoundVoiceSearch instance] startSearchWithRequestInfo:nil responseHandler:
     
     ^(NSError* error, HoundVoiceSearchResponseType responseType, id response, NSDictionary* dictionary, NSDictionary* requestInfo) {
    
         if (error)
         {
             // Handle error
             
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
             
             // Any properties from the documentation can be accessed through the keyed accessors, e.g.:
             
             HoundDataHoundServer* houndServer = response;
             
             HoundDataCommandResult* commandResult = houndServer.allResults.firstObject;
             
             NSDictionary* nativeData = commandResult[@"NativeData"];
             
             NSLog(@"NativeData: %@", nativeData);
         }
     }];
}

#pragma mark Notifications

- (void)handleHoundVoiceSearchStateChangeNotification:(NSNotification *)notification
{
    switch (HoundVoiceSearch.instance.state)
    {
        case HoundVoiceSearchStateNone:
        
            // Don't update UI when audio is disabled for backgrounding.
            if (UIApplication.sharedApplication.applicationState == UIApplicationStateActive) {
                [self updateListeningButton];
                
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

- (void)audioLevel:(NSNotification*)notification
{
    // The HoundVoiceSearchAudioLevel notification delivers the the audio level as an NSNumber between 0 and 1.0
    // in the object property of the notification.
    
    float audioLevel = [notification.object floatValue];
    
    UIViewAnimationOptions options = UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState;
    
    [UIView animateWithDuration:0.05 delay:0.0 options:options animations:^{
        
        self.levelView.frame = CGRectMake(
                                          0,
                                          CGRectGetMinY(self.levelView.frame),
                                          audioLevel * self.view.frame.size.width,
                                          self.levelView.frame.size.height
                                          );
    } completion:NULL];
}

- (void)hotPhrase
{
    [self blankTextView];
    
    // When the hot phrase is detected, it is the responsibility of the application to
    // begin a voice search in the style of its choosing.
    
    [self startSearch];
}

#pragma mark - Action Handlers

- (IBAction)didTapListeningButton:(id)sender
{
    self.listeningButton.enabled = NO;
    
    [self.tabBarController disableAllVoiceSearchControllersExcept:self];
    
    if ([HoundVoiceSearch instance].state == HoundVoiceSearchStateNone) {
        [self startListening];
    } else {
        [self stopListening];
    }
}

- (IBAction)didTapStartButton:(id)sender
{
    // Take action based on current voice search state
    
    switch ([HoundVoiceSearch instance].state)
    {
        case HoundVoiceSearchStateNone:
            
            break;
        
        case HoundVoiceSearchStateReady:
            
            [self blankTextView];
            
            [self startSearch];

            break;
        
        case HoundVoiceSearchStateRecording:
        
            [[HoundVoiceSearch instance] stopSearch];
            
            [self resetTextView];

            break;
        
        case HoundVoiceSearchStateSearching:
        
            [[HoundVoiceSearch instance] cancelSearch];
            
            [self resetTextView];
            
            break;
        
        case HoundVoiceSearchStateSpeaking:
        
            [[HoundVoiceSearch instance] stopSpeaking];
            
            break;
    }
}

- (void)updateListeningButton
{
    self.listeningButton.enabled = YES;
    self.listeningButton.selected = [HoundVoiceSearch instance].state != HoundVoiceSearchStateNone;
}

#pragma mark - Displayed Text

- (NSString *)explanatoryText
{
    NSMutableString *text = [@"HoundVoiceSearch.h offers voice search APIs with greater control." mutableCopy];
    
    switch ([HoundVoiceSearch instance].state) {
        case HoundVoiceSearchStateNone:
            [text appendString:@"\n\nIf you would like Houndify to manage audio, you must activate the audio session with -startListeningWithCompletionHandler:\n\nTap \"Listen\""];
            break;
        case HoundVoiceSearchStateReady:
            [text appendString:@"\n\nTap \"Search\" to begin a search with -startSearchWithRequestInfo:...\n\nTap \"Listen\" to deactivate the Hound audio session with -stopListeningWithCompletionHandler:"];
            break;
            
        default:
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
