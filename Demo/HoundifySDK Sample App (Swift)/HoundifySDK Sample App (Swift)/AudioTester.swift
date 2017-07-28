//
//  AudioTester.swift
//  HoundSDK Swift Test Application
//
//  Created by Ken Huang on 11/25/16.
//  Copyright © 2016 SoundHound. All rights reserved.
//

import Foundation
import AVFoundation
import AudioUnit

enum AudioTesterError:Int {
	case none
	case permissionDenied
}

typealias AudioTesterDataHandler = (NSError?, Data?)->Void
typealias AudioTesterErrorHandler = (NSError?)->Void
typealias AudioTesterPermissionCallback = (Bool)->Void

let AudioTesterErrorDomain = "AudioTesterErrorDomain"

let INPUT_BUS:UInt32 = 1
let OUTPUT_BUS:UInt32 = 0

class AudioTester {

	static let instance:AudioTester = AudioTester()
	
	fileprivate var _audioUnit: AudioUnit? = nil
	fileprivate var _queue: DispatchQueue
	fileprivate var _session: AVAudioSession {
		get {
			return AVAudioSession.sharedInstance()
		}
	}
	
	fileprivate var _handler: AudioTesterDataHandler?
	
	fileprivate var streamDescription: AudioStreamBasicDescription {
		get {
			var audioStreamDescription: AudioStreamBasicDescription = AudioStreamBasicDescription()
			audioStreamDescription.mFormatID = kAudioFormatLinearPCM
			audioStreamDescription.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked
			audioStreamDescription.mFramesPerPacket = 1
			audioStreamDescription.mChannelsPerFrame = 1
			audioStreamDescription.mBitsPerChannel = 16
			audioStreamDescription.mBytesPerPacket = 2
			audioStreamDescription.mBytesPerFrame = 2
			audioStreamDescription.mSampleRate = self._session.sampleRate
			
			return audioStreamDescription
		}
	}
	
	init() {
		self._queue = DispatchQueue(label: "com.hound.audio", attributes: [])
	}
	
