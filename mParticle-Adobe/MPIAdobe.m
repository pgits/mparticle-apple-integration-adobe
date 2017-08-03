#import "MPIAdobe.h"
#import "MPKitAdobe.h"

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

NSString *advertisingIdDeviceKey = @"20915";
NSString *pushTokenDeviceKey = @"20920";

NSString *customerIdIdentityKey = @"customerid";
NSString *emailIdentityKey = @"email";

NSString *idSuffix = @"%01";

NSString *marketingCloudIdUserDefaultsKey = @"ADBMOBILE_PERSISTED_MID";

@interface MPIAdobe ()

@property (nonatomic) NSString *region;
@property (nonatomic) NSString *blob;

@end

@implementation MPIAdobe

- (void)sendRequestWithMarketingCloudId:(NSString *)marketingCloudId advertisingId:(NSString *)advertisingId pushToken:(NSString *)pushToken organizationId:(NSString *)organizationId userIdentities:(NSDictionary<NSNumber *, NSString *> *)userIdentities completion:(void (^)(NSString *marketingCloudId, NSError *))completion {
    
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
    
    if (advertisingId) {
        [queryItems addObject:[NSURLQueryItem queryItemWithName:deviceIdKey value:[NSString stringWithFormat:@"%@%@%@", advertisingIdDeviceKey, idSuffix, advertisingId]]];
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
        if (error) {
            completion(nil, error);
            return;
        }

        NSDictionary *dictionary = nil;
        @try {
            dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        } @catch (NSException *exception) {
            
        }
        
        NSString *marketingCloudId = dictionary[marketingCloudIdKey];
        weakSelf.region = dictionary[regionKey];
        weakSelf.blob = dictionary[blobKey];
        
        completion(marketingCloudId, nil);
    }] resume];
}

- (NSString *)marketingCloudIdFromUserDefaults {
    return [[NSUserDefaults standardUserDefaults] objectForKey:marketingCloudIdUserDefaultsKey];
}

@end
