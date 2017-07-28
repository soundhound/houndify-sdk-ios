
Pod::Spec.new do |s|

  s.name         = "HoundifySDK"
  s.version      = "1.2.1"
  s.summary      = "The official Houndify SDK for iOS to access the Houndify API."

  s.description  = <<-DESC
        HoundifySDK provides:
        * Fast and large scale speech recognition
        * Powerful natural language understanding
        * Rich results covering the most popular domains such as Weather, Sports, Stocks, Hotels, Local Businesses, Home Automation, and more, with data provided from many popular companies including Uber, Yelp, and Expedia
                   DESC

  s.homepage     = "https://www.houndify.com"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Licensing your code is important. See http://choosealicense.com for more info.
  #  CocoaPods will detect a license file if there is a named LICENSE*
  #  Popular ones are 'MIT', 'BSD' and 'Apache License, Version 2.0'.
  #
  s.license      = { :type => "Custom", :file => "LICENSE" }


  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the authors of the library, with email addresses. Email addresses
  #  of the authors are extracted from the SCM log. E.g. $ git log. CocoaPods also
  #  accepts just a name if you'd rather not provide an email address.
  #
  #  Specify a social_media_url where others can refer to, for example a twitter
  #  profile URL.
  #

  s.author             = "SoundHound Inc."
  # s.social_media_url   = "http://twitter.com/"

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If this Pod runs only on iOS or OS X, then specify the platform and
  #  the deployment target. You can optionally include the target after the platform.
  #

  #s.platform     = :ios
  s.platform     = :ios, "8.0"

  #  When using multiple platforms
  # s.ios.deployment_target = "5.0"
  # s.osx.deployment_target = "10.7"
  # s.watchos.deployment_target = "2.0"
  # s.tvos.deployment_target = "9.0"

  s.source = {:git => "https://github.com/soundhound/houndify-sdk-ios.git", :branch => 'master' }
  s.vendored_frameworks = 'HoundifySDK.framework'
  s.requires_arc = true
end
