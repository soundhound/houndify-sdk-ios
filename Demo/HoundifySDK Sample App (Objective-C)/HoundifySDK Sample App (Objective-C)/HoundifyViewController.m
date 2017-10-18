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

@import HoundifySDK;
@import AVFoundation;

#pragma mark - HoundifyViewController

@interface HoundifyViewController()

@property (nonatomic, weak) IBOutlet UILabel *statusLabel;
@property (nonatomic, weak) IBOutlet UITextView *responseTextView;
@property (nonatomic, weak) IBOutlet UIButton *listenButton;
@property (nonatomic, weak) IBOutlet UIButton *houndifyButton;

@property (nonatomic, readonly) NSString *explanatoryText;
@property (nonatomic, copy) NSString *updateText;
@property (nonatomic, copy) NSAttributedString *responseText;

@end

@implementation HoundifyViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.listenButton.titleLabel.numberOfLines = 0;
    
    self.listenButton.enabled = [HoundVoiceSearch instance].state == HoundVoiceSearchStateNone || ![HoundVoiceSearch instance].enableHotPhraseDetection;
    
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
    
    if ([HoundVoiceSearch instance].state == HoundVoiceSearchStateNone) {
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
    [self resetTextView];
    
    // Launch the houndify listening UI using presentListeningViewControllerInViewController:fromView:style:requestInfo:responseHandler:
    
    [[Houndify instance] presentListeningViewControllerInViewController:self.tabBarController
                                                               fromView:sender
                                                                  style:nil
                                                            requestInfo:nil
                                                        responseHandler:
     
     ^(NSError * _Nullable error, id  _Nullable response, NSDictionary<NSString *,id> * _Nullable dictionary, NSDictionary<NSString *,id> * _Nullable requestInfo) {
         if (error)
         {
             self.updateText = [NSString stringWithFormat:@"%@ %ld %@", error.domain, error.code, error.localizedDescription];
         }
         else
         {
             self.responseText = [JSONAttributedFormatter attributedStringFromObject:dictionary style:nil];
         
             HoundDataCommandResult* commandResult = [response allResults].firstObject;
             
             // Any properties from the documentation can be accessed through the keyed accessors, e.g.:
             
             NSDictionary* nativeData = commandResult[@"NativeData"];
             
             NSLog(@"NativeData: %@", nativeData);
         }

         [self dismissSearch];
     }];
}


- (void)dismissSearch
{
    [Houndify.instance dismissListeningViewControllerAnimated:YES completionHandler:NULL];
}

#pragma mark Notifications

- (void) handleHoundVoiceSearchStateChangeNotification:(NSNotification *)notification
{
    NSString *statusString = nil;
    
    switch ([HoundVoiceSearch instance].state)
    {
        case HoundVoiceSearchStateNone:
            // Don't update UI when audio is disabled for backgrounding.
            if (UIApplication.sharedApplication.applicationState == UIApplicationStateActive) {
                statusString = @"";
                self.listenButton.enabled = YES;
                [self refreshTextView];
            }
            break;
            
        case HoundVoiceSearchStateReady:
            statusString = @"Listening";
            self.listenButton.enabled = ![HoundVoiceSearch instance].enableHotPhraseDetection;
            [self refreshTextView];
            break;
            
        case HoundVoiceSearchStateRecording:
            statusString = @"Recording";
            [self refreshTextView];
            break;
            
        case HoundVoiceSearchStateSearching:
            statusString = @"Searching";
            break;
            
        case HoundVoiceSearchStateSpeaking:
            statusString = @"Speaking";
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
    
    if ([HoundVoiceSearch instance].state == HoundVoiceSearchStateNone || [HoundVoiceSearch instance].state == HoundVoiceSearchStateReady)
    {
        text = [@"Houndify.h offers the simplest API for offering voice search in your app. It provides a UI and manages audio for you. Tap the microphone to begin a voice search with presentListeningViewController(...)" mutableCopy];
    }
    else
    {
        return nil;
    }
    
    if ([HoundVoiceSearch instance].state == HoundVoiceSearchStateNone || ![HoundVoiceSearch instance].enableHotPhraseDetection)
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
    if (self.responseText.length > 0) {
        self.responseTextView.attributedText = self.responseText;
    } else if (self.updateText.length > 0) {
        self.responseTextView.text = self.updateText;
    } else {
        self.responseTextView.text = self.explanatoryText;
    }
}

@end
