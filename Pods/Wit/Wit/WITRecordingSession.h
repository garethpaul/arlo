//
//  WITRecordingSession.h
//  Wit
//
//  Created by Aric Lasry on 8/14/14.
//  Copyright (c) 2014 Willy Blandin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WITRecorder.h"
#import "WITUploader.h"
#import "WITVadTracker.h"
#import "WitPrivate.h"

@protocol WITRecordingSessionDelegate;

@interface WITRecordingSession : NSObject <WITRecorderDelegate, WITUploaderDelegate>

@property WITRecorder *recorder;
@property WITUploader *uploader;
@property id <WITRecordingSessionDelegate> delegate;
@property id customData;
@property NSString *witToken;
@property NSMutableDictionary *context;
@property BOOL isUploading;


-(id)initWithWitContext:(NSDictionary *)upContext vadEnabled:(WITVadConfig)vadEnabled withWitToken:(NSString *)witToken withDelegate:(id<WITRecordingSessionDelegate>)delegate;
-(BOOL)start;
-(void)stop;
-(BOOL)isRecording;
-(void)trackVad:(NSString *)messageId;

@end


@protocol WITRecordingSessionDelegate <NSObject>

-(void)recordingSessionActivityDetectorStarted:(WITRecordingSession *)session;
-(void)recordingSessionDidStartRecording:(WITRecordingSession *)session;
-(void)recordingSessionDidStopRecording:(WITRecordingSession *)session;
-(void)recordingSession:(WITRecordingSession *)session recorderGotChunk:(NSData*)chunk;
-(void)recordingSession:(WITRecordingSession *)session gotResponse:(NSDictionary*)resp customData:(id)customData error:(NSError*)err;

-(void)stop;

@end
