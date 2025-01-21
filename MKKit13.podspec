Pod::Spec.new do |s|
  s.name             = "MKKit13"
  s.version          = "0.01"
  s.summary          = "MKKit13 summary"
  s.description      = <<-DESC
    MKKit13 desc
  DESC
  s.homepage         = "http://www.xxx.com/"
  s.license          = { :type => "MIT", :file => 'COPYING' }
  s.author           = "MK"
  s.source           = { :git => "https://github.com/mk-wang/mkkit.git", :tag => s.version.to_s }

  s.platform     = :ios, '13.0'

  s.default_subspecs = 'Core', 'SVG', 'Theme', 'KVStroage'

  s.subspec 'Core' do |ss|
    ss.source_files = 'Core/**/*.{h,m,c,swift,hpp}'
    ss.resources = 'Core/**/*.bundle'
    ss.dependency 'MKKit13/Combine'
  end

  s.subspec 'Combine' do |ss|
    ss.source_files = 'Combine/**/*.{h,m,c,swift,hpp}'
    ss.frameworks = "Combine"
  end

  s.subspec 'Theme' do |ss|
    ss.source_files = 'Theme/**/*.{h,m,c,swift,hpp}'
    ss.dependency 'MKKit13/Core'
    ss.dependency 'FluentDarkModeKit'
  end

  s.subspec 'SVG' do |ss|
    ss.source_files = 'SVG/**/*.{h,m,c,swift,hpp}'
    ss.dependency 'SwiftDraw'
    ss.dependency 'MKKit13/Core'
    ss.dependency 'MKKit13/Theme'
  end

  s.subspec 'KVStroage' do |ss|
    ss.source_files = 'KVStroage/Core/**/*.{h,m,c,swift,hpp}'
    ss.dependency 'MKKit13/Core'
  end

  s.subspec 'KVStroageMMKV' do |ss|
    ss.source_files = 'KVStroage/MMKV/**/*.{h,m,c,swift,hpp}'
    ss.dependency 'MMKV'
    ss.dependency 'MKKit13/KVStroage'
    ss.dependency 'MKKit13/Core'
  end

  s.subspec 'SnapKit' do |ss|
    ss.source_files = 'SnapKit/**/*.{h,m,c,swift,hpp}'
    ss.dependency 'SnapKit'
    ss.dependency 'MKKit13/Core'
  end

  s.subspec 'IGListSwiftKit' do |ss|
    ss.source_files = 'IGListSwiftKit/**/*.{h,m,c,swift,hpp}'
    ss.dependency 'IGListKit'
    ss.dependency 'MKKit13/Core'
  end
  
  s.subspec 'IAP' do |ss|
    ss.source_files = 'IAP/**/*.{h,m,c,swift,hpp}'
    ss.frameworks = "StoreKit"
    ss.dependency 'SwiftyStoreKit'
    ss.dependency 'MKKit13/Core'
  end

  s.subspec 'Lottie' do |ss|
    ss.source_files = 'Lottie/**/*.{h,m,c,swift,hpp}'
    ss.dependency 'lottie-ios'
    ss.dependency 'MKKit13/Core'
  end
  
  s.subspec 'YogaKit' do |ss|
    ss.source_files = 'YogaKit/**/*.{h,m,c,swift,hpp}'
    ss.dependency 'YogaKit'
    ss.dependency 'MKKit13/Core'
  end

  s.subspec 'RSwift' do |ss|
    ss.source_files = 'RSwift/**/*.{h,m,c,swift,hpp}'
    ss.dependency 'R.swift'
    ss.dependency 'MKKit13/Core'
  end
  
  s.subspec 'Logger' do |ss|
    ss.source_files = 'Logger/Logger/**/*.{h,m,c,swift,hpp}'
    ss.resources = 'Logger/**/*.bundle'
    ss.dependency 'MKKit13/Core'
    ss.dependency 'MKKit13/KVStroage'
  end
  
  s.subspec 'Logger+DDPrinter' do |ss|
    ss.source_files = 'Logger/DDPrinter/**/*.{h,m,c,swift,hpp}'
    ss.dependency 'CocoaLumberjack'
    ss.dependency 'CocoaLumberjack/Swift'
    ss.dependency 'SSZipArchive'
    ss.dependency 'MKKit13/Logger'
  end
  
  s.subspec 'Database' do |ss|
    ss.source_files = 'Database/**/*.{h,m,c,swift,hpp}'
    ss.dependency 'SQLite.swift'
    ss.dependency 'MKKit13/Core'
  end
end



