Pod::Spec.new do |s|
  s.name         = "LEDPayment"
  s.version      = "0.30"
  s.summary      = "Frameworks that helps you to build awasome projects."
  s.description  = <<-DESC
                    With this framework can fastly build MVP projects with all nessesary product code.
                   DESC
  s.homepage     = "https://github.com/azimin/LEDFrameworks"
  s.license      = "MIT"
  s.author             = { "Alexander Zimin" => "azimin@me.com" }

  s.ios.deployment_target = '11.0'
  s.source   = {
    :git => 'https://github.com/azimin/LEDFrameworks.git',
    :tag => s.version.to_s
  }
  s.swift_version = '5.0'
  s.source_files = 'LEDPayment/**/*.swift'
  s.dependency 'LEDAnalytics'
  s.dependency 'SwiftyStoreKit'
end
