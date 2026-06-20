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

static NSData *jsonData(void) {
    return [@"{\"outcomes\":[]}" dataUsingEncoding:NSUTF8StringEncoding];
}

static BOOL acceptsContentType(NSString *contentType) {
    NSError *error = nil;
    NSDictionary *object = WITJSONObjectFromResponse(response(200, contentType), jsonData(), &error);
    return object != nil && error == nil;
}

static BOOL isAllowedRestrictedASCII(unichar character) {
    return (character >= 'A' && character <= 'Z') ||
           (character >= 'a' && character <= 'z') ||
           (character >= '0' && character <= '9') ||
           character == '!' || character == '#' || character == '$' ||
           character == '&' || character == '-' || character == '^' ||
           character == '_' || character == '.' || character == '+';
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

        for (NSString *contentType in @[
                 @"APPLICATION/JSON",
                 @" application/vnd.example_v2+json\t",
                 @"application/foo!#$&^_.+-bar+json",
                 @"application/problem+JSON; charset=utf-8",
                 @"application/a+json; profile=\"https://example.test/schema\""
             ]) {
            require(acceptsContentType(contentType),
                    @"valid RFC 6838 JSON media types and parameters must pass");
        }

        NSString *maximumSubtype = [[@"a" stringByPaddingToLength:122
                                                        withString:@"a"
                                                   startingAtIndex:0]
                                    stringByAppendingString:@"+json"];
        require(maximumSubtype.length == 127 &&
                acceptsContentType([@"application/" stringByAppendingString:maximumSubtype]),
                @"127-character restricted subtypes must pass");

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

        require(!acceptsContentType(@"application/K+json"),
                @"Unicode case folding must not turn Kelvin sign into an ASCII restricted name");

        for (NSString *contentType in @[
                 @"text/problem+json",
                 @"application/+json",
                 @"application/Ｋ+json",
                 @"application/ſ+json",
                 @"application/İ+json",
                 @"application/ı+json",
                 @"application/µ+json",
                 @"application/Μ+json",
                 @"application/а+json",
                 @"application/a\u030A+json",
                 @"application/😀+json",
                 @"application/foo\u00A0bar+json",
                 @"application/foo\u200Bbar+json",
                 @"application/foo\u2028bar+json",
                 @"application/foo\u2029bar+json",
                 @"application/foo\uFEFFbar+json",
                 @"\u00A0application/json",
                 @"application/json\u00A0",
                 @"applicatioK/json",
                 @"ａｐｐｌｉｃａｔｉｏｎ/json",
                 @"application/foo\rbar+json",
                 @"application/foo\nbar+json",
                 @"application/foo\tbar+json",
                 @"application/-problem+json",
                 @"application/.problem+json",
                 @"application/problem()+json",
                 @"application/problem@+json",
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

        NSString *deleteControl = [NSString stringWithFormat:@"application/foo%Cbar+json", (unichar)0x7f];
        require(!acceptsContentType(deleteControl), @"DEL must be rejected inside restricted subtypes");

        for (NSUInteger surrogateIndex = 0; surrogateIndex < 2; surrogateIndex++) {
            const unichar surrogates[] = { 0xd800, 0xdfff };
            NSString *contentType = [NSString stringWithFormat:@"application/foo%Cbar+json", surrogates[surrogateIndex]];
            require(!acceptsContentType(contentType), @"unpaired UTF-16 surrogates must be rejected");
        }

        for (unichar character = 0; character < 0x20; character++) {
            NSString *contentType = [NSString stringWithFormat:@"application/foo%Cbar+json", character];
            require(!acceptsContentType(contentType), @"ASCII controls must be rejected inside restricted subtypes");
        }

        for (unichar character = 0x21; character <= 0x7e; character++) {
            if (!isAllowedRestrictedASCII(character)) {
                NSString *contentType = [NSString stringWithFormat:@"application/foo%Cbar+json", character];
                require(!acceptsContentType(contentType), @"disallowed ASCII punctuation must be rejected");
            }
        }

        for (NSUInteger rangeIndex = 0; rangeIndex < 3; rangeIndex++) {
            const unichar starts[] = { 0x0080, 0x2000, 0xff00 };
            const unichar ends[] = { 0x02ff, 0x214f, 0xffef };
            for (NSUInteger codePoint = starts[rangeIndex]; codePoint <= ends[rangeIndex]; codePoint++) {
                unichar character = (unichar)codePoint;
                NSString *contentType = [NSString stringWithFormat:@"application/foo%Cbar+json", character];
                require(!acceptsContentType(contentType), @"non-ASCII code units must be rejected before case folding");
            }
        }

        NSString *overlongSubtype = [[@"a" stringByPaddingToLength:123
                                                        withString:@"a"
                                                   startingAtIndex:0]
                                     stringByAppendingString:@"+json"];
        require(overlongSubtype.length == 128 &&
                !acceptsContentType([@"application/" stringByAppendingString:overlongSubtype]),
                @"128-character restricted subtypes must be rejected");
        NSString *veryLongSubtype = [[@"a" stringByPaddingToLength:4091
                                                       withString:@"a"
                                                  startingAtIndex:0]
                                     stringByAppendingString:@"+json"];
        require(!acceptsContentType([@"application/" stringByAppendingString:veryLongSubtype]),
                @"very long restricted subtypes must be rejected without truncation");

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
