//
//  Created by Willy Blandin on 12. 8. 16.
//  Copyright (c) 2012년 Willy Blandin. All rights reserved.
//

#import "WitPrivate.h"
#import "WITState.h"
#import "WITRecorder.h"
#import "WITUploader.h"
#import "util.h"
//#import "WITRecordingSession.h"
#import "WITContextSetter.h"
#import "WITHTTPPolicy.h"


@interface Wit ()
@property (strong) WITState *state;
@property WITRecordingSession *recordingSession;
@property NSUInteger textRequestGeneration;
@end

@implementation Wit {
    dispatch_once_t _initWcsOnceToken;
    WITContextSetter* _wcs;
}

@synthesize delegate, state;

#pragma mark - Public API
- (void)toggleCaptureVoiceIntent {
    [self toggleCaptureVoiceIntent: nil];
}

- (void)toggleCaptureVoiceIntent:(id)customData {
    if ([self isRecording]) {
        [self stop];
    } else {
        [self start: customData];
    }
}

- (void)start {
    [self start: nil];
}


- (void)start: (id)customData {
    if (self.recordingSession) {
        [self stop];
    }
    self.recordingSession = [[WITRecordingSession alloc] initWithWitContext:state.context
                                                                 vadEnabled:[Wit sharedInstance].detectSpeechStop withWitToken:[WITState sharedInstance].accessToken
                                                               withDelegate:self];
    if (!self.recordingSession) {
        [self errorWithDescription:@"Unable to start voice capture." customData:customData];
        return;
    }
    self.recordingSession.customData = customData;
    self.recordingSession.delegate = self;
    if (![self.recordingSession start]) {
        self.recordingSession = nil;
        [self errorWithDescription:@"Unable to start voice capture." customData:customData];
    }
}

- (void)stop{
    [self.recordingSession stop];
}

- (BOOL)isRecording {
    return [self.recordingSession isRecording];
}

- (void) interpretString: (NSString *) string customData:(id)customData {
    if (!WITIsValidAccessToken(self.accessToken) || ![string isKindOfClass:[NSString class]] || string.length == 0 || string.length > 16384) {
        [self errorWithDescription:@"Invalid Wit request." customData:customData];
        return;
    }
    [self.wcs contextFillup:self.state.context];
    NSDate *start = [NSDate date];
    NSError *requestError = nil;
    NSData *contextData = [NSJSONSerialization dataWithJSONObject:self.state.context options:0 error:&requestError];
    if (!contextData || contextData.length > 16384) {
        [self errorWithDescription:@"Invalid Wit context." customData:customData];
        return;
    }
    NSString *contextJSON = [[NSString alloc] initWithData:contextData encoding:NSUTF8StringEncoding];
    NSURL *url = WITURLByAppendingQueryItems([NSURL URLWithString:@"https://api.wit.ai/message"],
                                             @{ @"q": string, @"v": kWitAPIVersion, @"context": contextJSON },
                                             &requestError);
    if (!url) {
        [self errorWithDescription:@"Invalid Wit request URL." customData:customData];
        return;
    }
    NSUInteger generation = ++self.textRequestGeneration;
    NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:url];
    [req setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [req setTimeoutInterval:15.0];
    [req setValue:[NSString stringWithFormat:@"Bearer %@", self.accessToken] forHTTPHeaderField:@"Authorization"];
    [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [NSURLConnection sendAsynchronousRequest:req
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (generation != self.textRequestGeneration) {
                                   return;
                               }
                               if (WIT_DEBUG) {
                                   NSTimeInterval t = [[NSDate date] timeIntervalSinceDate:start];
                                   NSLog(@"Wit response (%f s)", t);
                               }

                               if (connectionError) {
                                   [self gotResponse:nil customData:customData error:WITSanitizedTransportError(connectionError)];
                                   return;
                               }

                               NSError *responseError = nil;
                               NSDictionary *object = WITJSONObjectFromResponse(response, data, &responseError);
                               if (!object) {
                                   [self gotResponse:nil customData:customData error:responseError];
                                   return;
                               }

                               if (object[@"error"]) {
                                   [self gotResponse:nil customData:customData
                                               error:[NSError errorWithDomain:@"WitProcessing"
                                                                         code:1
                                                                     userInfo:@{NSLocalizedDescriptionKey: @"The Wit service could not process the request."}]];
                                   return;
                               }

                               [self gotResponse:object customData:customData error:nil];
                           }];
}

