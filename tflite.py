#!/usr/bin/env python3

import argparse
from operator import itemgetter
import os
import glob
import pathlib
import shutil
import sys
import re
import errno
import stat

default_tflite_version = '2.7.1'
tflite_dist = 'tflite-dist'
libs = [
    ('bazel-bin/tensorflow/lite/libtensorflowlite.so', 'linux'),
    ('bazel-bin/tensorflow/lite/libtensorflowlite.dylib', 'macos'),
    ('bazel-bin/tensorflow/lite/tensorflowlite.dll', 'windows'),
]
includes = [
    ('tensorflow/core/public/version.h', 'tensorflow/core/public'),
    ('tensorflow/lite/*.h', 'tensorflow/lite'),
    ('tensorflow/lite/c/*.h', 'tensorflow/lite/c'),
    ('tensorflow/lite/core/*.h', 'tensorflow/lite/core'),
    ('tensorflow/lite/core/api/*.h', 'tensorflow/lite/core/api'),
    ('tensorflow/lite/schema/*.h', 'tensorflow/lite/schema'),
    ('tensorflow/lite/internal/*.h', 'tensorflow/lite/internal',),
    ('tensorflow/lite/kernels/*.h', 'tensorflow/lite/kernels'),
    ('tensorflow/lite/experimental/resource/*.h',
     'tensorflow/lite/experimental/resource'),
    ('bazel-bin/external/flatbuffers/_virtual_includes/flatbuffers/flatbuffers/*.h', 'flatbuffers'),
]


def parse_args(argv):
    prog = argv[0]
    args = argv[1:]

    parser = argparse.ArgumentParser(prog)
    parser.add_argument('--version', '-v', action='store',
                        help='tflite version(default: {})'.format(default_tflite_version), default=default_tflite_version)
    parser.add_argument('--os', '-o', help='os name',
                        choices=['windows', 'linux', 'macos'], required=True)
    parser.add_argument('--arch', '-a', help='arch name',
                        choices=['x86', 'x86_64', 'arm64', 'aarch64'], required=True)

    subparsers = parser.add_subparsers(dest='command', help='command')
    copy_parser = subparsers.add_parser(
        'copy', help='copy header and library files')
    copy_parser.add_argument(
        'source', action='store', help='tflite source path')

    delete_parser = subparsers.add_parser(
        'delete', help='delete header and library files')

    return parser.parse_args(args)

def handleRemoveReadonly(func, path, exc):
    excvalue = exc[1]
    if func in (os.unlink, os.rmdir, os.remove) and excvalue.errno == errno.EACCES:
        os.chmod(path, stat.S_IRWXU| stat.S_IRWXG| stat.S_IRWXO) # 0777
        func(path)
    else:
        raise

def delete(path):
    if os.path.exists(path):
        print('-' * 80)
        print('>> delete {}'.format(path))
        shutil.rmtree(path, ignore_errors=False, onerror=handleRemoveReadonly)

def glob_re(pattern, strings):
    return filter(re.compile(pattern).fullmatch, strings)

def main():
    # parse arguments
    args = vars(parse_args(sys.argv))
    command, os_name, arch_name, tflite_version, tflite_source_dir = (args.get(k) for k in (
        'command', 'os', 'arch', 'version', 'source'))

    # change working directory to project root
    working_dir = pathlib.Path(__file__).parent.resolve()
    os.chdir(working_dir)

    print('-' * 80)
    print('>> change working directory to {}'.format(working_dir))

    tflite_dist_dir = os.path.relpath(os.path.join(
        working_dir, tflite_dist, tflite_version, '{}-{}'.format(os_name, arch_name)), working_dir)
    include_dir = os.path.relpath(os.path.join(
        tflite_dist_dir, 'include'), working_dir)
    lib_dir = os.path.relpath(os.path.join(
        tflite_dist_dir, 'lib'), working_dir)

    print('-' * 80)
    print('command: {}\nos: {}\narch: {}\ntflite version: {}\ntflite source path: {}'.format(
        command, os_name, arch_name, tflite_version, tflite_source_dir))
    print('tflite dist root: {}'.format(tflite_dist_dir))
    print('tflite dist lib: {}'.format(lib_dir))
    print('tflite dist include: {}'.format(include_dir))

    if command == 'copy':  # copy command
        delete(tflite_dist_dir)

        os.makedirs(lib_dir, exist_ok=True)
        os.makedirs(include_dir, exist_ok=True)

        print('-' * 80)
        print('>> copy library')

        for source in [s for s, o in libs if o == os_name]:
            source_pattern = os.path.join(tflite_source_dir, source)
            target_dir = lib_dir
            print('{} -> {}'.format(source_pattern, target_dir))

            os.makedirs(target_dir, exist_ok=True)

            for file in sorted(glob.glob(source_pattern)):
                shutil.copy(file, target_dir)

        print('-' * 80)
        print('>> copy headers')

        for source, target in includes:
            source_pattern = os.path.join(tflite_source_dir, source)
            target_dir = os.path.join(include_dir, target)
            print('{} -> {}'.format(source_pattern, target_dir))

            os.makedirs(target_dir, exist_ok=True)

            for file in sorted(glob.glob(source_pattern)):
                shutil.copy(file, target_dir)

    else:  # delete command
        delete(tflite_dist_dir)


if __name__ == "__main__":
    main()
