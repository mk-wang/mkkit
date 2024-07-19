Pod::Spec.new do |s|
  s.name             = "MKKit"
  s.version          = "0.01"
  s.summary          = "MKKit summary"
  s.description      = <<-DESC
    MKKit desc
  DESC
  s.homepage         = "http://www.xxx.com/"
  s.license          = { :type => "MIT", :file => 'COPYING' }
  s.author           = "MK"
  s.source           = { :git => "https://github.com/mk-wang/mkkit.git", :tag => s.version.to_s }

  s.platform     = :ios, '11.0'

  s.default_subspecs = 'Core', 'SVG', 'Theme', 'KVStroage'

  s.subspec 'Core' do |ss|
    ss.source_files = 'Core/**/*.{h,m,c,swift,hpp}'
    ss.resources = 'Core/**/*.bundle'
    ss.dependency 'MKKit/Combine'
  end

  s.subspec 'Combine' do |ss|
    ss.source_files = 'Combine/**/*.{h,m,c,swift,hpp}'
    ss.dependency 'OpenCombine'
    ss.dependency 'OpenCombineFoundation'
    ss.dependency 'OpenCombineDispatch'
  end

  s.subspec 'Theme' do |ss|
    ss.source_files = 'Theme/**/*.{h,m,c,swift,hpp}'
    ss.dependency 'MKKit/Core'
    ss.dependency 'FluentDarkModeKit'
    ss.dependency 'OpenCombine'
  end

  s.subspec 'SVG' do |ss|
    ss.source_files = 'SVG/**/*.{h,m,c,swift,hpp}'
    ss.dependency 'SwiftDraw'
    ss.dependency 'MKKit/Core'
  end

  s.subspec 'KVStroage' do |ss|
    ss.source_files = 'KVStroage/Core/**/*.{h,m,c,swift,hpp}'
    ss.dependency 'OpenCombine'
  end

  s.subspec 'KVStroageMMKV' do |ss|
    ss.source_files = 'KVStroage/MMKV/**/*.{h,m,c,swift,hpp}'
    ss.dependency 'MMKV'
    ss.dependency 'MKKit/KVStroage'
  end

  s.subspec 'SnapKit' do |ss|
    ss.source_files = 'SnapKit/**/*.{h,m,c,swift,hpp}'
    ss.dependency 'SnapKit'
    ss.dependency 'MKKit/Core'
  end

  s.subspec 'IGListSwiftKit' do |ss|
    ss.source_files = 'IGListSwiftKit/**/*.{h,m,c,swift,hpp}'
    ss.dependency 'IGListKit'
  end
  
  s.subspec 'IAP' do |ss|
    ss.source_files = 'IAP/**/*.{h,m,c,swift,hpp}'
    ss.frameworks = "StoreKit"
    ss.dependency 'SwiftyStoreKit'
  end

  s.subspec 'Lottie' do |ss|
    ss.source_files = 'Lottie/**/*.{h,m,c,swift,hpp}'
    ss.dependency 'lottie-ios'
  end
  
  s.subspec 'YogaKit' do |ss|
    ss.source_files = 'YogaKit/**/*.{h,m,c,swift,hpp}'
    ss.dependency 'YogaKit'
  end

  s.subspec 'RSwift' do |ss|
    ss.source_files = 'RSwift/**/*.{h,m,c,swift,hpp}'
    ss.dependency 'R.swift'
    ss.dependency 'MKKit/Core'
  end
  
  s.subspec 'Logger' do |ss|
    ss.source_files = 'Logger/Logger/**/*.{h,m,c,swift,hpp}'
    ss.resources = 'Logger/**/*.bundle'
    ss.dependency 'MKKit/Core'
    ss.dependency 'MKKit/KVStroage'
  end
  
  s.subspec 'Logger+DDPrinter' do |ss|
    ss.source_files = 'Logger/DDPrinter/**/*.{h,m,c,swift,hpp}'
    ss.dependency 'CocoaLumberjack'
    ss.dependency 'CocoaLumberjack/Swift'
    ss.dependency 'SSZipArchive'
    ss.dependency 'MKKit/Logger'
  end
  
  s.subspec 'Database' do |ss|
    ss.source_files = 'Database/**/*.{h,m,c,swift,hpp}'
    ss.dependency 'SQLite.swift'
    ss.dependency 'MKKit/Core'
  end
end



