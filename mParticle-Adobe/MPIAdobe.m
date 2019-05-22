#import "MPIAdobe.h"
#import "MPKitAdobe.h"

NSString *const MPIAdobeErrorKey = @"MPIAdobeErrorKey";

NSString *host = @"dpm.demdex.net";
NSString *protocol = @"https";
NSString *path = @"/id?";

NSString *marketingCloudIdKey = @"d_mid";
NSString *organizationIdKey = @"d_orgid";
NSString *deviceIdKey = @"d_cid";
NSString *userIdentityKey = @"d_cid_ic";
NSString *regionKey = @"dcs_region";
NSString *blobKey = @"d_blob";
NSString *platformKey = @"d_ptfm";
NSString *versionKey = @"d_ver";

NSString *platform = @"ios";
NSString *version = @"2";

NSString *advertiserIdDeviceKey = @"20915";
NSString *pushTokenDeviceKey = @"20920";

NSString *customerIdIdentityKey = @"customerid";
NSString *emailIdentityKey = @"email";

NSString *idSuffix = @"%01";

NSString *errorResponseKey = @"error_msg";
NSString *errorMessageKey = @"msg";
NSString *errorCodeKey = @"code";

NSString *invalidMarketingCloudId = @"<null>";

NSString *errorDomain = @"mParticle-Adobe";
NSString *serverErrorDomain = @"mParticle-Adobe Server Response";
NSString *errorKey = @"Error";

NSString *marketingCloudIdUserDefaultsKey = @"ADBMOBILE_PERSISTED_MID";

@interface MPIAdobeError ()

- (id)initWithCode:(MPIAdobeErrorCode)code message:(NSString *)message error:(NSError *)error;

@end

@implementation MPIAdobeError

- (id)initWithCode:(MPIAdobeErrorCode)code message:(NSString *)message error:(NSError *)error {
    self = [super init];
    if (self) {
        _code = code;
        _message = message;
        _innerError = error;
    }
    return self;
}

- (NSString *)description {
    NSMutableString *description = [[NSMutableString alloc] initWithString:@"MPIAdobeError {\n"];
    [description appendFormat:@"  code: %@\n", @(_code)];
    [description appendFormat:@"  message: %@\n", _message];
    [description appendFormat:@"  inner error: %@\n", _innerError];
    [description appendString:@"}"];
    return description;
}

@end

@interface MPIAdobe ()

@property (nonatomic) NSString *region;
@property (nonatomic) NSString *blob;

@end

@implementation MPIAdobe

- (void)sendRequestWithMarketingCloudId:(NSString *)marketingCloudId advertiserId:(NSString *)advertiserId pushToken:(NSString *)pushToken organizationId:(NSString *)organizationId userIdentities:(NSDictionary<NSNumber *, NSString *> *)userIdentities completion:(void (^)(NSString *marketingCloudId, NSString *blob, NSString *locationHint, NSError *))completion {
    
    NSDictionary *userIdentityMappings = @{
                                           @(MPUserIdentityOther): @"other",
                                           @(MPUserIdentityCustomerId): @"customerid",
                                           @(MPUserIdentityFacebook): @"facebook",
                                           @(MPUserIdentityTwitter): @"twitter",
                                           @(MPUserIdentityGoogle): @"google",
                                           @(MPUserIdentityMicrosoft): @"microsoft",
                                           @(MPUserIdentityYahoo): @"yahoo",
                                           @(MPUserIdentityEmail): @"email",
                                           @(MPUserIdentityAlias): @"alias",
                                           @(MPUserIdentityFacebookCustomAudienceId): @"facebookcustomaudienceid"
                                           };
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@://%@%@", protocol, host, path];
    
    NSURLComponents *components = [NSURLComponents componentsWithString:urlString];
    NSMutableArray *queryItems = [NSMutableArray array];
    
    if (marketingCloudId) {
        [queryItems addObject:[NSURLQueryItem queryItemWithName:marketingCloudIdKey value:marketingCloudId]];
    }
    
    if (advertiserId) {
        [queryItems addObject:[NSURLQueryItem queryItemWithName:deviceIdKey value:[NSString stringWithFormat:@"%@%@%@", advertiserIdDeviceKey, idSuffix, advertiserId]]];
    }
    
    if (pushToken) {
        [queryItems addObject:[NSURLQueryItem queryItemWithName:deviceIdKey value:[NSString stringWithFormat:@"%@%@%@", pushTokenDeviceKey, idSuffix, pushToken]]];
    }
    
    if (userIdentities) {
        [userIdentities enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            NSString *mappedKey = userIdentityMappings[key];
            if (mappedKey.length) {
                [queryItems addObject:[NSURLQueryItem queryItemWithName:userIdentityKey value:[NSString stringWithFormat:@"%@%@%@", mappedKey, idSuffix, obj]]];
            }
        }];
    }
    
    if (self.blob) {
        [queryItems addObject:[NSURLQueryItem queryItemWithName:blobKey value:self.blob]];
    }
    
    if (self.region) {
        [queryItems addObject:[NSURLQueryItem queryItemWithName:regionKey value:self.region]];
    }
    
    [queryItems addObject:[NSURLQueryItem queryItemWithName:organizationIdKey value:organizationId]];
    [queryItems addObject:[NSURLQueryItem queryItemWithName:platformKey value:platform]];
    [queryItems addObject:[NSURLQueryItem queryItemWithName:versionKey value:version]];
    
    components.queryItems = queryItems;
    NSURL *url = components.URL;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    __weak MPIAdobe *weakSelf = self;
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        
        void (^callbackWithCode)(MPIAdobeErrorCode code, NSString *message, NSError *error) = ^void(MPIAdobeErrorCode code, NSString *message, NSError *error) {
            MPIAdobeError *adobeError = [[MPIAdobeError alloc] initWithCode:code message:message error:error];
            NSError *compositeError = [NSError errorWithDomain:errorDomain code:adobeError.code userInfo:@{MPIAdobeErrorKey:adobeError}];
            completion(nil, nil, nil, compositeError);
        };
        
        if (error) {
            return callbackWithCode(MPIAdobeErrorCodeClientFailedRequestError, @"Request failed", error);
        }
        
        NSDictionary *dictionary = nil;
        @try {
            dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        } @catch (NSException *exception) {
            return callbackWithCode(MPIAdobeErrorCodeClientSerializationError, @"Deserializing the response failed", nil);
        }
        
        NSDictionary *errorDictionary = dictionary[errorResponseKey];
        if (errorDictionary) {
            NSError *error = [NSError errorWithDomain:serverErrorDomain code:0 userInfo:errorDictionary];
            return callbackWithCode(MPIAdobeErrorCodeServerError, @"Server returned an error", error);
        }
        
        NSString *marketingCloudId = dictionary[marketingCloudIdKey];
        if ([marketingCloudId isEqualToString:invalidMarketingCloudId]) {
            marketingCloudId = nil;
        }
        
        NSString *region = [NSString stringWithFormat:@"%@", dictionary[regionKey]];
        NSString *blob = dictionary[blobKey];
        
        weakSelf.region = region;
        weakSelf.blob = blob;
        
        completion(marketingCloudId, region, blob, nil);
    }] resume];
}

- (NSString *)marketingCloudIdFromUserDefaults {
    return [[NSUserDefaults standardUserDefaults] objectForKey:marketingCloudIdUserDefaultsKey];
}

@end
