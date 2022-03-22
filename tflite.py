#!/usr/bin/env python3

import argparse
from operator import itemgetter

default_tflite_version = '2.7.1'


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--version', '-v', action='store',
                        help='tflite version(default: {})'.format(default_tflite_version), default=default_tflite_version)
    parser.add_argument('--os', '-o', help='os name',
                        choices=['windows', 'linux', 'macos'], required=True)
    parser.add_argument('--arch', '-a', help='arch name',
                        choices=['x86', 'x86_64', 'arm64'], required=True)

    subparsers = parser.add_subparsers(dest='command', help='command')
    copy_parser = subparsers.add_parser(
        'copy', help='copy header and library files')
    copy_parser.add_argument(
        'source', action='store', help='tflite source path')

    delete_parser = subparsers.add_parser(
        'delete', help='delete header and library files')

    return parser.parse_args()


def main():
    args = vars(parse_args())
    command, os_name, arch_name, tflite_version, tflite_source_path = (args.get(k) for k in (
        'command', 'os', 'arch', 'version', 'source'))
    print('-' * 80)
    print('command: {}\nos: {}\narch: {}\ntflite version: {}\ntflite source path: {}'.format(
        command, os_name, arch_name, tflite_version, tflite_source_path))
    print('-' * 80)

    if command == 'copy':  # copy command
        None
    else:  # delete command
        None


if __name__ == "__main__":
    main()
