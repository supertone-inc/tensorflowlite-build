# TensorFlow Lite Build

This project is to build custom [TensorFlow Lite](https://www.tensorflow.org/lite) libraries which are not provided officially.

Currently supports static library builds with the default options only.

## Building Libraries

### Prerequisites

- [CMake](https://cmake.org/install)
- Bash
  - On Windows, you can use Git Bash provided by [Git for Windows](https://git-scm.com/download/win).
- `realpath`
  - On macOS under 13, it can be installed via `brew install coreutils`.

### Build Script

```sh
./build-static-lib.sh
```