	func startAudioWithSampleRate(_ sampleRate:Double, handler: AudioTesterDataHandler?) {
		self.stopAudioWithHandler{ error in
			guard error == nil else {
				handler?(error, nil)
				return
			}
			
			self._queue.async {
				self._handler = handler
				self.requestPermissions { granted in
					
					guard granted else {
						handler?(self.error(.permissionDenied), nil)
						return
					}
					do {
						try self._session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
						try self._session.setPreferredSampleRate(sampleRate)
						try self._session.setActive(true)
						
						var status: OSStatus = kAudioServicesNoError
						
						var audioComponentDescription: AudioComponentDescription = AudioComponentDescription()
						audioComponentDescription.componentType = kAudioUnitType_Output
						audioComponentDescription.componentSubType = kAudioUnitSubType_RemoteIO
						audioComponentDescription.componentManufacturer = kAudioUnitManufacturer_Apple
						audioComponentDescription.componentFlags = 0
						audioComponentDescription.componentFlagsMask = 0
						let audioComponent: AudioComponent? = AudioComponentFindNext(nil, &audioComponentDescription)
						
						guard audioComponent != nil else {
							handler?(self.error(kAudioServicesUnsupportedPropertyError),nil)
							return
						}
						
						status = AudioComponentInstanceNew(audioComponent!, &self._audioUnit)
						
						if status == kAudioServicesNoError {
							var yes: UInt32 = 1
							
							status = AudioUnitSetProperty(self._audioUnit!, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, INPUT_BUS, &yes, UInt32(MemoryLayout.size(ofValue: yes)))
						}
						
						var streamDescription: AudioStreamBasicDescription = self.streamDescription
						
						if (status == kAudioServicesNoError) {
							status = AudioUnitSetProperty(self._audioUnit!, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, INPUT_BUS, &streamDescription, UInt32(MemoryLayout.size(ofValue: streamDescription)))
						}
						
						if (status == kAudioServicesNoError) {
							status = AudioUnitSetProperty(self._audioUnit!, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, OUTPUT_BUS, &streamDescription, UInt32(MemoryLayout.size(ofValue: streamDescription)))
						}
						
						if (status == kAudioServicesNoError) {
							var renderCallbackStruct = AURenderCallbackStruct(inputProc: audioTesterRenderCallback, inputProcRefCon: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()))
							status = AudioUnitSetProperty(self._audioUnit!, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Global, OUTPUT_BUS, &renderCallbackStruct, UInt32(MemoryLayout.size(ofValue: renderCallbackStruct)))
						}
						
						if (status == kAudioServicesNoError) {
							status = AudioUnitInitialize(self._audioUnit!)
						}
						
						if (status == kAudioServicesNoError) {
							status = AudioOutputUnitStart(self._audioUnit!)
						}
						
						if let error = self.error(status) {
							handler?(error, nil)
						}
						
					} catch let error {
						handler?(error as NSError, nil)
					}
				}
			}
		}
	}
	
	func stopAudioWithHandler(_ handler: AudioTesterErrorHandler?) {
		_queue.async {
			var error: NSError?
			guard self._audioUnit != nil else {
				handler?(error)
				return
			}
			
			var status:OSStatus
			status = AudioOutputUnitStop(self._audioUnit!)
			error = self.error(status)
			
			status = AudioUnitUninitialize(self._audioUnit!)
			
			error = error ?? self.error(status)
			
			status = AudioComponentInstanceDispose(self._audioUnit!)
			
			error = error ?? self.error(status)
			
			self._audioUnit = nil
			
			handler?(error)
		}
	}
	
	func render(_ actionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
		timeStamp: UnsafePointer<AudioTimeStamp>,
		busNumber:UInt32,
		frameCount:UInt32,
		bufferList: UnsafeMutablePointer<AudioBufferList>?) -> OSStatus {
		
		var status = kAudioServicesNoError
		if bufferList == nil {
			status = kAudioServicesUnsupportedPropertyError
		} else {
			status = AudioUnitRender(self._audioUnit!, actionFlags, timeStamp, INPUT_BUS, frameCount, bufferList!)
			
			if status == kAudioServicesNoError {
				
				if (bufferList?.pointee.mNumberBuffers)! > 0 {
					let buffers = UnsafeMutableAudioBufferListPointer(bufferList)
					let buffer = buffers?.first!.mData
					let length = MemoryLayout<Int16>.size * Int(frameCount)
					
					let data = Data(bytes: buffer!, count: length)
					
					self._handler?(nil, data)
				}
			}
		}
		
		actionFlags.pointee = [actionFlags.pointee, AudioUnitRenderActionFlags.unitRenderAction_OutputIsSilence]
		
		let error = self.error(status)
		
		if error != nil {
			self._handler?(error, nil)
		}
		
		return status
	}
	
	fileprivate func error(_ status:OSStatus)->NSError? {
		var error: NSError?
		
		if (status != kAudioServicesNoError) {
			error = NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil)
		}
		
		return error
	}
	
	fileprivate func error(_ code: AudioTesterError) -> NSError? {
		return NSError(domain: AudioTesterErrorDomain, code: code.rawValue, userInfo: nil)
	}
	
	fileprivate func requestPermissions(_ completionHandler: @escaping AudioTesterPermissionCallback) {
		var permission: AVAudioSessionRecordPermission = .undetermined
		permission = self._session.recordPermission()
		
		switch (permission) {
        case AVAudioSessionRecordPermission.denied:
    		completionHandler(false)
    	case AVAudioSessionRecordPermission.granted:
    		completionHandler(true)
        default:
            self._session.requestRecordPermission(completionHandler)
    	}
	}
}

func audioTesterRenderCallback(_ context:UnsafeMutableRawPointer, actionFlags:UnsafeMutablePointer<AudioUnitRenderActionFlags>, timeStamp:UnsafePointer<AudioTimeStamp>, busNumber:UInt32, frameCount:UInt32, bufferList: UnsafeMutablePointer<AudioBufferList>?) -> OSStatus
{
	let audioTester = unsafeBitCast(context, to: AudioTester.self)
	return audioTester.render(actionFlags, timeStamp: timeStamp, busNumber: busNumber, frameCount: frameCount, bufferList: bufferList)
}
