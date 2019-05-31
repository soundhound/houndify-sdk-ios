//
//  SHSoundHoundDataModels.h
//  SHHound
//
//  Created by Cyril Austin on 9/11/15.
//  Copyright (c) 2015 SoundHound. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HoundDataModelsPrivate.h"

#pragma mark - Forward declarations

@class SHDataSoundHoundTrackNameGroup;
@class SHDataSoundHoundArtistNameGroup;
@class SHDataSoundHoundTrack;
@class SHDataSoundHoundArtist;
@class SHDataSoundHoundId;
@class SHDataSoundHoundLyricsDetail;
@class SHDataSoundHoundLyrics;
@class SHDataSoundHoundExternalLink;
@class SHDataSoundHoundAlignedLyrics;
@class SHDataSoundHoundLyric;
@class SHDataSoundHoundResyncToken;

#pragma mark - SHDataSoundHoundMelodis

@interface SHDataSoundHoundMelodis : HoundData

@property(nonatomic, copy) NSString* searchID;
@property(nonatomic, copy) NSString* contentType;
@property(nonatomic, copy) NSString* messageType;
@property(nonatomic, copy) NSString* messagePersistence;
@property(nonatomic, copy) NSString* messageInlineTitleTop;
@property(nonatomic, copy) NSString* messageInlineTextTop;
@property(nonatomic, copy) NSString* messageInlineMoreTipsAnchorTop;
@property(nonatomic, copy) NSString* messageInlineButtonsTop;
@property(nonatomic, assign) BOOL messageInlineTextAutoShowTop;
@property(nonatomic, copy) NSNumber* errorNo;
@property(nonatomic, strong) NSArray *messages;
@property(nonatomic, strong) NSArray<SHDataSoundHoundTrackNameGroup *>  *tracksGrouped;

@end

#pragma mark - SHDataSoundHoundTrackNameGroup

@interface SHDataSoundHoundTrackNameGroup : HoundData

@property(nonatomic, copy) NSString* trackName;
@property(nonatomic, strong) SHDataSoundHoundArtistNameGroup* artistNameGroup;

@end

#pragma mark - SHDataSoundHoundArtistNameGroup

@interface SHDataSoundHoundArtistNameGroup : HoundData

@property(nonatomic, copy) NSString* artistName;
@property(nonatomic, strong) NSArray<SHDataSoundHoundTrack *>* tracks;

@end

#pragma mark - SHDataSoundHoundTrack

@interface SHDataSoundHoundTrack : HoundData

@property(nonatomic, copy) NSString* trackID;
@property(nonatomic, copy) NSString* artistID;
@property(nonatomic, copy) NSString* albumID;
@property(nonatomic, copy) NSString* trackName;
@property(nonatomic, copy) NSString* artistName;
@property(nonatomic, copy) NSString* artistDisplayName;
@property(nonatomic, copy) NSString* albumName;
@property(nonatomic, copy) NSString* albumDate;
@property(nonatomic, copy) NSURL* albumPrimaryImage;
@property(nonatomic, copy) NSURL* audioPreviewUrl;
@property(nonatomic, copy) NSURL* videoUrl;
@property(nonatomic, copy) NSString* lyricsProvider;
@property(nonatomic, copy) NSString* lyricsLinkText;
@property(nonatomic, copy) NSURL* lyricsLinkUrl;
@property(nonatomic, copy) NSURL* lyricsUrl;
@property(nonatomic, copy) NSURL* purchaseUrl;
@property(nonatomic, assign) NSUInteger socialPostsCount;
@property(nonatomic, assign) BOOL socialPostsAvailable;
@property(nonatomic, assign) NSUInteger socialPostsLines;
@property(nonatomic, copy) NSString* spotifyID;
@property(nonatomic, copy) NSString* rdioID;
@property(nonatomic, copy) NSString* omrFingerprintID;
@property(nonatomic, copy) NSString* livelyricsID;
@property(nonatomic, assign) NSUInteger livelyricsOffsetMs;
@property(nonatomic, copy) NSString* livelyricsFingerprintID;

@property(nonatomic, strong) NSArray<SHDataSoundHoundArtist *> *artists;
@property(nonatomic, strong) NSArray<SHDataSoundHoundId *> *ids;
@property(nonatomic, strong) SHDataSoundHoundLyricsDetail* lyricsDetail;
@property(nonatomic, strong) NSArray<SHDataSoundHoundExternalLink *> * externalLinks;
@property(nonatomic, strong) SHDataSoundHoundAlignedLyrics* alignedLyrics;
@property(nonatomic, strong) SHDataSoundHoundResyncToken* resyncToken;

@end

#pragma mark - SHDataSoundHoundArtist

@interface SHDataSoundHoundArtist : HoundData

