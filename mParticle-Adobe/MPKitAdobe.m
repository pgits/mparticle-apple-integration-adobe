#import "MPKitAdobe.h"
#import "MPIAdobe.h"

NSString *marketingCloudIdIntegrationAttributeKey = @"adobe_mcid";
NSString *organizationIdConfigurationKey = @"organizationId";

#pragma mark - MPKitAdobe
@interface MPKitAdobe ()

@property (nonatomic) NSString *organizationId;
@property (nonatomic) MPIAdobe *adobe;

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
    return nil;
}

- (NSString *)advertisingId {
    return nil;
}

- (NSString *)pushToken {
    return nil;
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
    
    NSString *advertisingId = [self advertisingId];
    NSString *pushToken = [self pushToken];
    NSDictionary *userIdentities = [self userIdentitiesDictionary];
    
    [_adobe sendRequestWithMarketingCloudId:marketingCloudId advertisingId:advertisingId pushToken:pushToken organizationId:_organizationId userIdentities:userIdentities completion:^(NSString *marketingCloudId, NSError *error) {
        if (!error && marketingCloudId.length) {
            [[MParticle sharedInstance] setIntegrationAttributes:@{marketingCloudIdIntegrationAttributeKey: marketingCloudId} forKit:[[self class] kitCode]];
        }
    }];
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
