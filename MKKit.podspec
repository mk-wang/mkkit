Pod::Spec.new do |s|
  s.name             = "MKKit"
  s.version          = "0.01"
  s.summary          = "MKKit summary"
  s.description      = <<-DESC
    MKKit desc
  DESC
  s.homepage         = "http://www.mupdf.com/"
  s.license          = { :type => "Affero GNU GPL v3", :file => 'COPYING' }
  s.author           = "Artifex Software Inc"
  s.source           = { :git => "https://github.com/ArtifexSoftware/mupdf.git", :tag => s.version.to_s }

  s.platform     = :ios, '11.0'

  s.default_subspecs = 'Core', 'SVG', 'KVStroage', 'InjectionIII', 'SnapKit'

  s.subspec 'Core' do |ss|
    ss.source_files = 'Core/**/*.{h,m,c,swift,hpp}'
    ss.dependency 'OpenCombine'
    ss.dependency 'OpenCombineFoundation'
    ss.dependency 'FluentDarkModeKit'
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
end

