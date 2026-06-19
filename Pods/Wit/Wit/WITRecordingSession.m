//
//  WITRecordingSession.m
//  Wit
//
//  Created by Aric Lasry on 8/14/14.
//  Copyright (c) 2014 Willy Blandin. All rights reserved.
//

#import "WITRecordingSession.h"
#import "WITVadConfig.h"
#import "WITContextSetter.h"
#import "WITHTTPPolicy.h"
#import <AVFoundation/AVFoundation.h>

@interface WITRecordingSession ()

@property WITVadConfig vadEnabled;
@property NSMutableArray *dataBuffer;
@property int buffersToSave;
@property BOOL stopped;
@end

@implementation WITRecordingSession {
WITContextSetter *wcs;
}

-(id)initWithWitContext:(NSMutableDictionary *)upContext vadEnabled:(WITVadConfig)vadEnabled withWitToken:(NSString *)witToken withDelegate:(id<WITRecordingSessionDelegate>)delegate {
    self = [super init];
    if (self) {
        if (!WITIsValidAccessToken(witToken)) {
            return nil;
        }

        self.delegate = delegate;
        self.dataBuffer = [[NSMutableArray alloc] init];
        self.vadEnabled = vadEnabled;
        self.uploader = [[WITUploader alloc] init];
        self.uploader.delegate = self;
        self.isUploading = false;
        self.context = upContext;
        self.recorder = [[WITRecorder alloc] init];
        self.recorder.delegate = self;
        self.witToken = witToken;
        self.stopped = NO;
        self.buffersToSave = 25; //hardcode for now
    }
    
    return self;
}

-(BOOL)start
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *audioError = nil;
    if (![audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&audioError] ||
        ![audioSession setActive:YES error:&audioError]) {
        return NO;
    }

    [self.recorder start];
    if (self.vadEnabled == WITVadConfigDisabled) {
        return [self startUploader];
    }

    [self.recorder enabledVad];
    if (self.vadEnabled == WITVadConfigDetectSpeechStop) {
        return [self startUploader];
    }
    return YES;
}

-(BOOL)startUploader
{
    [[Wit sharedInstance].wcs contextFillup:self.context];
    if (![self.uploader startRequestWithContext:self.context]) {
        [[AVAudioSession sharedInstance] setActive:NO
                                       withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation
                                             error:nil];
        return NO;
    }
    self.isUploading = true;
    [self.delegate recordingSessionDidStartRecording:self];
    return YES;
}

-(void)stop
{
        if (self.stopped) {
            return;
        }
        self.stopped = YES;
        [self.recorder stop];
        [self.uploader endRequest];
        self.isUploading = false;
        NSError *audioError = nil;
        [[AVAudioSession sharedInstance] setActive:NO
                                       withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation
                                             error:&audioError];
        if (audioError) {
            debug(@"Unable to deactivate Wit audio session");
        }
        [self.delegate recordingSessionDidStopRecording:self];

}

- (BOOL)isRecording {
    return [self.recorder isRecording];
}

-(void)gotResponse:(NSDictionary*)resp error:(NSError*)err {
    if (err) {
        NSLog(@"Wit stopped recording because of a network error");
        [self stop];
    }

    [self.delegate recordingSession:self gotResponse:resp customData:self.customData error:err];

    if (!err && resp[kWitKeyMsgId]) {
        [self trackVad:resp[kWitKeyMsgId]];
    }
    [self clean];
}

-(void)trackVad:(NSString *)messageId {
    if (self.vadEnabled && ![self.recorder stoppedUsingVad]) {
        NSLog(@"Tracking vad failure");
        int vadSensitivity = [Wit sharedInstance].vadSensitivity;
        [[[WITVadTracker alloc] init] track:@"vadFailed" withMessageId:messageId withVadSensitivity:vadSensitivity withToken:self.witToken];
    }
}


#pragma mark - WITRecorderDelegate implementation

-(void)recorderGotChunk:(NSData*)chunk {
    dispatch_async(dispatch_get_main_queue(), ^{
    if(self.isUploading) {
        [self.uploader sendChunk:chunk];
    } else {
        //not uploading, so save the chunk to the buffer and remove old chunk
        if ([self.dataBuffer count] >= self.buffersToSave){
            //if we have enough entries, remove the oldest one
            [self.dataBuffer removeObjectAtIndex:0];
        }
        //enqueue the new data
        [self.dataBuffer addObject:chunk];
    }
        [self.delegate recordingSession:self recorderGotChunk:chunk];
    });
}

-(void)recorderDetectedSpeech {
    if (self.vadEnabled == WITVadConfigFull) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //start the uploader
            if (![self startUploader]) {
                [self stop];
                return;
            }
    
            //then prepend buffered data
            for(NSData* bufferedData in self.dataBuffer){
                [self.uploader sendChunk:bufferedData];
            }
        });
    }
}

-(void)recorderStarted {
    [self.delegate recordingSessionActivityDetectorStarted:self];
}


-(void)recorderVadStoppedTalking {
    [self.delegate stop];
}


#pragma mark - cleaning

-(void)clean {
    self.recorder = nil;
    self.uploader = nil;
}


-(void)dealloc {
    
    NSLog(@"Clean WITRecordingSession");
}

@end
