//
//  HoundSDKServerDataModels.h
//  SHHound
//
//  Created by Cyril MacDonald on 2015-06-05.
//  Copyright (c) 2015 SoundHound. All rights reserved.
//

#import "HoundDataModels.h"

#pragma mark - Forward declarations

@class HoundDataBuildInfo;
@class HoundDataCommandError;
@class HoundDataCommandResult;
@class HoundDataDynamicResponse;
@class HoundDataHTMLData;
@class HoundDataHTMLDataHTMLHead;
@class HoundDataHints;
@class HoundDataHintsSpoken;
@class HoundDataHintsWritten;
@class HoundDataHintsWrittenHints;
@class HoundDataHoundServer;
@class HoundDataHoundServerDisambiguation;
@class HoundDataHoundServerDisambiguationChoiceData;
@class HoundDataHoundServerDomainUsage;
@class HoundDataInformationCommand;
@class HoundDataInformationNuggetIntent;
@class HoundDataInformationNugget;
@class HoundDataPreview;
@class HoundDataTemplate;

#pragma mark - HoundDataCommandResultViewType

typedef NS_ENUM(NSUInteger, HoundDataCommandResultViewType) {
	HoundDataCommandResultViewTypeNone,
	HoundDataCommandResultViewTypeNative,
	HoundDataCommandResultViewTypeTemplate,
	HoundDataCommandResultViewTypeHTML,
	HoundDataCommandResultViewTypeError,
};

#pragma mark - HoundDataDynamicResponseViewType

typedef NS_ENUM(NSUInteger, HoundDataDynamicResponseViewType) {
	HoundDataDynamicResponseViewTypeNone,
	HoundDataDynamicResponseViewTypeNative,
	HoundDataDynamicResponseViewTypeTemplate,
	HoundDataDynamicResponseViewTypeHTML,
	HoundDataDynamicResponseViewTypeError,
};

#pragma mark - HoundDataEmotion

/**
	The specification of an emotion for a client to display
*/
typedef NS_ENUM(NSUInteger, HoundDataEmotion) {
	HoundDataEmotionNone,
	HoundDataEmotionNeutral,
	HoundDataEmotionHappy,
	HoundDataEmotionSad,
	HoundDataEmotionAngry,
};

#pragma mark - HoundDataHintsSpokenPriority

typedef NS_ENUM(NSUInteger, HoundDataHintsSpokenPriority) {
	HoundDataHintsSpokenPriorityNone,
	HoundDataHintsSpokenPriorityLow,
	HoundDataHintsSpokenPriorityMedium,
	HoundDataHintsSpokenPriorityHigh,
};

#pragma mark - HoundDataHintsWrittenHintsPriority

typedef NS_ENUM(NSUInteger, HoundDataHintsWrittenHintsPriority) {
	HoundDataHintsWrittenHintsPriorityNone,
	HoundDataHintsWrittenHintsPriorityLow,
	HoundDataHintsWrittenHintsPriorityMedium,
	HoundDataHintsWrittenHintsPriorityHigh,
};

#pragma mark - HoundDataHoundServerFormat

typedef NS_ENUM(NSUInteger, HoundDataHoundServerFormat) {
	HoundDataHoundServerFormatNone,
	HoundDataHoundServerFormatSoundHoundVoiceSearchResult,
	HoundDataHoundServerFormatHoundQueryResult,
};

#pragma mark - HoundDataHoundServerFormatVersion

typedef NS_ENUM(NSUInteger, HoundDataHoundServerFormatVersion) {
	HoundDataHoundServerFormatVersionNone,
	HoundDataHoundServerFormatVersion10,
};

#pragma mark - HoundDataHoundServerStatus

typedef NS_ENUM(NSUInteger, HoundDataHoundServerStatus) {
	HoundDataHoundServerStatusNone,
	HoundDataHoundServerStatusOK,
	HoundDataHoundServerStatusError,
};

#pragma mark - HoundDataHoundServerLocalOrRemote

typedef NS_ENUM(NSUInteger, HoundDataHoundServerLocalOrRemote) {
	HoundDataHoundServerLocalOrRemoteNone,
	HoundDataHoundServerLocalOrRemoteLocal,
	HoundDataHoundServerLocalOrRemoteRemote,
};

