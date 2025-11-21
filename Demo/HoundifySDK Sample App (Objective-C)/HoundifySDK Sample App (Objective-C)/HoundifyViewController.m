//
//  HoundifyViewController.m
//  HoundifySDK Sample App (Objective-C)
//
//  Created by Cyril Austin on 10/29/15.
//  Copyright © 2015 SoundHound, Inc. All rights reserved.
//

#import "HoundifyViewController.h"
#import "UITabBarController+HoundifySample.h"
#import "JSONAttributedFormatter.h"
#import "HoundDataCommandResult+Extras.h"

@import HoundifySDK;
@import AVFoundation;

#pragma mark - HoundifyViewController

@interface HoundifyViewController()

@property (nonatomic, weak) IBOutlet UILabel *statusLabel;
@property (nonatomic, weak) IBOutlet UITextView *responseTextView;
@property (nonatomic, weak) IBOutlet UIButton *listenButton;
@property (nonatomic, weak) IBOutlet UIButton *houndifyButton;

@property (nonatomic, strong) UIFont *originalTextViewFont;
@property (nonatomic, strong) UIColor *originalTextViewColor;

@property (nonatomic, readonly) NSString *explanatoryText;
@property (nonatomic, copy) NSString *updateText;
@property (nonatomic, copy) NSAttributedString *responseText;

@end

@implementation HoundifyViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.originalTextViewFont = self.responseTextView.font;
    self.originalTextViewColor = self.responseTextView.textColor;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.listenButton.titleLabel.numberOfLines = 0;
    
    self.listenButton.enabled = ![HoundVoiceSearch instance].isListening || ![HoundVoiceSearch instance].enableHotPhraseDetection;
    
    [self resetTextView];
    
    // Add Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleHoundVoiceSearchStateChangeNotification:) name:HoundVoiceSearchStateChangeNotification object:nil];

    // Observe HoundVoiceSearchHotPhraseNotification to be notified of when the hot phrase is detected.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleHoundVoiceSearchHotPhraseNotification:) name:HoundVoiceSearchHotPhraseNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - HoundifySDK

- (void)startListeningForHotPhrase
{
    // Houndify -presentListingViewController: will activate audio if necessary, but
    // if you wish to support beginning voice queries with a hot phrase, you will need to
    // explicitly start HoundVoiceSearch listening.

    [[HoundVoiceSearch instance] startListeningWithCompletionHandler:^(NSError * _Nullable error) {
        
        if (error) {
            self.updateText = error.localizedDescription;
        } else {
            self.listenButton.enabled = NO;
            [HoundVoiceSearch instance].enableHotPhraseDetection = YES;
            [self refreshTextView];
        }
    }];
}

- (IBAction)beginListeningButtonPressed:(id)sender
{
    [self.tabBarController disableAllVoiceSearchControllersExcept:self];
    
    if (![HoundVoiceSearch instance].isListening) {
        [self startListeningForHotPhrase];
    } else {
        [HoundVoiceSearch instance].enableHotPhraseDetection = YES;
        self.listenButton.enabled = NO;
        [self refreshTextView];
    }
}

