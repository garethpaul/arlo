#import <Foundation/Foundation.h>

FOUNDATION_EXPORT const NSUInteger WITMaximumResponseBytes;

FOUNDATION_EXPORT BOOL WITIsValidAccessToken(NSString *token);
FOUNDATION_EXPORT NSURL *WITURLByAppendingQueryItems(NSURL *baseURL,
                                                     NSDictionary<NSString *, NSString *> *items,
                                                     NSError **error);
FOUNDATION_EXPORT NSDictionary *WITJSONObjectFromResponse(NSURLResponse *response,
                                                           NSData *data,
                                                           NSError **error);
FOUNDATION_EXPORT NSArray *WITOutcomesFromJSONObject(NSDictionary *object,
                                                     NSString **messageID,
                                                     NSError **error);
FOUNDATION_EXPORT NSError *WITSanitizedTransportError(NSError *error);