#pragma mark - HoundDataIcon

/**
	The specification of an icon for a client to display
*/
typedef NS_ENUM(NSUInteger, HoundDataIcon) {
	HoundDataIconNone,
	HoundDataIconNeutral,
	HoundDataIconHappy,
	HoundDataIconSad,
	HoundDataIconAngry,
	HoundDataIconCoffee,
};

NS_ASSUME_NONNULL_BEGIN

#pragma mark - HoundDataBuildInfo

/**
	Information about the server that produced a result
*/
@interface HoundDataBuildInfo : HoundData

@property(nonatomic, copy, nullable) NSString* user;
@property(nonatomic, copy, nullable) NSDate* date;
@property(nonatomic, copy, nullable) NSString* machine;
@property(nonatomic, copy, nullable) NSString* SVNRevision;
@property(nonatomic, copy, nullable) NSString* SVNBranch;
@property(nonatomic, copy, nullable) NSString* buildNumber;
@property(nonatomic, copy, nullable) NSString* kind;
@property(nonatomic, copy, nullable) NSString* variant;

@end

#pragma mark - HoundDataCommandError

/**
	An error in processing a request
*/
@interface HoundDataCommandError : HoundData

@property(nonatomic, copy) NSString* errorMessage;
@property(nonatomic, copy, nullable) NSString* expectedCommandKind;
@property(nonatomic, copy) NSString* errorType;

@end

#pragma mark - HoundDataCommandResult

/**
	The results from the server to a particular parse of a request
*/
@interface HoundDataCommandResult : HoundData

@property(nonatomic, copy) NSString* spokenResponse;
@property(nonatomic, copy) NSString* spokenResponseLong;
@property(nonatomic, copy) NSString* writtenResponse;
@property(nonatomic, copy) NSString* writtenResponseLong;
@property(nonatomic, copy, nullable) NSString* spokenResponseSSML;
@property(nonatomic, copy, nullable) NSString* spokenResponseSSMLLong;
@property(nonatomic, assign) BOOL autoListen;
@property(nonatomic, copy, nullable) NSString* userVisibleMode;
@property(nonatomic, assign) BOOL isRepeat;
@property(nonatomic, strong, nullable) NSArray<HoundDataInformationNugget*>* additionalInformation;
@property(nonatomic, strong, nullable) NSDictionary* conversationState;
@property(nonatomic, strong) NSArray<NSNumber*>* viewType;
@property(nonatomic, copy, nullable) NSString* templateName;
@property(nonatomic, strong, nullable) HoundDataTemplate* templateData;
@property(nonatomic, strong, nullable) HoundDataTemplate* combiningTemplateData;
@property(nonatomic, strong, nullable) HoundDataPreview* preview;
@property(nonatomic, strong, nullable) HoundDataHTMLData* HTMLData;
@property(nonatomic, strong, nullable) HoundDataHints* hints;
@property(nonatomic, assign) HoundDataEmotion emotion;
@property(nonatomic, assign) HoundDataIcon icon;
@property(nonatomic, copy, nullable) NSString* responseAudioBytes;
@property(nonatomic, copy, nullable) NSString* responseAudioEncoding;
@property(nonatomic, copy, nullable) NSString* responseAudioError;
@property(nonatomic, strong, nullable) NSArray<NSString*>* outputOverrideDiagnostics;
@property(nonatomic, strong, nullable) NSArray<NSString*>* uploadedTerrierDiagnostics;
@property(nonatomic, strong, nullable) NSArray<NSString*>* requiredFeatures;
@property(nonatomic, strong, nullable) HoundDataDynamicResponse* clientActionSucceededResult;
@property(nonatomic, strong, nullable) HoundDataDynamicResponse* clientActionFailedResult;
@property(nonatomic, strong, nullable) HoundDataDynamicResponse* requiredFeaturesSupportedResult;
@property(nonatomic, strong, nullable) id sendBack;
@property(nonatomic, assign) double understandingConfidence;
@property(nonatomic, copy, nullable) NSString* errorType;
@property(nonatomic, strong, nullable) HoundDataCommandError* errorData;
@property(nonatomic, copy) NSString* commandKind;
@property(nonatomic, strong, nullable) NSDictionary* userInfo;

