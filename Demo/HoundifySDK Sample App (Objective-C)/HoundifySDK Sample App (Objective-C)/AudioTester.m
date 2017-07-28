//
//  AudioTester.m
//  HoundSDK Test Application
//
//  Created by Cyril Austin on 6/2/15.
//  Copyright (c) 2015 SoundHound, Inc. All rights reserved.
//

#import "AudioTester.h"

#define OUTPUT_BUS                              0
#define INPUT_BUS                               1

@import AVFoundation;

#pragma mark - Callbacks

typedef void (^AudioTesterPermissionCallback)(BOOL granted);

#pragma mark - Errors

NSString* AudioTesterErrorDomain = @"AudioTesterErrorDomain";

#pragma mark - AudioTester

@interface AudioTester()

@property(nonatomic, strong) dispatch_queue_t queue;
@property(nonatomic, assign) AudioUnit audioUnit;

@property(nonatomic, copy) AudioTesterDataHandler handler;

@end

@implementation AudioTester

+ (instancetype)instance
{
    static AudioTester* instance = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
    
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        self.queue = dispatch_queue_create("com.hound.audio", NULL);
    }
    
    return self;
}

- (void)startAudioWithSampleRate:(double)sampleRate dataHandler:(AudioTesterDataHandler)handler
{
    [self stopAudioWithHandler:^(NSError* error) {
    
        if (error)
        {
            if (handler) handler(error, nil);
        }
        else
        {
            dispatch_async(self.queue, ^{
            
                self.handler = handler;
            
                [self requestPermissionsWithCompletionHandler:^(BOOL granted) {
                    
                    dispatch_async(self.queue, ^{
                
                        NSError* error = nil;
                        
                        if (!granted)
                        {
                            error = [self errorWithCode:AudioTesterErrorCodePermissionDenied];
                        }
                        
                        if (!error)
                        {
                            [self.session setCategory:AVAudioSessionCategoryPlayAndRecord
                                withOptions:AVAudioSessionCategoryOptionAllowBluetooth
                                error:&error];
                        }
                        
                        if (error)
                        {
                            if (handler) handler(error, nil);
                        }
                        else
                        {
                            [self.session setMode:AVAudioSessionModeDefault error:&error];

                            if (!error)
                            {
                                [self.session setPreferredSampleRate:sampleRate error:&error];
                            }
                            
                            if (!error)
                            {
                                [self.session setActive:YES error:&error];
                            }
                            
                            if (error)
                            {
                                if (handler) handler(error, nil);
                            }
                            else
                            {
                                OSStatus status = kAudioServicesNoError;
                                
                                AudioComponentDescription audioComponentDescription;

                                audioComponentDescription.componentType = kAudioUnitType_Output;
                                audioComponentDescription.componentSubType = kAudioUnitSubType_RemoteIO;
                                audioComponentDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
                                audioComponentDescription.componentFlags = 0;
                                audioComponentDescription.componentFlagsMask = 0;
                                
                                AudioComponent audioComponent = AudioComponentFindNext(NULL, &audioComponentDescription);
                                
                                if (!audioComponent)
                                {
                                    status = kAudioServicesUnsupportedPropertyError;
                                }
                                else
                                {
                                    status = AudioComponentInstanceNew(audioComponent, &_audioUnit);
                                    
                                    if (status == kAudioServicesNoError)
                                    {
                                        UInt32 yes = YES;
                                    
                                        if (status == kAudioServicesNoError)
                                        {
                                            status = AudioUnitSetProperty(
                                                self.audioUnit,
                                                kAudioOutputUnitProperty_EnableIO,
                                                kAudioUnitScope_Input,
                                                INPUT_BUS,
                                                &yes,
                                                sizeof(yes));
                                        }

                                        AudioStreamBasicDescription streamDescription = self.streamDescription;
                                        
                                        if (status == kAudioServicesNoError)
                                        {
                                            status = AudioUnitSetProperty(
                                                self.audioUnit,
                                                kAudioUnitProperty_StreamFormat,
                                                kAudioUnitScope_Output,
                                                INPUT_BUS,
                                                &streamDescription,
                                                sizeof(streamDescription));
                                        }

                                        if (status == kAudioServicesNoError)
                                        {
                                            status = AudioUnitSetProperty(
                                                self.audioUnit,
                                                kAudioUnitProperty_StreamFormat,
                                                kAudioUnitScope_Input,
                                                OUTPUT_BUS,
                                                &streamDescription,
                                                sizeof(streamDescription));
                                        }
                                        
                                        AURenderCallbackStruct renderCallbackStruct;
                                        renderCallbackStruct.inputProc = audioTesterRenderCallback;
                                        renderCallbackStruct.inputProcRefCon = (__bridge void*)self;
                                        
                                        if (status == kAudioServicesNoError)
                                        {
                                            status = AudioUnitSetProperty(
                                                self.audioUnit,
                                                kAudioUnitProperty_SetRenderCallback,
                                                kAudioUnitScope_Global,
                                                OUTPUT_BUS,
                                                &renderCallbackStruct,
                                                sizeof(renderCallbackStruct));
                                        }
                                        
                                        if (status == kAudioServicesNoError)
                                        {
                                            status = AudioUnitInitialize(self.audioUnit);
                                        }
                                        
                                        if (status == kAudioServicesNoError)
                                        {
                                            status = AudioOutputUnitStart(self.audioUnit);
                                        }
                                    }
                                }
                                
                                NSError* error = [self errorWithOSStatus:status];
                                
                                if (error)
                                {
                                    if (handler) handler(error, nil);
                                }
                            }
                        }
                    });
                }];
            });
        }
    }];
}

