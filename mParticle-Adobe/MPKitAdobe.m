#import "MPKitAdobe.h"

@implementation MPIAdobe

- (instancetype)init {
    self = [super init];
    return self;
}

@end

#pragma mark - MPKitAdobe
@interface MPKitAdobe ()

@property (nonatomic, copy) NSString *organizationId;

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

    _organizationId = [configuration[@"organizationId"] copy];
    if (!self || !_organizationId.length) {
        return nil;
    }

    _configuration = configuration;
    _started       = startImmediately;

    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *userInfo = @{ mParticleKitInstanceKey: [[self class] kitCode] };

        [[NSNotificationCenter defaultCenter] postNotificationName:mParticleKitDidBecomeActiveNotification
                                                            object:nil
                                                          userInfo:userInfo];
    });

    return self;
}

@end