#pragma mark - Context management
-(void)setContext:(NSDictionary *)dict {
    NSMutableDictionary* newContext = [state.context mutableCopy];
    if (!newContext) {
        newContext = [@{} mutableCopy];
    }

    [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        newContext[key] = obj;
    }];

    state.context = newContext;
}

-(NSDictionary*)getContext {
    return state.context;
}

#pragma mark - WITUploaderDelegate
- (void)gotResponse:(NSDictionary*)resp customData:(id)customData error:(NSError*)err {
    if (err) {
        [self error:err customData:customData];
        return;
    }
    [self processMessage:resp customData:customData];
}

#pragma mark - Response processing
- (void)errorWithDescription:(NSString*)errorDesc customData:(id)customData {
    NSError* e = [NSError errorWithDomain:@"WitProcessing" code:1 userInfo:@{NSLocalizedDescriptionKey: errorDesc}];
    [self error:e customData:customData];
}

- (void)processMessage:(NSDictionary *)resp customData:(id)customData {
    NSError *responseError = nil;
    NSString *messageId = nil;
    NSArray *outcomes = WITOutcomesFromJSONObject(resp, &messageId, &responseError);
    if (!outcomes) {
        [self error:responseError customData:customData];
        return;
    }

    [self.delegate witDidGraspIntent:outcomes messageId:messageId customData:customData error:nil];

}

- (void)error:(NSError*)e customData:(id)customData; {
    [self.delegate witDidGraspIntent:nil messageId:nil customData:customData error:e];
}

#pragma mark - Getters and setters
- (NSString *)accessToken {
    return state.accessToken;
}

- (void)setAccessToken:(NSString *)accessToken {
    state.accessToken = WITIsValidAccessToken(accessToken) ? [accessToken copy] : nil;
}

#pragma mark - Lifecycle
- (void)initialize {
    state = [WITState sharedInstance];
    self.detectSpeechStop = WITVadConfigDetectSpeechStop;
    self.vadTimeout = 7000;
    self.vadSensitivity = 0;
}
- (id)init {
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (Wit *)sharedInstance {
    static Wit *instance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[Wit alloc] init];
    });

    return instance;
}

-(WITContextSetter*)wcs {
    dispatch_once(&_initWcsOnceToken, ^{
        _wcs = [[WITContextSetter alloc] init];
    });
    return _wcs;
}

#pragma mark - WITRecordingSessionDelegate

- (BOOL)guardCurrentRecordingSession:(WITRecordingSession *)session {
    if (session != self.recordingSession) {
        return NO;
    }
    return session != nil;
}

-(void)recordingSessionActivityDetectorStarted:(WITRecordingSession *)session {
    if (![self guardCurrentRecordingSession:session]) return;
    if ([self.delegate respondsToSelector:@selector(witActivityDetectorStarted)]) {
        [self.delegate witActivityDetectorStarted];
    }
}

-(void)recordingSessionDidStartRecording:(WITRecordingSession *)session {
    if (![self guardCurrentRecordingSession:session]) return;
    if ([self.delegate respondsToSelector:@selector(witDidStartRecording)]) {
        [self.delegate witDidStartRecording];
    }
}

-(void)recordingSessionDidStopRecording:(WITRecordingSession *)session {
    if (![self guardCurrentRecordingSession:session]) return;
    if ([self.delegate respondsToSelector:@selector(witDidStopRecording)]) {
        [self.delegate witDidStopRecording];
    }
}

-(void)recordingSession:(WITRecordingSession *)session recorderGotChunk:(NSData *)chunk {
    if (![self guardCurrentRecordingSession:session]) return;
    if ([self.delegate respondsToSelector:@selector(witDidGetAudio:)]) {
        [self.delegate witDidGetAudio:chunk];
    }
}

-(void)recordingSessionRecorderPowerChanged:(float)power {

}

-(void)recordingSession:(WITRecordingSession *)session gotResponse:(NSDictionary *)resp customData:(id)customData error:(NSError *)err {
    if (![self guardCurrentRecordingSession:session]) return;
    [self gotResponse:resp customData:customData error:err];
    self.recordingSession = nil;
}

@end
