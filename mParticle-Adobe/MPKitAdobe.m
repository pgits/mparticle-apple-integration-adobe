#import "MPKitAdobe.h"
#import "MPIAdobe.h"

NSString *marketingCloudIdIntegrationAttributeKey = @"adobe_mcid";
NSString *organizationIdConfigurationKey = @"organizationId";

#pragma mark - MPKitAdobe
@interface MPKitAdobe ()

@property (nonatomic) NSString *organizationId;
@property (nonatomic) MPIAdobe *adobe;
@property (nonatomic) NSString *pushToken;

@end

@implementation MPKitAdobe

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
    NSDictionary *dictionary = [MPKitAPI integrationAttributesForKit:[[self class] kitCode]];
    return dictionary[marketingCloudIdIntegrationAttributeKey];
}

- (NSString *)advertiserId {
    return nil;
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

- (NSDictionary *)userIdentitiesDictionary {
    NSArray *identitiesArray = [self userIdentities];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [identitiesArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *identity = obj[@"i"];
        NSNumber *type = obj[@"n"];
        [dictionary setObject:identity forKey:type];
    }];
    return dictionary;
}

- (void)sendNetworkRequest {
    NSString *marketingCloudId = [self marketingCloudIdFromIntegrationAttributes];
    if (!marketingCloudId) {
        marketingCloudId = [_adobe marketingCloudIdFromUserDefaults];
        [[MParticle sharedInstance] setIntegrationAttributes:@{marketingCloudIdIntegrationAttributeKey: marketingCloudId} forKit:[[self class] kitCode]];
    }
    
    NSString *advertiserId = [self advertiserId];
    NSString *pushToken = [self pushToken];
    NSDictionary *userIdentities = [self userIdentitiesDictionary];
    
    [_adobe sendRequestWithMarketingCloudId:marketingCloudId advertiserId:advertiserId pushToken:pushToken organizationId:_organizationId userIdentities:userIdentities completion:^(NSString *marketingCloudId, NSError *error) {
        if (!error && marketingCloudId.length) {
            [[MParticle sharedInstance] setIntegrationAttributes:@{marketingCloudIdIntegrationAttributeKey: marketingCloudId} forKit:[[self class] kitCode]];
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