@end

#pragma mark - HoundDataDynamicResponse

/**
	Action result-specific results from the server
*/
@interface HoundDataDynamicResponse : HoundData

@property(nonatomic, copy) NSString* spokenResponse;
@property(nonatomic, copy) NSString* spokenResponseLong;
@property(nonatomic, copy) NSString* writtenResponse;
@property(nonatomic, copy) NSString* writtenResponseLong;
@property(nonatomic, assign) BOOL autoListen;
@property(nonatomic, copy, nullable) NSString* userVisibleMode;
@property(nonatomic, strong, nullable) NSDictionary* conversationState;
@property(nonatomic, assign) NSUInteger conversationStateTime;
@property(nonatomic, strong, nullable) NSArray<NSNumber*>* viewType;
@property(nonatomic, copy, nullable) NSString* templateName;
@property(nonatomic, strong, nullable) HoundDataTemplate* templateData;
@property(nonatomic, copy, nullable) NSString* smallScreenHTML;
@property(nonatomic, copy, nullable) NSString* largeScreenHTML;
@property(nonatomic, strong, nullable) HoundDataHints* hints;
@property(nonatomic, assign) HoundDataEmotion emotion;
@property(nonatomic, assign) HoundDataIcon icon;

@end

#pragma mark - HoundDataHTMLData

/**
	HTML to be displayed by the client
*/
@interface HoundDataHTMLData : HoundData

@property(nonatomic, strong) HoundDataHTMLDataHTMLHead* HTMLHead;
@property(nonatomic, copy, nullable) NSString* smallScreenHTML;
@property(nonatomic, copy, nullable) NSString* largeScreenHTML;
@property(nonatomic, copy, nullable) NSURL* smallScreenURL;
@property(nonatomic, copy, nullable) NSURL* largeScreenURL;

@end

#pragma mark - HoundDataHTMLDataHTMLHead

@interface HoundDataHTMLDataHTMLHead : HoundData

@property(nonatomic, copy) NSString* CSS;
@property(nonatomic, copy) NSString* JS;

@end

#pragma mark - HoundDataHints

/**
	Hints to the user
*/
@interface HoundDataHints : HoundData

@property(nonatomic, strong, nullable) HoundDataHintsSpoken* spoken;
@property(nonatomic, strong, nullable) HoundDataHintsWritten* written;

@end

#pragma mark - HoundDataHintsSpoken

@interface HoundDataHintsSpoken : HoundData

@property(nonatomic, copy) NSString* text;
@property(nonatomic, assign) HoundDataHintsSpokenPriority priority;

@end

#pragma mark - HoundDataHintsWritten

@interface HoundDataHintsWritten : HoundData

@property(nonatomic, strong) NSArray<HoundDataHintsWrittenHints*>* hints;

@end

#pragma mark - HoundDataHintsWrittenHints

@interface HoundDataHintsWrittenHints : HoundData

@property(nonatomic, copy) NSString* text;
@property(nonatomic, assign) HoundDataHintsWrittenHintsPriority priority;

@end

#pragma mark - HoundDataHoundServer

/**
	The JSON returned by the SoundHound Hound servers
*/
@interface HoundDataHoundServer : HoundData

