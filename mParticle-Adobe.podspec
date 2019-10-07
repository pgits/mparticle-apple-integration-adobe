Pod::Spec.new do |s|
    s.name             = "mParticle-Adobe"
    s.version          = "7.11.0"
    s.summary          = "Adobe integration for mParticle"

    s.description      = <<-DESC
                       This is the Adobe integration for mParticle.
                       DESC

    s.homepage         = "https://www.mparticle.com"
    s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
    s.author           = { "mParticle" => "support@mparticle.com" }
    s.source           = { :git => "https://github.com/mparticle-integrations/mparticle-apple-integration-adobe.git", :tag => s.version.to_s }
    s.social_media_url = "https://twitter.com/mparticle"

    s.static_framework = true

    s.subspec 'Adobe' do |ss|
        ss.ios.deployment_target = "8.0"
        ss.ios.source_files      = 'mParticle-Adobe/*.{h,m}'
        ss.ios.dependency 'mParticle-Apple-SDK/mParticle', '~> 7.11.0'
    s.ios.framework = 'UIKit'
    end

    s.subspec 'AdobeMedia' do |ss|
        ss.ios.deployment_target = "9.0"
        ss.ios.source_files      = 'mParticle-Adobe-Media/*.{h,m}'
        ss.ios.dependency 'mParticle-Apple-SDK', '~> 7.11.0'
        ss.ios.dependency 'mParticle-Apple-Media', '~> 1.0.0-beta.1'
        ss.ios.dependency 'ACPMedia', '~> 1.0'
        ss.ios.dependency 'ACPAnalytics', '~> 2.0'
        ss.ios.dependency 'ACPCore', '~> 2.0'
        ss.ios.dependency 'ACPUserProfile', '~> 2.0'
    end
end
