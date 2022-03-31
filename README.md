# tflite-build
This includes custom build manuals of TensorFlow Lite C++ shard library with XNNPACK and the CLI usage copying built libraries and required headers.

# build TFLite shard library
## macos
### Prerequisites
- python3
  - [pyenv(Recommended)](https://github.com/pyenv/pyenv#homebrew-in-macos)
  - dependent packages
    ```console
    $ pip install -U --user pip numpy wheel packaging
    $ pip install -U --user keras_preprocessing --no-deps
    ```
- Bazel
  - [Bazelisk(Recommended)](https://bazel.build/install/bazelisk)
- CMake 3.16+
### Build
- git clone [TensorFlow repository](https://github.com/tensorflow/tensorflow)
  - checkout v2.7.1 release branch
- change bazel version to 4.2.1
  - `.bazelversion`  
    ```
    4.2.1
    ```
- configure and build
  ```console
  $ cd tensorflow
  $ ./configure
  $ bazel build -s -c opt \
    --define tflite_with_xnnpack=true \
    --define tflite_keep_symbols=true \
    //tensorflow/lite:libtensorflowlite.dylib
  ```
- copy library and headers
  ```console
  $ cd tflite-build
  $ ./tflite.py -o macos -a x86_64 copy ../tensorflow
  ```
  m1 mac
  ```
  $ ./tflite.py -o macos -a arm64 copy ../tensorflow
  ```
### Test
- configure & build
  ```console
  $ cd tflite-build
  $ cmake -S . -B build
  $ cmake --build build
  ```
- run
  ```console
  $ ./build/TFLiteBuildCheck ./models/ssd_mobilenet_v1_1_metadata_1.tflite 
  ```

## linux
### Prerequisites
- python3
  - dependent packages
    ```console
    $ pip install -U --user pip numpy wheel packaging
    $ pip install -U --user keras_preprocessing --no-deps
    ```
- Bazel
  - [Bazelisk(Recommended)](https://bazel.build/install/bazelisk)
- CMake 3.16+
### Build
- git clone [TensorFlow repository](https://github.com/tensorflow/tensorflow)
  - checkout v2.7.1 release branch
- change bazel version to 4.2.1
  - `.bazelversion`  
    ```
    4.2.1
    ```
- configure and build
  ```console
  $ cd tensorflow
  $ ./configure.py
  $ bazel build -s -c opt \
    --define tflite_with_xnnpack=true \
    --define tflite_keep_symbols=true \
    //tensorflow/lite:libtensorflowlite.so
  ```
- copy library and headers
  ```console
  $ cd tflite-build
  $ ./tflite.py -o linux -a x86_64 copy ../tensorflow
  ```
  arm64
  ```
  $ ./tflite.py -o macos -a aarch64 copy ../tensorflow
  ```
### Test
- configure & build
  ```console
  $ cd tflite-build
  $ cmake -S . -B build
  $ cmake --build build
  ```
- run
  ```console
  $ ./build/TFLiteBuildCheck ./models/ssd_mobilenet_v1_1_metadata_1.tflite 
  ```

## windows(x64)
### Prerequisites
- python3
  - dependent packages
    ```cmd
    c:\> pip3 install -U --user six numpy wheel packaging
    c:\> pip3 install -U --user keras_preprocessing --no-deps
    ```
- Bazel
  - [Bazelisk(Recommended)](https://docs.bazel.build/versions/main/install-bazelisk.html)
    - Add to PATH environment variable
- MSYS2
  - [MSYS2](https://www.msys2.org/)
    ```cmd
    c:\> pacman -S git patch unzip
    ```
- Visual C++ Build Tools 2019
  - [Visual Studio 2019 and other Products](https://my.visualstudio.com/Downloads?q=Visual%20Studio%202019)
    - Visual C++ Redistributable for Visual Studio 2019 (version 16.11) x64
    - Build Tools for Visual Studio 2019 (version 16.11) x64
      - In the "Workloads" tab enable "Desktop development with C++"
- CMake 3.16+
### Build
- git clone [TensorFlow repository](https://github.com/tensorflow/tensorflow)
  - checkout v2.7.1 release branch
- configure and build
  ```cmd
  c:\> cd tensorflow
  c:\tensorflow> python .\configure.py
  c:\tensorflow> bazel build -s -c opt `
    --define tflite_with_xnnpack=true `
    --define tflite_keep_symbols=true `
    //tensorflow/lite:tensorflowlite.dll
  ```
- copy library and headers
  ```cmd
  c:\> cd tflite-build
  c:\tflite-build> python tflite.py -o windows -a x86_64 copy ..\tensorflow
  ```
### Test
- configure & build
  ```cmd
  c:\tflite-build> cmake -S . -B .\build -G "Visual Studio 16 2019" -T host=x64 -A x64
  c:\tflite-build> cmake --build .\build  --config Release
  ```
- run
  ```cmd
  c:\tflite-build> .\build\Release\TFLiteBuildCheck.exe .\models\ssd_mobilenet_v1_1_metadata_1.tflite
  ```

# References
- [Build Tensorflow from source on Ubuntu, macOS](https://www.tensorflow.org/install/source)
- [Build Tensorflow from source on Windows](https://www.tensorflow.org/install/source_windows)
- [TensorFlow Lite C++ Series](https://www.youtube.com/playlist?list=PLYV_j9XEhvorTV-ClcNA2xUb5YsdUHgRX)