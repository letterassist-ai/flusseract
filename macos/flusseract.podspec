#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flusseract.podspec` to validate before publishing.
#

build_tesseract_libs = <<-EOS
!#/bin/bash -ex

#
# Note: SRCROOT == <Flutter App>/macos/Pods
#
plugin_build_dir=${SRCROOT}/flusseract/build
mkdir -p ${plugin_build_dir}
env > ${plugin_build_dir}/env.log

plugin_src_root="$(cd -P $(dirname ${PODS_TARGET_SRCROOT}) && pwd)"

pushd ${plugin_build_dir}
cmake ${plugin_src_root}/src && \
  make ${PLATFORM_NAME} \
    2>&1 | tee ${plugin_build_dir}/build.log
popd

rm -f ${SRCROOT}/flusseract/include \
  && ln -s ${plugin_build_dir}/dist/${PLATFORM_NAME}/include ${SRCROOT}/flusseract/include
rm -f ${SRCROOT}/flusseract/lib \
  && ln -s ${plugin_build_dir}/dist/${PLATFORM_NAME}/lib ${SRCROOT}/flusseract/lib

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
      '${SRCROOT}/Pods/flusseract/libzstd.a',
      '${SRCROOT}/Pods/flusseract/libjpeg.a',
      '${SRCROOT}/Pods/flusseract/libpng.a',
      '${SRCROOT}/Pods/flusseract/libtiff.a',
      '${SRCROOT}/Pods/flusseract/libleptonica.a',
      '${SRCROOT}/Pods/flusseract/libtesseract.a'
    ],
    :execution_position => :before_compile 
  }
  s.xcconfig = {
    'HEADER_SEARCH_PATHS' => '$(inherited) ${SRCROOT}/flusseract/include',
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

  s.dependency 'FlutterMacOS'
  s.platform = :osx, '10.14'
  
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