- (IBAction)activateVoiceSearch:(id)sender
{
    [self.tabBarController disableAllVoiceSearchControllersExcept:self];
    
    // If the current query is speaking, cancel it.
    if ([Houndify instance].currentQuery.state == HoundVoiceSearchQueryStateSpeaking) {
        [[Houndify instance].currentQuery stopSpeaking];
        return;
    }
    
    [self resetTextView];
    
    // Launch the houndify listening UI using presentListeningViewControllerInViewController:fromView:style:requestInfo:responseHandler:
    
    [[Houndify instance] presentListeningViewControllerInViewController:self.tabBarController
                                                               fromView:sender
                                                                  style:nil
                                                         configureQuery:
     ^(HoundVoiceSearchQuery * _Nonnull query) {
         // If not using the default, Set the end point URL here.
         // query.endPointURL = [NSURL URLWithString:@"custom.url.com"];
         
         // Example of setting location, hardcoded to Santa Clara
         query.requestInfoBuilder.latitude = 37.387390;
         query.requestInfoBuilder.longitude = -121.974447;
         query.requestInfoBuilder.positionTime = lround([[NSDate date] timeIntervalSince1970]);
         query.requestInfoBuilder.positionHorizontalAccuracy = 10.0;
     }
                                                             completion:
     ^(HoundVoiceSearchQuery * _Nonnull query) {
         if (query.error)
         {
             self.updateText = [NSString stringWithFormat:@"%@ %ld %@", query.error.domain, query.error.code, query.error.localizedDescription];
         }
         else
         {
             HoundDataCommandResult* commandResult = [query.response allResults].firstObject;
             
             // This sample app includes more detailed examples of how to use a CommandResult
             // for some queries. See HoundDataCommandResult-Extras.m
             NSAttributedString *specialExampleText = [commandResult exampleResultText];
             
             if (specialExampleText) {
                 self.responseText = specialExampleText;
             } else {
                 self.responseText = [JSONAttributedFormatter attributedStringFromObject:query.dictionary style:nil];
             }

             // Any properties from the documentation can be accessed through the keyed accessors, e.g.:
             
             NSDictionary* nativeData = commandResult[@"NativeData"];
             
             NSLog(@"NativeData: %@", nativeData);
         }
         
         // It is the application's responsibility to initiate text-to-speech for the response
         // if it is desired.
         // The SDK provides the -speakResponse method on HoundVoiceSearchQuery, or the
         // the application may use its own TTS support.
         [query speakResponse];
     }];
    
}


#pragma mark Notifications

- (void) handleHoundVoiceSearchStateChangeNotification:(NSNotification *)notification
{
    // Check whether listening has been disabled.
    if (![HoundVoiceSearch instance].isListening) {
        // Don't update UI when audio is disabled for backgrounding.
        if (UIApplication.sharedApplication.applicationState == UIApplicationStateActive) {
            self.statusLabel.text = @"";
            self.listenButton.enabled = YES;
            [self refreshTextView];
        }
        return;
    }
    
    self.listenButton.enabled = ![HoundVoiceSearch instance].enableHotPhraseDetection;

    // Check whether there is a current query
    HoundVoiceSearchQuery *query = notification.userInfo[HoundVoiceSearchQueryKey];
    if (!query) {
        self.statusLabel.text = @"Listening";
        [self refreshTextView];
        return;
    }
    
    NSString *statusString = nil;
    
    switch (query.state)
    {
        case HoundVoiceSearchQueryStateRecording:
            statusString = @"Recording";
            [self refreshTextView];
            break;
            
        case HoundVoiceSearchQueryStateSearching:
            statusString = @"Searching";
            break;
            
        case HoundVoiceSearchQueryStateSpeaking:
            statusString = @"Speaking";
            break;
            
        case HoundVoiceSearchQueryStateNotStarted:
        case HoundVoiceSearchQueryStateFinished:
            statusString = @"Listening";
            [self refreshTextView];
            break;
    }
    
    self.statusLabel.text = statusString;
}

- (void) handleHoundVoiceSearchHotPhraseNotification:(NSNotification *)notification
{
    [self activateVoiceSearch:self.houndifyButton];
}

#pragma mark - Displayed Text

- (NSString *)explanatoryText
{
    NSMutableString *text = nil;
    
    if (![HoundVoiceSearch instance].isListening || ![Houndify instance].currentQuery.isActive)
    {
        text = [@"Houndify.h offers the simplest API for offering voice search in your app. It provides a UI and manages audio for you. Tap the microphone to begin a voice search with presentListeningViewController(...)" mutableCopy];
    }
    else
    {
        return nil;
    }
    
    if (![HoundVoiceSearch instance].isListening || ![HoundVoiceSearch instance].enableHotPhraseDetection)
    {
        [text appendString:@"\n\nTo use a hot phrase with the Houndify UI, audio must first be explicitly activated. See startListeningForHotPhrase() in HoundifyViewController in this sample code. Tap \"Listen for Hot Phrase\""];
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

- (void)resetTextView
{
    self.updateText = nil;
    self.responseText = nil;
}

- (void)refreshTextView
{
    self.responseTextView.font = self.originalTextViewFont;
    self.responseTextView.textColor = self.originalTextViewColor;

    if (self.responseText.length > 0) {
        self.responseTextView.attributedText = self.responseText;
    } else if (self.updateText.length > 0) {
        self.responseTextView.text = self.updateText;
    } else {
        self.responseTextView.text = self.explanatoryText;
    }
}

@end
