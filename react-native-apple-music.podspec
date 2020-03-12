require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "react-native-apple-music"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.description  = <<-DESC
                  react-native-apple-music
                   DESC
  s.homepage     = "https://github.com/Lemonadd-UG/react-native-apple-music"
  s.license      = "MIT"
  # s.license    = { :type => "MIT", :file => "FILE_LICENSE" }
  s.authors      = { "Your Name" => "yourname@email.com" }
  s.platforms    = { :ios => "11.0" }
  s.source       = { :git => "https://github.com/Lemonadd-UG/react-native-apple-music.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,m,swift}"
  s.requires_arc = true

  s.dependency "React"
  s.dependency 'SwiftJWT'
  s.dependency "PromiseKit", '~> 6.8'
  # ...
  # s.dependency "..."
end