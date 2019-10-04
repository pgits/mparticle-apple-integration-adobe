## Adobe Kit Integration

This repository contains the [Adobe](https://www.adobe.com) integration for the [mParticle Apple SDK](https://github.com/mParticle/mparticle-apple-sdk).

### Adding the integration

1. Add the kit dependency to your app's package management file:

> To send media data to Adobe, you must use CocoaPods since their SDKs do not support Carthage

```
pod 'mParticle-Adobe/AdobeHeartbeat', '~> 7.0'
```

> Otherwise, for the previous non-media Adobe integration, you can integrate via Carthage or CocoaPods

```
pod 'mParticle-Adobe/Adobe', '~> 7.0'
```

OR

```
github "mparticle-integrations/mparticle-apple-integration-adobe" ~> 7.0
```

2. Follow the mParticle iOS SDK [quick-start](https://github.com/mParticle/mparticle-apple-sdk), then rebuild and launch your app, and verify that you see `"Included kits: { AdobeHeartbeat }"` or `"Included kits: { Adobe }"` or in your Xcode console

> (This requires your mParticle log level to be at least Debug)

3. Reference mParticle's integration docs below to enable the integration.

### Documentation

[Adobe integration](https://docs.mparticle.com/integrations/adobe/event/)

### License

[Apache License 2.0](http://www.apache.org/licenses/LICENSE-2.0)
