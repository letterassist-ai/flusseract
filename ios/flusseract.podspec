#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flusseract.podspec` to validate before publishing.
#

build_tesseract_libs = <<-EOS
!#/bin/bash -ex

plugin_root="$(cd -P $(dirname ${PODS_TARGET_SRCROOT}) && pwd)"
plugin_build_dir=${plugin_root}/build
mkdir -p ${plugin_build_dir}

env > ${plugin_build_dir}/env.log

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

#
# Note: SRCROOT == <Flutter App>/macos/Pod
# The same var availalble within the podspec 
# Ruby code is == <Flutter App>/macos.
#
mkdir -p ${SRCROOT}/flusseract
ln -s ${plugin_build_dir}/dist/${PLATFORM_NAME}/include ${SRCROOT}/flusseract/include
ln -s ${plugin_build_dir}/dist/${PLATFORM_NAME}/lib ${SRCROOT}/flusseract/lib

EOS

Pod::Spec.new do |s|
  s.name             = 'flusseract'
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
    :script => build_tesseract_libs,
    :input_files => [
      '${PODS_TARGET_SRCROOT}/../src/**/*',
    ], 
    :output_files => [
      '${PODS_TARGET_SRCROOT}/../build/dist/${PLATFORM_NAME}/lib/libzstd.a',
      '${PODS_TARGET_SRCROOT}/../build/dist/${PLATFORM_NAME}/lib/libjpeg.a',
      '${PODS_TARGET_SRCROOT}/../build/dist/${PLATFORM_NAME}/lib/libpng.a',
      '${PODS_TARGET_SRCROOT}/../build/dist/${PLATFORM_NAME}/lib/libtiff.a',
      '${PODS_TARGET_SRCROOT}/../build/dist/${PLATFORM_NAME}/lib/libleptonica.a',
      '${PODS_TARGET_SRCROOT}/../build/dist/${PLATFORM_NAME}/lib/libtesseract.a'
    ],
    :execution_position => :before_compile 
  }
  s.xcconfig = {
    'HEADER_SEARCH_PATHS' => '$(inherited) ${PODS_TARGET_SRCROOT}/../build/dist/${PLATFORM_NAME}/include',
    'OTHER_LDFLAGS' => '$(inherited) -all_load',

    # A bug seems to prevent the linker from finding the libraries 
    # as it appears to ignore PODS_TARGET_SRCROOT in the path. But
    # even after creating an absolute path to the libraries the
    # via SRCROOT it still fails as SRCROOT seems to have different
    # paths in the build phase. The following paths were found to work
    # via trial and error.
    'LIBRARY_SEARCH_PATHS' => '$(inherited) ${SRCROOT}/flusseract/lib ${SRCROOT}/Pods/flusseract/lib'
  }
  s.libraries = [
    'z',
    'lzma',
    'zstd',
    'jpeg',
    'png',
    'tiff',
    'leptonica',
    'tesseract'
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