- (void)stopAudioWithHandler:(AudioTesterErrorHandler)handler
{
    dispatch_async(self.queue, ^{
        
        NSError* error = nil;
        
        if (self.audioUnit)
        {
            OSStatus status;
            
            status = AudioOutputUnitStop(self.audioUnit);
            
            if (!error)
            {
                error = [self errorWithOSStatus:status];
            }
        
            status = AudioUnitUninitialize(self.audioUnit);
                
            if (!error)
            {
                error = [self errorWithOSStatus:status];
            }
            
            status = AudioComponentInstanceDispose(self.audioUnit);
            
            if (!error)
            {
                error = [self errorWithOSStatus:status];
            }
            
            self.audioUnit = NULL;

            [self.session setActive:NO error:&error];
        }
        
        if (handler) handler(error);
    });
}

#pragma mark - Audio Processing

OSStatus audioTesterRenderCallback(void* context, AudioUnitRenderActionFlags* actionFlags,
    const AudioTimeStamp* timestamp, UInt32 busNumber, UInt32 frameCount,
    AudioBufferList* bufferList)
{
	AudioTester* self = (__bridge AudioTester*)context;
    
    return [self render:actionFlags timestamp:timestamp
        busNumber:busNumber frameCount:frameCount bufferList:bufferList];
}

- (OSStatus)render:(AudioUnitRenderActionFlags*)actionFlags
    timestamp:(const AudioTimeStamp*)timestamp
	busNumber:(UInt32)busNumber
    frameCount:(UInt32)frameCount
    bufferList:(AudioBufferList*)bufferList
{
    OSStatus status = kAudioServicesNoError;
    
    if (!bufferList)
    {
        status = kAudioServicesUnsupportedPropertyError;
    }
    else
    {
        status = AudioUnitRender(self.audioUnit, actionFlags, timestamp,
            INPUT_BUS, frameCount, bufferList);
        
        if (status == kAudioServicesNoError)
        {
            if (bufferList->mNumberBuffers > 0)
            {
                SInt16* buffer = bufferList->mBuffers[0].mData;
                NSUInteger length = sizeof(SInt16) * frameCount;
                
                NSData* data = [NSData dataWithBytes:buffer length:length];
                
                if (self.handler) self.handler(nil, data);
            }
        }
    }

    *actionFlags |= kAudioUnitRenderAction_OutputIsSilence;

    NSError* error = [self errorWithOSStatus:status];

    if (error)
    {
        if (self.handler) self.handler(error, nil);
    }
    
	return status;
}

#pragma mark - Utility

- (AVAudioSession*)session
{
    return AVAudioSession.sharedInstance;
}

- (NSError*)errorWithCode:(AudioTesterErrorCode)errorCode
{
    NSError* error = [NSError errorWithDomain:AudioTesterErrorDomain
        code:errorCode userInfo:nil];
    
    return error;
}

- (NSError*)errorWithOSStatus:(OSStatus)status
{
    NSError* error = nil;

    if (status != kAudioServicesNoError)
    {
        error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
    }
    
    return error;
}

- (AudioStreamBasicDescription)streamDescription
{
    AudioStreamBasicDescription streamDescription;
    
    streamDescription.mFormatID = kAudioFormatLinearPCM;
    streamDescription.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    streamDescription.mFramesPerPacket = 1;
    streamDescription.mChannelsPerFrame = 1;
    streamDescription.mBitsPerChannel = 16;
    streamDescription.mBytesPerPacket = 2;
    streamDescription.mBytesPerFrame = 2;
    streamDescription.mSampleRate = [[AVAudioSession sharedInstance] sampleRate];
    
    return streamDescription;
}

- (void)requestPermissionsWithCompletionHandler:(AudioTesterPermissionCallback)handler
{
    AVAudioSessionRecordPermission permission = AVAudioSessionRecordPermissionUndetermined;
    
    if ([self.session respondsToSelector:@selector(recordPermission)])
    {
        permission = [self.session recordPermission];
    }
    
    if (permission == AVAudioSessionRecordPermissionDenied)
    {
        if (handler) handler(NO);
    }
    else if (permission == AVAudioSessionRecordPermissionGranted)
    {
        if (handler) handler(YES);
    }
    else
    {
        [self.session requestRecordPermission:handler];
    }
}

@end