@property(nonatomic, copy) NSString* artistID;
@property(nonatomic, copy) NSString* artistName;
@property(nonatomic, copy) NSString* biography;
@property(nonatomic, assign) NSUInteger albumCount;
@property(nonatomic, copy) NSURL* artistPrimaryImage;
@property(nonatomic, assign) NSUInteger fansCount;
@property(nonatomic, assign) NSUInteger topSongCount;
@property(nonatomic, assign) NSUInteger similarArtistCount;
@property(nonatomic, assign) BOOL hasSocialChannels;
@property(nonatomic, assign) BOOL hasTwitterSocial;
@property(nonatomic, assign) BOOL hasFacebookSocial;
@property(nonatomic, copy) NSURL* purchaseUrl;
@property(nonatomic, copy) NSString* birthDate;
@property(nonatomic, copy) NSString* birthPlace;
@property(nonatomic, copy) NSString* deathDate;
@property(nonatomic, copy) NSString* deathPlace;
@property(nonatomic, copy) NSString* artistType;
@property(nonatomic, copy) NSURL* associatedMembersUrl;
@property(nonatomic, copy) NSURL* videoUrl;
@property(nonatomic, copy) NSURL* lyricsUrl;
@property(nonatomic, assign) NSUInteger popularityScore;

@property(nonatomic, strong) NSArray<SHDataSoundHoundExternalLink *>* externalLinks;

// other artistImages, styles

@end

#pragma mark - SHDataSoundHoundAlbum

@interface SHDataSoundHoundAlbum : HoundData

@property(nonatomic, copy) NSString* date;
@property(nonatomic, copy) NSString* albumID;
@property(nonatomic, copy) NSString* artistID;
@property(nonatomic, copy) NSString* albumName;
@property(nonatomic, copy) NSString* artistName;
@property(nonatomic, strong) NSURL* artistPrimaryImage;
@property(nonatomic, strong) NSURL* albumPrimaryImage;
@property(nonatomic, copy) NSString* review;
@property(nonatomic, copy) NSURL* lyricsUrl;

@property(nonatomic, strong) NSArray<SHDataSoundHoundTrack*> *tracks;
@property(nonatomic, strong) NSArray<SHDataSoundHoundExternalLink *>* externalLinks;

@end

#pragma mark - SHDataSoundHoundId

@interface SHDataSoundHoundId : HoundData

@property(nonatomic, copy) NSString* type;
@property(nonatomic, copy) NSString* id;
@property(nonatomic, copy) NSString* name;

@end

#pragma mark - SHDataSoundHoundLyricsDetail

@interface SHDataSoundHoundLyricsDetail : HoundData

@property(nonatomic, strong) SHDataSoundHoundAlignedLyrics* alignedLyrics;
@property(nonatomic, strong) SHDataSoundHoundLyrics* lyrics;

@end

#pragma mark - SHDataSoundHoundLyrics

@interface SHDataSoundHoundLyrics : HoundData

@end

#pragma mark - SHDataSoundHoundAlignedLyrics

@interface SHDataSoundHoundAlignedLyrics : HoundData

@property(nonatomic, copy) NSString* ref;
@property(nonatomic, copy) NSNumber* offset;
@property(nonatomic, copy) NSNumber* duration;
@property(nonatomic, copy) NSNumber* expiration;
@property(nonatomic, strong) NSArray<SHDataSoundHoundLyric *>* lyric;

@end

#pragma mark - SHDataSoundHoundLyric

@interface SHDataSoundHoundLyric : HoundData

@property(nonatomic, copy) NSString* type;
@property(nonatomic, copy) NSNumber* start;
@property(nonatomic, copy) NSString* text;

@end

#pragma mark - SHDataSoundHoundExternalLink

@interface SHDataSoundHoundExternalLink : HoundData

@property(nonatomic, copy) NSString* title;
@property(nonatomic, copy) NSString* altTitle;
@property(nonatomic, copy) NSString* subtitle;
@property(nonatomic, copy) NSString* altSubtitle;
@property(nonatomic, copy) NSURL* image;
@property(nonatomic, copy) NSURL* altImage;
@property(nonatomic, copy) NSURL* url;
@property(nonatomic, copy) NSURL* altUrl;
@property(nonatomic, copy) NSString* urlBrowser;
@property(nonatomic, copy) NSString* altUrlBrowser;
@property(nonatomic, assign) NSUInteger section;
@property(nonatomic, assign) NSUInteger itemCount;

@end

#pragma mark - SHDataSoundHoundBuyLink

@interface SHDataSoundHoundBuyLink : HoundData

@property(nonatomic, copy) NSString* status;
@property(nonatomic, copy) NSString* store;
@property(nonatomic, copy) NSString* storeName;
@property(nonatomic, strong) NSURL* url;
@property(nonatomic, copy) NSString* urlTitle;

@end

#pragma mark - SHDataSoundHoundResyncToken

@interface SHDataSoundHoundResyncToken : HoundData

@property(nonatomic, copy) NSString* value;

@end
