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
  s.source           = { :git => "https://github.com/ArtifexSoftware/mupdf.git", :tag => s.version.to_s }

  s.platform     = :ios, '11.0'

  s.default_subspecs = 'Core', 'SVG', 'KVStroage', 'InjectionIII'

  s.subspec 'Core' do |ss|
    ss.source_files = 'Core/**/*.{h,m,c,swift,hpp}'
    ss.resources = 'Core/**/*.bundle'
    ss.dependency 'OpenCombine'
    ss.dependency 'OpenCombineFoundation'
    ss.dependency 'FluentDarkModeKit'
    ss.dependency 'AsyncSwift'
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

  s.subspec 'InjectionIII' do |ss|
    ss.source_files = 'InjectionIII/**/*.{h,m,c,swift,hpp}'
  end  

  s.subspec 'SnapKit' do |ss|
    ss.source_files = 'SnapKit/**/*.{h,m,c,swift,hpp}'
    ss.dependency 'SnapKit'
  end

  s.subspec 'IGListSwiftKit' do |ss|
    ss.source_files = 'IGListSwiftKit/**/*.{h,m,c,swift,hpp}'
    ss.dependency 'IGListKit'
  end
  
  s.subspec 'IAP' do |ss|
    ss.source_files = 'IAP/**/*.{h,m,c,swift,hpp}'
    ss.frameworks = "CryptoKit"
    ss.dependency 'SwiftyStoreKit'
  end

  s.subspec 'YogaKit' do |ss|
    ss.source_files = 'YogaKit/**/*.{h,m,c,swift,hpp}'
    ss.dependency 'YogaKit'
  end
end

