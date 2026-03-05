#!/usr/bin/env python3
"""
向 versions-manifest.json 中指定版本追加蓝奏云下载链接。

用法：
  python3 scripts/update-lanzou.py \
    --version 0.3.2 \
    --manifest versions-manifest.json \
    --android-url "https://wwxx.lanzouq.com/iXXXX" \
    --android-password "abcd" \
    --windows-url "https://wwxx.lanzouq.com/iYYYY" \
    --windows-password "efgh"
"""

import argparse
import json
import sys
from pathlib import Path


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--version', required=True)
    parser.add_argument('--manifest', required=True)
    parser.add_argument('--android-url', default='')
    parser.add_argument('--android-password', default='')
    parser.add_argument('--windows-url', default='')
    parser.add_argument('--windows-password', default='')
    args = parser.parse_args()

    manifest_path = Path(args.manifest)
    manifest = json.loads(manifest_path.read_text(encoding='utf-8'))

    # 查找目标版本
    target = None
    for v in manifest['versions']:
        if v['version'] == args.version:
            target = v
            break

    if target is None:
        sys.exit(f'ERROR: version {args.version} not found in manifest')

    # 更新蓝奏云链接
    if args.android_url:
        if 'android' not in target['assets']:
            target['assets']['android'] = {}
        lanzou = {'url': args.android_url}
        if args.android_password:
            lanzou['password'] = args.android_password
        target['assets']['android']['lanzou'] = lanzou

    if args.windows_url:
        if 'windows' not in target['assets']:
            target['assets']['windows'] = {}
        lanzou = {'url': args.windows_url}
        if args.windows_password:
            lanzou['password'] = args.windows_password
        target['assets']['windows']['lanzou'] = lanzou

    manifest_path.write_text(
        json.dumps(manifest, indent=2, ensure_ascii=False) + '\n',
        encoding='utf-8',
    )
    print(f'Updated lanzou links for version {args.version}.')


if __name__ == '__main__':
    main()
