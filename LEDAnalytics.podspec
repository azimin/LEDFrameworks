Pod::Spec.new do |s|
  s.name         = "LEDAnalytics"
  s.version      = "0.23"
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
  s.source_files = 'LEDAnalytics/**/*.swift'

  s.dependency 'LEDProductCore'
  s.dependency 'FacebookCore'
  s.dependency 'Amplitude-iOS'
  s.dependency 'SimpleKeychain'
end
