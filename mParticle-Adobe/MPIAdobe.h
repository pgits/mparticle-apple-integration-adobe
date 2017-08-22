#import <Foundation/Foundation.h>

@interface MPIAdobe : NSObject

- (void)sendRequestWithMarketingCloudId:(NSString *)marketingCloudId advertiserId:(NSString *)advertiserId pushToken:(NSString *)pushToken organizationId:(NSString *)organizationId userIdentities:(NSDictionary<NSNumber *, NSString *> *)userIdentities completion:(void (^)(NSString *marketingCloudId, NSString *locationHint, NSString *blob, NSError *error))completion;

- (NSString *)marketingCloudIdFromUserDefaults;

@end

// Use this key to retrieve the MPIAdobeError object from the NSError's userInfo dictionary
extern NSString *const MPIAdobeErrorKey;

typedef NS_ENUM(NSInteger, MPIAdobeErrorCode) {
    // Network request failed
    MPIAdobeErrorCodeClientFailedRequestError,
    // Unable to deserialize JSON from response
    MPIAdobeErrorCodeClientSerializationError,
    // An error was provided by the server
    MPIAdobeErrorCodeServerError
};

@interface MPIAdobeError : NSObject

@property (nonatomic, assign) MPIAdobeErrorCode code;
@property (nonatomic) NSString *message;
@property (nonatomic) NSError *innerError;

@end
