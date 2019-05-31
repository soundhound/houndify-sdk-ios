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
#import "HoundDataCommandResult+Extras.h"
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

@interface RawVoiceSearchViewController() <HoundVoiceSearchQueryDelegate>

@property(nonatomic, strong) IBOutlet UIButton* setupButton;
@property(nonatomic, weak) IBOutlet UIButton* searchButton;
@property(nonatomic, weak) IBOutlet UITextView* textView;
@property(nonatomic, weak) IBOutlet UILabel* statusLabel;

@property(nonatomic, assign) RawVoiceSearchViewControllerSetupState setupState;

@property(nonatomic, strong) HoundVoiceSearchQuery *query;

@property (nonatomic, readonly) NSString *explanatoryText;
@property (nonatomic, copy) NSString *updateText;
@property (nonatomic, copy) NSAttributedString *responseText;

@property (nonatomic, strong) UIFont *originalTextViewFont;
@property (nonatomic, strong) UIColor *originalTextViewColor;

@end

@implementation RawVoiceSearchViewController

- (void)setSetupState:(RawVoiceSearchViewControllerSetupState)setupState
{
    _setupState = setupState;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.setupButton.hidden = self.setupState == RawVoiceSearchViewControllerSetupStateSetUp;
        self.setupButton.enabled = self.setupState == RawVoiceSearchViewControllerSetupStateNotSetUp;
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.originalTextViewFont = self.textView.font;
    
    [self refreshTextView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Add notifications
    
    // Observe HoundVoiceSearchHotPhraseNotification to be notified of when the hot phrase is detected.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hotPhrase)
                                                 name:HoundVoiceSearchHotPhraseNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)refreshUI
{
    // Search button
    if (self.query && self.query.state != HoundVoiceSearchQueryStateFinished) {
        [self.searchButton setTitle:@"Stop" forState:UIControlStateNormal];
        self.searchButton.enabled = YES;
    } else {
        [self.searchButton setTitle:@"Search" forState:UIControlStateNormal];
        self.searchButton.enabled = [HoundVoiceSearch instance].isListening;
    }
    
    if (self.setupState != RawVoiceSearchViewControllerSetupStateSetUp) {
        self.searchButton.backgroundColor = [self.view.tintColor colorWithAlphaComponent:0.5];
    } else if (self.query.state == HoundVoiceSearchQueryStateSpeaking) {
        self.searchButton.backgroundColor = [UIColor redColor];
    } else {
        self.searchButton.backgroundColor = self.view.tintColor;
    }
    
    // Status Text
    NSString *status = nil;
    
    if (self.setupState != RawVoiceSearchViewControllerSetupStateSetUp) {
        status = @"Not Ready";
    } else if (self.query) {
        switch (self.query.state) {
            case HoundVoiceSearchQueryStateRecording:
                status = @"Recording";
                break;
            case HoundVoiceSearchQueryStateSearching:
                status = @"Searching";
                break;
            case HoundVoiceSearchQueryStateSpeaking:
                status = @"Speaking";
                break;
            default:
                status = @"Ready";
                break;
        }
    } else {
        status = @"Ready";
    }
    
    [self updateStatus:status];
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
             [self refreshUI];
             [self refreshTextView];
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
    if (self.query.isActive || self.setupState != RawVoiceSearchViewControllerSetupStateSetUp) {
        return;
    }
    // To perform a voice search, create an instance of HoundVoiceSearchQuery
    // Configure it, including setting its delegate
    // And call -start
    
    self.query = [[HoundVoiceSearch instance] newVoiceSearch];
    
    self.query.delegate = self;
    
    // An example of how to use RequestInfo: set the location to SoundHound HQ.
    // a real application, of course, one would use location services to determine
    // the device's location.
    
    self.query.requestInfoBuilder.latitude = 37.4089054;
    self.query.requestInfoBuilder.longitude = -121.9849621;
    self.query.requestInfoBuilder.positionTime = lround([[NSDate date] timeIntervalSince1970]);
    self.query.requestInfoBuilder.positionHorizontalAccuracy = 10.0;
    
    [self.query start];
    
}

# pragma mark - HoundVoiceSearchQueryDelegate

- (void)houndVoiceSearchQuery:(HoundVoiceSearchQuery *)query changedStateFrom:(HoundVoiceSearchQueryState)oldState to:(HoundVoiceSearchQueryState)newState
{
    [self refreshUI];
    
    if (newState == HoundVoiceSearchQueryStateFinished) {
        [self refreshTextView];
    }
}

- (void)houndVoiceSearchQuery:(HoundVoiceSearchQuery *)query didReceivePartialTranscription:(HoundDataPartialTranscript *)partialTranscript
{
    // While a voice query is being recorded, the HoundSDK will provide ongoing transcription
    // updates which can be displayed to the user.
    
    if (query == self.query) {
        self.updateText = partialTranscript.partialTranscript;
    }
}

- (void)houndVoiceSearchQuery:(HoundVoiceSearchQuery *)query didReceiveSearchResult:(HoundDataHoundServer *)houndServer dictionary:(NSDictionary *)dictionary
{
    if (query != self.query) {
        return;
    }
    
    // Domains that work with client features often return incomplete results that need
    // to be completed by the application before they are ready to use. See this method for
    // an example
    [self tryUpdateQueryResponse:query];
    
    HoundDataCommandResult *commandResult = houndServer.allResults.firstObject;
    
    // This sample app includes more detailed examples of how to use a CommandResult
    // for some queries. See HoundDataCommandResult-Extras.m
    NSAttributedString *specialExampleText = [commandResult exampleResultText];
    
    if (specialExampleText) {
        self.responseText = specialExampleText;
    } else {
        self.responseText = [JSONAttributedFormatter attributedStringFromObject:dictionary style:nil];
    }
    
    if (commandResult[@"NativeData"]) {
        NSLog(@"NativeData: %@", commandResult[@"NativeData"]);
    }
    
    // It is the application's responsibility to initiate text-to-speech for the response
    // if it is desired.
    // The SDK provides the -speakResponse method on HoundVoiceSearchQuery, or the
    // the application may use its own TTS support.
    [query speakResponse];
}

- (void)houndVoiceSearchQuery:(HoundVoiceSearchQuery *)query didFailWithError:(NSError *)error
{
    if (query != self.query) {
        return;
    }
    
    self.updateText = [NSString stringWithFormat:@"%@ %ld %@", error.domain, (long)error.code, error.localizedDescription];
}

- (void)houndVoiceSearchQueryDidCancel:(HoundVoiceSearchQuery *)query
{
    if (query != self.query) {
        return;
    }
    
    self.updateText = @"Canceled";
}

#pragma mark - Client Integration Example

- (void)tryUpdateQueryResponse:(HoundVoiceSearchQuery *)query
{
    // Some HoundServer responses need information from the client before they are "complete"
    // For more general information, start here: https://www.houndify.com/docs#dynamic-responses
    
    // In this example, let's look at ClientClearScreenCommand. Make sure the "Client Control"
    // domain is enabled in your Houndify Dashboard while you try this example, and say
    // "Clear the screen" to try it.
    
    // First, let's make sure we've got a ClientClearScreenCommand to work with.
    HoundDataCommandResult *commandResult = query.response.allResults.firstObject;
    
    // See HoundDataCommandResult-Extras.m for the implementation of isClientClearScreenCommand
    if (!commandResult.isClientClearScreenCommand) {
        return;
    }
    
    // ClientClearScreenCommand arrives from the server with a spoken response of
    // "This client does not support clearing the screen." by default.
    // This is because houndify does not know whether your application can clear
    // the screen when the command is received.
    
    // Let us suppose for the sake of this example that we'll only consider it a success
    // if the screen has contents to clear. (In this view controller, that will always be
    // true. Try clearing the screen twice in row in the Text Search example to see the
    // negative case.)
    
    if (self.textView.text.length > 0) {
        
        // CommandResult comes with a DynamicResponse in the clientActionSucceededResult
        // field which contains updates for the success case.
        // Use Hound.handleDynamicResponse to copy values from clientActionSucceeded
        // to the command result, and to update the conversation state.
        [Hound handleDynamicResponse:commandResult.clientActionSucceededResult
              andUpdateCommandResult:commandResult];
        
        // Now the spoken response is "Screen is now cleared."
    } else {
        [Hound handleDynamicResponse:commandResult.clientActionFailedResult
              andUpdateCommandResult:commandResult];
        
        // Now the spoken response is, "I couldn't clear the screen."
        
        // Just for fun, let's add our own explanation.
        commandResult.spokenResponse = [commandResult.spokenResponse stringByAppendingString:@" There was nothing to clear."];
    }
}

#pragma mark - Notifications

- (void)hotPhrase
{
    [self blankTextView];
    
    // When the hot phrase is detected, it is the responsibility of the application to
    // begin a voice search in the style of its choosing.
    [self startSearch];
}

- (void)applicationWillResignActive:(NSNotification*)notification
{
    [self.query cancel];
}

#pragma mark - IBActions

- (IBAction)setupButtonTapped:(id)sender
{
    [self.tabBarController disableAllVoiceSearchControllersExcept:self];
    
    [self trySetupAudio];
}



- (IBAction)searchButtonTapped:(id)sender
{
    // Begin a voice search if this is the first one.
    if (!self.query) {
        [self blankTextView];
        [self startSearch];
        return;
    }
    
    // The button performs different actions, depending on the state of the current query
    
    switch (self.query.state)
    {
        case HoundVoiceSearchQueryStateFinished:
            [self blankTextView];
            [self startSearch];
            break;
        case HoundVoiceSearchQueryStateRecording:
            [self.query finishRecording];
            [self resetTextView];
            break;
        case HoundVoiceSearchQueryStateSearching:
            [self.query cancel];
            [self resetTextView];
            break;
        case HoundVoiceSearchQueryStateSpeaking:
            [self.query stopSpeaking];
            break;
            
        default:
            break;
    }
}

#pragma mark - Displayed Text

- (NSString *)explanatoryText
{
    NSMutableString *text = [@"HoundVoiceSearch.h offers voice search APIs with greater control." mutableCopy];
    
    if (self.setupState != RawVoiceSearchViewControllerSetupStateSetUp) {
        [text appendString:@"\n\nIf your app will be responsible for audio and will pass raw audio data to Houndify, you must first call -setupRawModeWithInputSampleRate:completionHandler:\n\nTap \"Set Up\""];
    } else if ([HoundVoiceSearch instance].isListening) {
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
    self.textView.font = self.originalTextViewFont;
    self.textView.textColor = self.originalTextViewColor;

    if (self.responseText.length > 0) {
        self.textView.attributedText = self.responseText;
    } else if (self.updateText) {
        self.textView.text = self.updateText;
    } else {
        self.textView.text = self.explanatoryText;
    }
}

- (void)updateStatus:(NSString *)status
{
    self.statusLabel.text = status;
}

@end
