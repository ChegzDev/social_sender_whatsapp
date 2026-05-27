#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint social_sender_whatsapp.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'social_sender_whatsapp'
  s.version          = '0.0.1'
  s.summary          = 'A Flutter plugin to send WhatsApp messages and share files.'
  s.description      = <<-DESC
A Flutter plugin for sending WhatsApp messages and sharing files directly to specific phone numbers or via a general share sheet on both Android and iOS.
                       DESC
  s.homepage         = 'https://github.com/ChegzDev/social_sender_whatsapp'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'ChegzDev' => 'chegz.dev@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'social_sender_whatsapp/Sources/social_sender_whatsapp/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'social_sender_whatsapp_privacy' => ['social_sender_whatsapp/Sources/social_sender_whatsapp/PrivacyInfo.xcprivacy']}
end
