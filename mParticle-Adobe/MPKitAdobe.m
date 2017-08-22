#import "MPKitAdobe.h"
#import "MPIAdobe.h"

NSString *marketingCloudIdIntegrationAttributeKey = @"mid";
NSString *blobIntegrationAttributeKey = @"aamb";
NSString *locationHintIntegrationAttributeKey = @"aamlh";
NSString *organizationIdConfigurationKey = @"organizationId";

#pragma mark - MPKitAdobe
@interface MPKitAdobe ()

@property (nonatomic) NSString *organizationId;
@property (nonatomic) MPIAdobe *adobe;
@property (nonatomic) NSString *pushToken;
@property (nonatomic) MPKitAPI *kitApi;

@end

@implementation MPKitAdobe

@synthesize userIdentities = _userIdentities;

+ (NSNumber *)kitCode {
    return @124;
}


+ (void)load {
    MPKitRegister *kitRegister = [[MPKitRegister alloc] initWithName:@"Adobe"
                                                           className:NSStringFromClass(self)
                                                    startImmediately:YES];
    [MParticle registerExtension:kitRegister];
}


#pragma mark MPKitInstanceProtocol methods

- (nonnull instancetype)initWithConfiguration:(nonnull NSDictionary *)configuration startImmediately:(BOOL)startImmediately {
    self = [super init];

    _organizationId = [configuration[organizationIdConfigurationKey] copy];
    if (!self || !_organizationId.length) {
        return nil;
    }

    _configuration = configuration;
    _started       = startImmediately;
    _adobe         = [[MPIAdobe alloc] init];
    _kitApi        = [[MPKitAPI alloc] initWithKitCode:[[self class] kitCode]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                           selector:@selector(didEnterBackground:)
                               name:UIApplicationDidEnterBackgroundNotification
                             object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                           selector:@selector(willTerminate:)
                               name:UIApplicationWillTerminateNotification
                             object:nil];
    
    [self sendNetworkRequest];

    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *userInfo = @{ mParticleKitInstanceKey: [[self class] kitCode] };

        [[NSNotificationCenter defaultCenter] postNotificationName:mParticleKitDidBecomeActiveNotification
                                                            object:nil
                                                          userInfo:userInfo];
    });

    return self;
}

- (NSString *)marketingCloudIdFromIntegrationAttributes {
    NSDictionary *dictionary = _kitApi.integrationAttributes;
    return dictionary[marketingCloudIdIntegrationAttributeKey];
}

- (NSString *)advertiserId {
    NSString *advertiserId = nil;
    Class MPIdentifierManager = NSClassFromString(@"ASIdentifierManager");
    
    if (MPIdentifierManager) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        SEL selector = NSSelectorFromString(@"sharedManager");
        id<NSObject> adIdentityManager = [MPIdentifierManager performSelector:selector];
        
        selector = NSSelectorFromString(@"isAdvertisingTrackingEnabled");
        BOOL advertisingTrackingEnabled = (BOOL)[adIdentityManager performSelector:selector];
        if (advertisingTrackingEnabled) {
            selector = NSSelectorFromString(@"advertisingIdentifier");
            advertiserId = [[adIdentityManager performSelector:selector] UUIDString];
        }
#pragma clang diagnostic pop
#pragma clang diagnostic pop
    }
    
    return advertiserId;
}

- (NSString *)pushToken {
    return _pushToken;
}

- (void)sendNetworkRequest {
    NSString *marketingCloudId = [self marketingCloudIdFromIntegrationAttributes];
    if (!marketingCloudId) {
        marketingCloudId = [_adobe marketingCloudIdFromUserDefaults];
        if (marketingCloudId.length) {
            [[MParticle sharedInstance] setIntegrationAttributes:@{marketingCloudIdIntegrationAttributeKey: marketingCloudId} forKit:[[self class] kitCode]];
        }
    }
    
    NSString *advertiserId = [self advertiserId];
    NSString *pushToken = [self pushToken];
    NSDictionary *userIdentities = _kitApi.userIdentities;
    [_adobe sendRequestWithMarketingCloudId:marketingCloudId advertiserId:advertiserId pushToken:pushToken organizationId:_organizationId userIdentities:userIdentities completion:^(NSString *marketingCloudId, NSString *locationHint, NSString *blob, NSError *error) {
        if (error) {
            NSLog(@"mParticle -> Adobe kit request failed with error: %@", error);
            return;
        }
        
        NSMutableDictionary *integrationAttributes = [NSMutableDictionary dictionary];
        if (marketingCloudId.length) {
            [integrationAttributes setObject:marketingCloudId forKey:marketingCloudIdIntegrationAttributeKey];
        }
        if (locationHint.length) {
            [integrationAttributes setObject:locationHint forKey:locationHintIntegrationAttributeKey];
        }
        if (blob.length) {
            [integrationAttributes setObject:blob forKey:blobIntegrationAttributeKey];
        }
        
        if (integrationAttributes.count) {
            [[MParticle sharedInstance] setIntegrationAttributes:integrationAttributes forKit:[[self class] kitCode]];
        }
    }];
}

- (MPKitExecStatus *)setDeviceToken:(NSData *)deviceToken {
    _pushToken = [[NSString alloc] initWithData:deviceToken encoding:NSUTF8StringEncoding];
    [self sendNetworkRequest];
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:[[self class] kitCode] returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

- (MPKitExecStatus *)setUserIdentity:(NSString *)identityString identityType:(MPUserIdentity)identityType {
    [self sendNetworkRequest];
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:[[self class] kitCode] returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

- (nonnull MPKitExecStatus *)didBecomeActive {
    [self sendNetworkRequest];
    
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceAdobe) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

- (void)didEnterBackground:(NSNotification *)notification {
    [self sendNetworkRequest];
}

- (void)willTerminate:(NSNotification *)notification {
    [self sendNetworkRequest];
}

@end
