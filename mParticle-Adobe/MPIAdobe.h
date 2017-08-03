#import <Foundation/Foundation.h>

@interface MPIAdobe : NSObject

- (void)sendRequestWithMarketingCloudId:(NSString *)marketingCloudId advertisingId:(NSString *)advertisingId pushToken:(NSString *)pushToken organizationId:(NSString *)organizationId userIdentities:(NSDictionary<NSNumber *, NSString *> *)userIdentities completion:(void (^)(NSString *marketingCloudId, NSError *))completion;

- (NSString *)marketingCloudIdFromUserDefaults;

@end
