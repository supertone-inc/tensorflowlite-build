# tflite-build
This includes custom build manuals of TensorFlow Lite C++ shard library with XNNPACK and the CLI usage copying built libraries and required headers.

## build TFLite shard library
### macos
#### Prerequisites
- python3
  - [pyenv(Recommended)](https://github.com/pyenv/pyenv#homebrew-in-macos)
  - dependent packages
    ```console
    $ pip install -U --user pip numpy wheel packaging
    $ pip install -U --user keras_preprocessing --no-deps
    ```
- Bazel
  - [Bazelisk(Recommended)](https://bazel.build/install/bazelisk)
#### Build
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

### linux
#### Prerequisites
- python3
  - dependent packages
    ```console
    $ pip install -U --user pip numpy wheel packaging
    $ pip install -U --user keras_preprocessing --no-deps
    ```
- Bazel
  - [Bazelisk(Recommended)](https://bazel.build/install/bazelisk)
#### Build
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

### windows(x64)
#### Prerequisites
- python3
  - dependent packages
    ```cmd
    c:\> pip3 install -U --user six numpy wheel packaging
    c:\> pip3 install -U --user keras_preprocessing --no-deps
    ```
- Bazel
  - [Bazel v4.2.1](https://github.com/bazelbuild/bazel/releases/tag/4.2.1)
- MSYS2
  - [MSYS2](https://www.msys2.org/)
    ```cmd
    c:\> pacman -S git patch unzip
    ```
- Visual C++ Build Tools 2019
  - [Visual Studio 2019 and other Products](https://my.visualstudio.com/Downloads?q=Visual%20Studio%202019)
    - Visual C++ Redistributable for Visual Studio 2019 (version 16.11) x64
    - Build Tools for Visual Studio 2019 (version 16.11) x64
#### Build
- git clone [TensorFlow repository](https://github.com/tensorflow/tensorflow)
  - checkout v2.7.1 release branch
- change bazel version to 4.2.1
  - `.bazelversion`  
    ```
    4.2.1
    ```
- configure and build
  ```cmd
  c:\> cd tensorflow
  c:\> python ./configure
  c:\> bazel build -s -c opt \
    --define tflite_with_xnnpack=true \
    --define tflite_keep_symbols=true \
    //tensorflow/lite:tensorflowlite
  ```
- copy library and headers
  ```cmd
  c:\> cd tflite-build
  c:\> python ./tflite.py -o windows -a x86_64 copy ../tensorflow
  ```

## References
- [Build Tensorflow from source on Ubuntu, macOS](https://www.tensorflow.org/install/source)
- [Build Tensorflow from source on Windows](https://www.tensorflow.org/install/source_windows)
- [TensorFlow Lite C++ Series](https://www.youtube.com/playlist?list=PLYV_j9XEhvorTV-ClcNA2xUb5YsdUHgRX)