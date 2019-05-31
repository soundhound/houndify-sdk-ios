//
//  SHAudioDestinationProtocol.h
//  SoundHound
//
//  Created by Ben Levitt on 12/6/12.
//  Copyright (c) 2012 SoundHound. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef midomi_SHAudioDestinationProtocol_h
#define midomi_SHAudioDestinationProtocol_h


// Number of bytes needed for raw 16bit pcm of duration seconds at samplerate rate
#define RAW_FRAME_SIZE(rate, duration) ((UInt32)((rate) * (duration)) * sizeof(uint16_t))


@protocol SHAudioDestination;



@protocol SHAudioSource <NSObject>

@optional

// Allows a destination to tell its source that we need to cancel. (mostly used to cancel playback)
// The source should send no more calls to the destination after this.
- (void)audioDestinationDidCancel:(id<SHAudioDestination>)destination;

@end


// Audio Sources should retain their destinations, but not vice versa.

@protocol SHAudioDestination <NSObject>

// Set up all relevant properties on the receiver before calling audioSourceWillBeginSending:
// Wait until this method returns before first call to audioSource:availableBytes:length:
// When setting up chains of audioDestinations, you only need to call willBegin, availableBytes, didFinish,
// etc on the head of your chain.  That object will forward on relevant calls down the chain.
- (void)audioSourceWillBeginSending:(id<SHAudioSource>)source;

- (void)audioSource:(id<SHAudioSource>)source availableData:(NSData*)data;

// After calling audioSource:availableData for the last time, call audioSourceDidFinishSending:completionHandler:
// the completion handler fires once all processing is done.
// It is safe to release the audio chain from the completionHandler.
- (void)audioSourceDidFinishSending:(id<SHAudioSource>)source completionHandler:(void (^)(BOOL success))handler;

// Calling audioSourceDidCancel is similar to calling audioSourceDidFinishSending, but cancels all pending
// audio processing in the chain, so we can avoid finishing encoding and resampling, etc. if we don't need it.
// If you call audioSourceDidCancel:completionHandler:, you shouldn't also call didFinishSending:
- (void)audioSourceDidCancel:(id<SHAudioSource>)source completionHandler:(void (^)(void))handler;

- (void)audioSource:(id<SHAudioSource>)source runBlockWhenCaughtUp:(void (^)(void))handler;

@optional
// used to allow decoders to set their destination's input sample rate after decoding the file header
// this must be called on an object before audioSourceWillBeginSending: is called on it.
- (void)audioSource:(id<SHAudioSource>)source setInputSampleRate:(UInt32)rate;

- (void)audioSource:(id<SHAudioSource>)source availableData:(NSData*)data indexAtTail:(NSUInteger)indexAtTail;


@end


#endif
