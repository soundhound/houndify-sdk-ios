
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
  s.license      = { :type => "Custom", :file => "LICENSE" }
  s.author             = "SoundHound Inc."

  s.platform     = :ios, "8.0"

  s.source = {:git => "https://github.com/soundhound/houndify-sdk-ios.git", :branch => 'master' }
  s.vendored_frameworks = 'HoundifySDK.framework'
  s.requires_arc = true
  
end
