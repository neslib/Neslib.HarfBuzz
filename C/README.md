# Building the native HarfBuzz libraries

This is internal documentation. It gives a short bullet point descriptions for building the HarfBuzz libraries. For details information, see https://harfbuzz.github.io/building.html.

We use CMake although this will be deprecated in the future in favor of Meson.

## Windows

* Use CMake GUI. After Configure:
  * Uncheck all `HB_*` entries.
  * Add a Boolean `BUILD_SHARED_LIBS` entry and check it.
  * Update `CMAKE_CXX_FLAGS_RELEASE` and `CMAKE_C_FLAGS_RELEASE` by replacing `/MD` with `/MT` and adding `/DHB_TINY`.
* Configure again.
* Generate the solution.
* Open and build the solution in Visual Studio.

## macOS

* Use CMake GUI. After Configure:
  * Uncheck all `HB_*` entries.
  * Set `CMAKE_OSX_DEPLOYMENT_TARGET` to 10.13
  
* Configure again.
* Press Generate.
* Open project.
* Choose the "harfbuzz" project in the sidebar and sub-sidebar.
* Under "Build Settings", set "Architectures" to "Standard Architectures", and set "Build Active Architecture Only" to "No" (for all configurations).
* Also under "Build Settings", under "Apple Clang - Preprocessing", add the `HB_TINY` define to the Release configuration.
* In Xcode, choose "Product | Scheme | Edit Scheme.." and select the "harfbuzz" project.
* Select the "Run" scheme and set Build Configuration to Release. Do the same for the "ALL_BUILD" project.
* Choose "Product | Build For | Running"
* In the project view, expand the "Products" node to locate the "libharfbuzz.a" file. Right click it and select "Show in Finder". Copy and rename this file to "libHarfBuzz_macos.a".

## iOS

* Use CMake GUI. 
* When pressing "Configure", choose "Specify options for cross-compiling".
* On the next page, set "Operating System" to "iOS" (case sensitive) and "Version" to "12.0"
* After Configure, set:
  * Uncheck all `HB_*` entries.
  * Set `CMAKE_OSX_DEPLOYMENT_TARGET` to 12.0 (add if needed)
  
* Configure again.
* Press Generate.
* Open project.
* Choose the "harfbuzz" project in the sidebar and sub-sidebar.
* Under "Build Settings", under "Apple Clang - Preprocessing", add the `HB_TINY` define to the Release configuration.
* In Xcode, choose "Product | Scheme | Edit Scheme.." and select the "harfbuzz" project.
* Select the "Run" scheme and set Build Configuration to Release. Do the same for the "ALL_BUILD" project.
* Choose "Product | Build For | Running"
* In the project view, expand the "Products" node to locate the "libharfbuzz.a" file. Right click it and select "Show in Finder". Copy and rename this file to "libHarfBuzz_ios.a".

## Android

### 32-Bit

* Use CMake GUI.
* When pressing "Configure", set the generator to "Ninja" and choose "Specify toolchain for cross-compiling".
* On next page, select the "android.toolchain.cmake" file from your NDK directory (eg. "C:/Users/Public/Documents/Embarcadero/Studio/23.0/CatalogRepository/AndroidSDK-2525-23.0.55362.2017/ndk/27.1.12297006/build/cmake/android.toolchain.cmake").
* After Configure:

  * Uncheck all `HB_*` entries.
  * Set `CMAKE_BUILD_TYPE` to `Release`
  * Set `CMAKE_CXX_FLAGS_RELEASE` and `CMAKE_C_FLAGS_RELEASE` to `-DHB_TINY` (do *not* add any `-O2` or `-DNDEBUG` flags!)

* And add the following options:
  * `ANDROID_ABI`: armeabi-v7a
  * `ANDROID_PLATFORM`: android-16
* Configure again.

* Press Generate.
* Open a command prompt in the build directory and enter `Ninja`.
* Once the static library has been generated, strip the debug symbols using `strip -g`, where the strip command is part of the NDK. For example: 
  ```Shell
  C:\Users\Public\Documents\Embarcadero\Studio\23.0\CatalogRepository\AndroidSDK-2525-23.0.55362.2017\ndk\27.1.12297006\toolchains\llvm\prebuilt\windows-x86_64\bin\llvm-strip.exe -g libharfbuzz.a
  ```
* Rename the library to "libHarfBuzz_android32.a"

### 64-Bit

Use same steps as above with the following changes:

* Set ANDROID_ABI to : arm64-v8a
* Configure, Generate, Ninja and Strip as for the 32-bit version.
* Rename the library to "libHarfBuzz_android64.a"
