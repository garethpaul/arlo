#import "WITHTTPPolicy.h"

const NSUInteger WITMaximumResponseBytes = 1024 * 1024;

static NSString *const WITHTTPPolicyErrorDomain = @"WITHTTPPolicy";

static NSError *WITPolicyError(NSInteger code, NSString *description) {
    return [NSError errorWithDomain:WITHTTPPolicyErrorDomain
                               code:code
                           userInfo:@{ NSLocalizedDescriptionKey: description }];
}

static BOOL WITIsASCIIAlphaNumeric(unichar character) {
    return (character >= 'A' && character <= 'Z') ||
           (character >= 'a' && character <= 'z') ||
           (character >= '0' && character <= '9');
}

static BOOL WITIsRestrictedNameCharacter(unichar character) {
    return WITIsASCIIAlphaNumeric(character) ||
           character == '!' || character == '#' || character == '$' ||
           character == '&' || character == '-' || character == '^' ||
           character == '_' || character == '.' || character == '+';
}

static BOOL WITIsRestrictedName(NSString *name) {
    if (name.length == 0 || name.length > 127 ||
        !WITIsASCIIAlphaNumeric([name characterAtIndex:0]) ||
        !WITIsASCIIAlphaNumeric([name characterAtIndex:name.length - 1])) {
        return NO;
    }

    for (NSUInteger index = 1; index + 1 < name.length; index++) {
        if (!WITIsRestrictedNameCharacter([name characterAtIndex:index])) {
            return NO;
        }
    }
    return YES;
}

static unichar WITASCIILowercase(unichar character) {
    if (character >= 'A' && character <= 'Z') {
        return character + ('a' - 'A');
    }
    return character;
}

static BOOL WITASCIIStringEquals(NSString *value, NSString *expected) {
    if (value.length != expected.length) {
        return NO;
    }
    for (NSUInteger index = 0; index < value.length; index++) {
        if (WITASCIILowercase([value characterAtIndex:index]) !=
            WITASCIILowercase([expected characterAtIndex:index])) {
            return NO;
        }
    }
    return YES;
}

static BOOL WITASCIIStringHasSuffix(NSString *value, NSString *suffix) {
    if (value.length < suffix.length) {
        return NO;
    }
    return WITASCIIStringEquals([value substringFromIndex:value.length - suffix.length], suffix);
}

static BOOL WITIsJSONContentType(NSString *contentType) {
    if (![contentType isKindOfClass:[NSString class]]) {
        return NO;
    }

    NSString *rawMediaType = [contentType componentsSeparatedByString:@";"][0];
    NSUInteger start = 0;
    NSUInteger end = rawMediaType.length;
    while (start < end && ([rawMediaType characterAtIndex:start] == ' ' ||
                           [rawMediaType characterAtIndex:start] == '\t')) {
        start++;
    }
    while (end > start && ([rawMediaType characterAtIndex:end - 1] == ' ' ||
                           [rawMediaType characterAtIndex:end - 1] == '\t')) {
        end--;
    }

    NSString *mediaType = [rawMediaType substringWithRange:NSMakeRange(start, end - start)];
    NSRange separator = [mediaType rangeOfString:@"/"];
    if (separator.location == NSNotFound ||
        !WITASCIIStringEquals([mediaType substringToIndex:separator.location], @"application")) {
        return NO;
    }

    NSString *subtype = [mediaType substringFromIndex:separator.location + 1];
    if (!WITIsRestrictedName(subtype)) {
        return NO;
    }
    if (WITASCIIStringEquals(subtype, @"json")) {
        return YES;
    }

    NSString *jsonSuffix = @"+json";
    return subtype.length > jsonSuffix.length && WITASCIIStringHasSuffix(subtype, jsonSuffix);
}

BOOL WITIsValidAccessToken(NSString *token) {
    if (![token isKindOfClass:[NSString class]] || token.length == 0 || token.length > 4096) {
        return NO;
    }

    NSCharacterSet *forbidden = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    return [token rangeOfCharacterFromSet:forbidden].location == NSNotFound &&
           [token rangeOfCharacterFromSet:[NSCharacterSet controlCharacterSet]].location == NSNotFound;
}

