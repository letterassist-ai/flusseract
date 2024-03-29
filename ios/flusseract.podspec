#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint user.podspec` to validate before publishing.
#

build_go_source = <<-EOS
!#/bin/bash

plugin_root="$(cd -P $(dirname ${PODS_TARGET_SRCROOT}) && pwd)"
plugin_build_dir=${plugin_root}/build
mkdir -p ${plugin_build_dir}

pushd ${plugin_build_dir}
cmake ../src && \
  make \
    libzstd-${PLATFORM_NAME} \
    libjpeg-${PLATFORM_NAME} \
    libpng-${PLATFORM_NAME} \
    libtiff-${PLATFORM_NAME} \
    libleptonica-${PLATFORM_NAME} \
    libtesseract-${PLATFORM_NAME} \
    2>&1 | tee ${plugin_build_dir}/build.log
popd

EOS

Pod::Spec.new do |s|
  s.name             = 'user'
  s.version          = '0.0.1'
  s.summary          = 'Flutter plugin for Tesseract OCR library.'
  s.description      = <<-DESC
Flutter Tesseract OCR FFI plugin library.
                       DESC
  s.homepage         = '"https://github.com/letterassist-ai/flusseract'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Mevan Samaratunga' => 'mevan.samaratunga@letterassist.ai' }

  # This will ensure the source files in Classes/ are included in the native
  # builds of apps using this FFI plugin. Podspec does not support relative
  # paths, so Classes contains a forwarder C file that relatively imports
  # `../src/*` so that the C sources can be shared among all target platforms.
  s.source              = { :path => '.' }
  s.source_files        = 'Classes/**/*'
  s.public_header_files = '${PODS_TARGET_SRCROOT}/../src/*.h'

  s.script_phase = { 
    :name => 'Build Flusseract Source', 
    :script => build_go_source,
    :input_files => [
      '${PODS_TARGET_SRCROOT}/../src/**/*',
    ], 
    :output_files => [
      '${PODS_TARGET_SRCROOT}/../build/dist/${PLATFORM_NAME}/lib/libtessearct.a'
    ],
    :execution_position => :before_compile 
  }
  s.vendored_libraries = '${PODS_TARGET_SRCROOT}/../build/dist/${PLATFORM_NAME}/lib/libtessearct.a'
  s.xcconfig = {
    'HEADER_SEARCH_PATHS' => '$(inherited) "${PODS_TARGET_SRCROOT}/../build/dist/${PLATFORM_NAME}/lib/include"',
    'LIBRARY_SEARCH_PATHS' => '$(inherited) "$(PODS_TARGET_SRCROOT)/../build/dist/${PLATFORM_NAME}/lib"',
    'OTHER_LDFLAGS' => '$(inherited) -all_load'
  }
  s.libraries = [
    'liblzma',
    'libzstd',
    'libzstd',
    'libjpeg',
    'libpng',
    'libtiff',
    'libleptonica',
    'libtesseract'
  ]
  
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 
    'DEFINES_MODULE' => 'YES', 
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' 
  }
  s.swift_version = '5.0'
end
