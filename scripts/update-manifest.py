#!/usr/bin/env python3
"""
CI 发布后自动更新 versions-manifest.json。

用法：
  python3 scripts/update-manifest.py --tag v0.3.2 --manifest versions-manifest.json

功能：
  1. 从 pubspec.yaml 读取 version (含 build number)
  2. 从 tag 名提取 semver
  3. 检查 manifest 中是否已存在该版本
  4. 若不存在，自动生成 GitHub 下载链接并追加到 manifest
  5. 更新 latest 字段
"""

import argparse
import json
import re
import sys
from datetime import date
from pathlib import Path

OWNER = 'GlowLED'
REPO = 'BuSic'

PLATFORM_ASSETS = {
    'android': 'busic-android.apk',
    'windows': 'busic-windows-x64.zip',
    'linux': 'busic-linux-x64.tar.gz',
    'macos': 'busic-macos.zip',
}


def parse_pubspec_version(pubspec_path: str) -> tuple[str, int]:
    """从 pubspec.yaml 解析 version 字段，返回 (semver, build)。"""
    content = Path(pubspec_path).read_text(encoding='utf-8')
    match = re.search(r'^version:\s*(\S+)', content, re.MULTILINE)
    if not match:
        sys.exit('ERROR: version not found in pubspec.yaml')
    version_str = match.group(1)
    if '+' in version_str:
        semver, build = version_str.split('+', 1)
        return semver, int(build)
    return version_str, 0


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--tag', required=True, help='Git tag (e.g. v0.3.2)')
    parser.add_argument('--manifest', required=True, help='Path to versions-manifest.json')
    parser.add_argument('--pubspec', default='pubspec.yaml', help='Path to pubspec.yaml')
    args = parser.parse_args()

    tag = args.tag.lstrip('v')
    semver, build = parse_pubspec_version(args.pubspec)

    # 验证 tag 与 pubspec 版本一致
    if tag != semver:
        sys.exit(f'ERROR: tag v{tag} does not match pubspec version {semver}')

    # 读取现有 manifest
    manifest_path = Path(args.manifest)
    if manifest_path.exists():
        manifest = json.loads(manifest_path.read_text(encoding='utf-8'))
    else:
        manifest = {'latest': '', 'min_supported': '0.2.0', 'versions': []}

    # 检查是否已存在
    existing = [v for v in manifest['versions'] if v['version'] == semver]
    if existing:
        print(f'Version {semver} already exists in manifest, skipping.')
        return

    # 生成 GitHub 下载链接
    assets = {}
    for platform, filename in PLATFORM_ASSETS.items():
        assets[platform] = {
            'github': f'https://github.com/{OWNER}/{REPO}/releases/download/v{semver}/{filename}'
        }

    # 新版本条目
    entry = {
        'version': semver,
        'build': build,
        'date': date.today().isoformat(),
        'changelog': '',
        'force_update_below': manifest.get('min_supported', '0.2.0'),
        'assets': assets,
    }

    # 插入到列表头部（最新版本在前）
    manifest['versions'].insert(0, entry)
    manifest['latest'] = semver

    # 写回
    manifest_path.write_text(
        json.dumps(manifest, indent=2, ensure_ascii=False) + '\n',
        encoding='utf-8',
    )
    print(f'Added version {semver}+{build} to manifest.')


if __name__ == '__main__':
    main()