NSURL *WITURLByAppendingQueryItems(NSURL *baseURL,
                                   NSDictionary<NSString *, NSString *> *items,
                                   NSError **error) {
    NSURLComponents *components = [NSURLComponents componentsWithURL:baseURL resolvingAgainstBaseURL:NO];
    if (!components || ![components.scheme.lowercaseString isEqualToString:@"https"] || components.host.length == 0) {
        if (error) {
            *error = WITPolicyError(1, @"Invalid Wit request URL.");
        }
        return nil;
    }

    if (![items isKindOfClass:[NSDictionary class]] || items.count > 32) {
        if (error) {
            *error = WITPolicyError(2, @"Invalid Wit request query.");
        }
        return nil;
    }

    __block BOOL invalidItem = NO;
    [items enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        if (![key isKindOfClass:[NSString class]] || ![value isKindOfClass:[NSString class]]) {
            invalidItem = YES;
            *stop = YES;
        }
    }];
    if (invalidItem) {
        if (error) {
            *error = WITPolicyError(2, @"Invalid Wit request query.");
        }
        return nil;
    }

    NSMutableArray *queryItems = [components.queryItems mutableCopy] ?: [NSMutableArray array];
    [items enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        if ([key isKindOfClass:[NSString class]] && [value isKindOfClass:[NSString class]]) {
            [queryItems addObject:[NSURLQueryItem queryItemWithName:key value:value]];
        }
    }];
    components.queryItems = queryItems;

    NSURL *url = components.URL;
    if (!url && error) {
            *error = WITPolicyError(7, @"Unable to construct Wit request URL.");
    }
    return url;
}

NSError *WITSanitizedTransportError(NSError *error) {
    if (!error) {
        return nil;
    }
    return [NSError errorWithDomain:error.domain ?: WITHTTPPolicyErrorDomain
                               code:error.code
                           userInfo:@{ NSLocalizedDescriptionKey: @"The Wit request failed." }];
}

NSDictionary *WITJSONObjectFromResponse(NSURLResponse *response, NSData *data, NSError **error) {
    if (![response isKindOfClass:[NSHTTPURLResponse class]]) {
        if (error) {
            *error = WITPolicyError(3, @"The Wit response was not HTTP.");
        }
        return nil;
    }

    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if (httpResponse.statusCode < 200 || httpResponse.statusCode > 299) {
        if (error) {
            *error = WITPolicyError(httpResponse.statusCode, @"The Wit service returned an error.");
        }
        return nil;
    }

    NSString *contentType = [httpResponse.allHeaderFields[@"Content-Type"] description];
    if (!WITIsJSONContentType(contentType)) {
        if (error) {
            *error = WITPolicyError(4, @"The Wit response was not JSON.");
        }
        return nil;
    }

    if (![data isKindOfClass:[NSData class]] || data.length == 0 || data.length > WITMaximumResponseBytes) {
        if (error) {
            *error = WITPolicyError(5, @"The Wit response size was invalid.");
        }
        return nil;
    }

    NSError *serializationError = nil;
    id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:&serializationError];
    if (![object isKindOfClass:[NSDictionary class]]) {
        if (error) {
            *error = WITPolicyError(6, @"The Wit response JSON shape was invalid.");
        }
        return nil;
    }
    return object;
}

NSArray *WITOutcomesFromJSONObject(NSDictionary *object, NSString **messageID, NSError **error) {
    if (messageID) {
        *messageID = nil;
    }
    if (![object isKindOfClass:[NSDictionary class]]) {
        if (error) {
            *error = WITPolicyError(8, @"The Wit intent response was invalid.");
        }
        return nil;
    }

    id providerError = object[@"error"];
    if (providerError && providerError != [NSNull null]) {
        if (error) {
            *error = WITPolicyError(9, @"The Wit service could not process the request.");
        }
        return nil;
    }

    id rawOutcomes = object[@"outcomes"];
    if (![rawOutcomes isKindOfClass:[NSArray class]] || [rawOutcomes count] == 0 || [rawOutcomes count] > 100) {
        if (error) {
            *error = WITPolicyError(10, @"The Wit intent outcomes were invalid.");
        }
        return nil;
    }
    for (id outcome in rawOutcomes) {
        if (![outcome isKindOfClass:[NSDictionary class]]) {
            if (error) {
                *error = WITPolicyError(10, @"The Wit intent outcomes were invalid.");
            }
            return nil;
        }
    }

    id rawMessageID = object[@"msg_id"];
    if (rawMessageID && rawMessageID != [NSNull null]) {
        if (![rawMessageID isKindOfClass:[NSString class]] || [rawMessageID length] > 4096 ||
            [rawMessageID rangeOfCharacterFromSet:[NSCharacterSet controlCharacterSet]].location != NSNotFound) {
            if (error) {
                *error = WITPolicyError(11, @"The Wit message identifier was invalid.");
            }
            return nil;
        }
        if (messageID) {
            *messageID = rawMessageID;
        }
    }
    return rawOutcomes;
}
