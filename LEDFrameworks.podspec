Pod::Spec.new do |s|
  s.name         = "LEDFrameworks"
  s.version      = "0.1"
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
  
  s.subspec 'LEDHelpers' do |helpers|
    helpers.source_files = 'LEDHelpers/**/*.swift'
    helpers.swift_version = '5.0'
  end

  s.subspec 'LEDCore' do |core|
    core.dependency 'LEDFrameworks/LEDHelpers'
    core.source_files = 'LEDCore/**/*.swift'
    core.swift_version = '5.0'
  end

end