@property(nonatomic, assign) HoundDataHoundServerFormat format;
@property(nonatomic, assign) HoundDataHoundServerFormatVersion formatVersion;
@property(nonatomic, assign) HoundDataHoundServerStatus status;
@property(nonatomic, copy, nullable) NSString* errorMessage;
@property(nonatomic, assign) NSUInteger numToReturn;
@property(nonatomic, strong, nullable) NSArray<HoundDataCommandResult*>* allResults;
@property(nonatomic, strong, nullable) HoundDataHoundServerDisambiguation* disambiguation;
@property(nonatomic, strong, nullable) NSArray<NSNumber*>* resultsAreFinal;
@property(nonatomic, strong) NSArray<HoundDataHoundServerDomainUsage*>* domainUsage;
@property(nonatomic, strong, nullable) HoundDataBuildInfo* buildInfo;
@property(nonatomic, copy) NSString* queryID;
@property(nonatomic, copy, nullable) NSString* serverGeneratedId;
@property(nonatomic, assign) double audioLength;
@property(nonatomic, assign) double realSpeechTime;
@property(nonatomic, assign) double cpuSpeechTime;
@property(nonatomic, assign) double realTime;
@property(nonatomic, assign) double cpuTime;
@property(nonatomic, assign) HoundDataHoundServerLocalOrRemote localOrRemote;
@property(nonatomic, copy, nullable) NSString* localOrRemoteReason;

@end

#pragma mark - HoundDataHoundServerDisambiguation

@interface HoundDataHoundServerDisambiguation : HoundData

@property(nonatomic, assign) NSUInteger numToShow;
@property(nonatomic, strong) NSArray<HoundDataHoundServerDisambiguationChoiceData*>* choiceData;

@end

#pragma mark - HoundDataHoundServerDisambiguationChoiceData

@interface HoundDataHoundServerDisambiguationChoiceData : HoundData

@property(nonatomic, copy) NSString* transcription;
@property(nonatomic, assign) double confidenceScore;
@property(nonatomic, copy) NSString* formattedTranscription;
@property(nonatomic, copy, nullable) NSString* fixedTranscription;

@end

#pragma mark - HoundDataHoundServerDomainUsage

@interface HoundDataHoundServerDomainUsage : HoundData

@property(nonatomic, copy) NSString* domain;
@property(nonatomic, copy) NSString* domainUniqueID;
@property(nonatomic, assign) double creditsUsed;

@end

#pragma mark - HoundDataInformationNuggetIntent

/**
	The intent of a particular parse of a request for information
*/
@interface HoundDataInformationNuggetIntent : HoundData

@property(nonatomic, copy) NSString* nuggetIntentKind;

@end

#pragma mark - HoundDataInformationNugget

/**
	A chunk of information in response to a user query
*/
@interface HoundDataInformationNugget : HoundData

@property(nonatomic, copy) NSString* spokenResponse;
@property(nonatomic, copy) NSString* spokenResponseLong;
@property(nonatomic, copy) NSString* writtenResponse;
@property(nonatomic, copy) NSString* writtenResponseLong;
@property(nonatomic, copy, nullable) NSString* spokenResponseSSML;
@property(nonatomic, copy, nullable) NSString* spokenResponseSSMLLong;
@property(nonatomic, strong, nullable) HoundDataTemplate* templateData;
@property(nonatomic, strong, nullable) HoundDataTemplate* combiningTemplateData;
@property(nonatomic, strong, nullable) HoundDataPreview* preview;
@property(nonatomic, copy, nullable) NSString* smallScreenHTML;
@property(nonatomic, copy, nullable) NSString* largeScreenHTML;
@property(nonatomic, strong, nullable) HoundDataHints* hints;
@property(nonatomic, assign) HoundDataEmotion emotion;
@property(nonatomic, assign) HoundDataIcon icon;
@property(nonatomic, assign) double understandingConfidence;
@property(nonatomic, strong, nullable) NSArray<NSString*>* outputOverrideDiagnostics;
@property(nonatomic, copy) NSString* nuggetKind;

@end

#pragma mark - HoundDataPreview

/**
	The data to specify how to display query results as a preview
*/
@interface HoundDataPreview : HoundData


@end

#pragma mark - HoundDataTemplate

/**
	The data to specify how to display results using one of a pre-defined number of display format templates
*/
@interface HoundDataTemplate : HoundData

@property(nonatomic, copy) NSString* templateName;

@end

#pragma mark - HoundDataInformationCommand

/**
	The results from the server to a request where the result is one or more pieces of information, not requiring any client action
*/
@interface HoundDataInformationCommand : HoundDataCommandResult

@property(nonatomic, strong) NSArray<HoundDataInformationNugget*>* informationNuggets;

@end

NS_ASSUME_NONNULL_END
