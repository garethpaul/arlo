#import <Foundation/Foundation.h>

#import "WITHTTPPolicy.h"

static void require(BOOL condition, NSString *message) {
    if (!condition) {
        NSLog(@"FAIL: %@", message);
        exit(1);
    }
}

static NSHTTPURLResponse *response(NSInteger statusCode, NSString *contentType) {
    return [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:@"https://api.wit.ai/speech"]
                                      statusCode:statusCode
                                     HTTPVersion:@"HTTP/1.1"
                                    headerFields:@{ @"Content-Type": contentType }];
}

int main(void) {
    @autoreleasepool {
        require(!WITIsValidAccessToken(nil), @"nil tokens must be rejected");
        require(!WITIsValidAccessToken(@""), @"empty tokens must be rejected");
        require(!WITIsValidAccessToken(@" token"), @"leading whitespace must be rejected");
        require(!WITIsValidAccessToken(@"token\nInjected: value"), @"control characters must be rejected");
        require(WITIsValidAccessToken(@"wit-valid_token.123"), @"valid tokens must be accepted");

        NSError *urlError = nil;
        NSURL *url = WITURLByAppendingQueryItems(
            [NSURL URLWithString:@"https://api.wit.ai/speech?v=20141022"],
            @{ @"context": @"{\"message\":\"a&b?c#d\"}" },
            &urlError
        );
        require(url != nil && urlError == nil, @"valid query items must produce a URL");
        require([url.absoluteString containsString:@"context=%7B%22message%22:%22a%26b?c%23d%22%7D"] ||
                [url.absoluteString containsString:@"context=%7B%22message%22:%22a%26b%3Fc%23d%22%7D"],
                @"provider context must remain one encoded query value");

        urlError = nil;
        require(WITURLByAppendingQueryItems([NSURL URLWithString:@"https://api.wit.ai/speech"],
                                            (id)@{ @"context": @1 },
                                            &urlError) == nil && urlError != nil,
                @"non-string query values must fail closed");

        NSError *responseError = nil;
        NSDictionary *object = WITJSONObjectFromResponse(
            response(200, @"application/json; charset=utf-8"),
            [@"{\"outcomes\":[]}" dataUsingEncoding:NSUTF8StringEncoding],
            &responseError
        );
        require(object != nil && responseError == nil, @"valid JSON object responses must pass");

        responseError = nil;
        object = WITJSONObjectFromResponse(
            response(200, @"application/problem+json; charset=utf-8"),
            [@"{\"outcomes\":[]}" dataUsingEncoding:NSUTF8StringEncoding],
            &responseError
        );
        require(object != nil && responseError == nil,
                @"application structured JSON suffixes must pass");

        NSString *messageID = nil;
        NSError *intentError = nil;
        NSArray *outcomes = WITOutcomesFromJSONObject(@{ @"outcomes": @[ @{ @"intent": @"weather" } ], @"msg_id": @"message-1" },
                                                       &messageID,
                                                       &intentError);
        require(outcomes.count == 1 && [messageID isEqualToString:@"message-1"] && intentError == nil,
                @"valid intent responses must preserve bounded outcomes and message IDs");

        intentError = nil;
        require(WITOutcomesFromJSONObject(@{ @"outcomes": @{ @"intent": @"weather" } }, nil, &intentError) == nil,
                @"mapping-shaped outcomes must be rejected");
        intentError = nil;
        require(WITOutcomesFromJSONObject(@{ @"outcomes": @[ @"secret" ] }, nil, &intentError) == nil,
                @"scalar outcome entries must be rejected");
        intentError = nil;
        require(WITOutcomesFromJSONObject(@{ @"error": @{ @"payload": @"secret" } }, nil, &intentError) == nil &&
                ![intentError.description containsString:@"secret"],
                @"nested provider errors must fail without retaining payloads");

        responseError = nil;
        require(WITJSONObjectFromResponse(response(401, @"application/json"),
                                          [@"{\"error\":{\"token\":\"secret\"}}" dataUsingEncoding:NSUTF8StringEncoding],
                                          &responseError) == nil,
                @"non-success HTTP responses must fail closed");
        require(responseError != nil && ![responseError.localizedDescription containsString:@"secret"],
                @"HTTP errors must not expose provider payloads");

        responseError = nil;
        require(WITJSONObjectFromResponse(response(200, @"text/html"),
                                          [@"<html>secret</html>" dataUsingEncoding:NSUTF8StringEncoding],
                                          &responseError) == nil,
                @"non-JSON content types must be rejected");

        for (NSString *contentType in @[
                 @"text/problem+json",
                 @"application/+json",
                 @"application/problem+jsonp",
                 @"text/plain; note=+json"
             ]) {
            responseError = nil;
            require(WITJSONObjectFromResponse(
                        response(200, contentType),
                        [@"{\"outcomes\":[]}" dataUsingEncoding:NSUTF8StringEncoding],
                        &responseError) == nil && responseError != nil,
                    @"JSON media types must be application/json or application/*+json");
        }

        responseError = nil;
        NSMutableData *oversized = [NSMutableData dataWithLength:WITMaximumResponseBytes + 1];
        require(WITJSONObjectFromResponse(response(200, @"application/json"), oversized, &responseError) == nil,
                @"oversized responses must be rejected before parsing");

        responseError = nil;
        require(WITJSONObjectFromResponse(response(200, @"application/json"),
                                          [@"[1,2,3]" dataUsingEncoding:NSUTF8StringEncoding],
                                          &responseError) == nil,
                @"top-level arrays must be rejected");

        NSError *nested = [NSError errorWithDomain:NSURLErrorDomain
                                               code:NSURLErrorBadServerResponse
                                           userInfo:@{
                                               NSURLErrorFailingURLErrorKey: [NSURL URLWithString:@"https://api.wit.ai/speech?token=secret"],
                                               NSLocalizedDescriptionKey: @"payload secret",
                                               NSUnderlyingErrorKey: [NSError errorWithDomain:@"nested" code:7 userInfo:@{ @"body": @"secret" }]
                                           }];
        NSError *sanitized = WITSanitizedTransportError(nested);
        require([sanitized.domain isEqualToString:NSURLErrorDomain] && sanitized.code == NSURLErrorBadServerResponse,
                @"sanitized errors must preserve stable domain and code");
        require(![sanitized.description containsString:@"secret"] && sanitized.userInfo.count == 1,
                @"sanitized errors must remove URLs, nested errors, and payloads");
    }
    return 0;
}
