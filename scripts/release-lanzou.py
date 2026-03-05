#!/usr/bin/env python3
"""Supplement Lanzou links for an existing release version.

Usage examples:
  python scripts/release-lanzou.py
  python scripts/release-lanzou.py --version 0.3.3
  python scripts/release-lanzou.py --manifest versions-manifest.json

Behavior:
  1. Load versions-manifest.json.
  2. Pick target version:
     - `--version` if provided.
     - Otherwise the newest version missing Lanzou links for android/windows.
  3. Prompt Lanzou URL/password for android and windows (Enter keeps current).
  4. Update manifest in place.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

MANIFEST_DEFAULT = 'versions-manifest.json'
SUPPORTED_PLATFORMS = ('android', 'windows')


def die(message: str) -> None:
    print(f'ERROR: {message}', file=sys.stderr)
    raise SystemExit(1)


def ask(prompt: str, default: str = '') -> str:
    suffix = f' [{default}]' if default else ''
    value = input(f'{prompt}{suffix}: ').strip()
    return value or default


def load_manifest(path: Path) -> dict:
    if not path.exists():
        die(f'manifest not found: {path}')
    try:
        return json.loads(path.read_text(encoding='utf-8'))
    except json.JSONDecodeError as exc:
        die(f'invalid manifest json: {exc}')


def validate_semver(version: str) -> None:
    if not re.match(r'^\d+\.\d+\.\d+$', version):
        die(f'invalid version format: {version}, expected x.y.z')


def has_lanzou(entry: dict, platform: str) -> bool:
    platform_assets = entry.get('assets', {}).get(platform, {})
    lanzou = platform_assets.get('lanzou')
    return isinstance(lanzou, dict) and bool(lanzou.get('url'))


def find_target_entry(manifest: dict, version: str | None) -> dict:
    versions = manifest.get('versions', [])
    if not isinstance(versions, list) or not versions:
        die('manifest has no versions')

    if version:
        validate_semver(version)
        for entry in versions:
            if entry.get('version') == version:
                return entry
        die(f'version {version} not found in manifest')

    # Manifest keeps latest first. Pick first entry that is not fully supplemented.
    for entry in versions:
        if any(not has_lanzou(entry, platform) for platform in SUPPORTED_PLATFORMS):
            return entry

    die('all versions already have Lanzou links for android/windows')


def upsert_lanzou(entry: dict, platform: str) -> bool:
    assets = entry.setdefault('assets', {})
    platform_assets = assets.get(platform)
    if not isinstance(platform_assets, dict):
        print(f'Skip {platform}: missing assets.{platform} in manifest.')
        return False

    current_lanzou = platform_assets.get('lanzou')
    current_url = ''
    current_password = ''
    if isinstance(current_lanzou, dict):
        current_url = str(current_lanzou.get('url', '')).strip()
        current_password = str(current_lanzou.get('password', '')).strip()

    print(f'\n[{platform}]')
    url = ask('Lanzou share URL (empty keeps current)', current_url)
    if not url:
        print('No URL provided, keep unchanged.')
        return False

    password = ask('Extraction password (empty means no password)', current_password)

    lanzou = {'url': url}
    if password:
        lanzou['password'] = password

    if isinstance(current_lanzou, dict):
        normalized_current = {'url': str(current_lanzou.get('url', '')).strip()}
        current_pwd = str(current_lanzou.get('password', '')).strip()
        if current_pwd:
            normalized_current['password'] = current_pwd
        if lanzou == normalized_current:
            print('No changes for this platform.')
            return False

    platform_assets['lanzou'] = lanzou
    return True


def save_manifest(path: Path, manifest: dict) -> None:
    path.write_text(
        json.dumps(manifest, indent=2, ensure_ascii=False) + '\n',
        encoding='utf-8',
    )


def main() -> None:
    parser = argparse.ArgumentParser(
        description='Supplement Lanzou links for an existing release in versions-manifest.json.',
    )
    parser.add_argument(
        '--version',
        help='Target version (x.y.z). Default: newest version missing Lanzou links.',
    )
    parser.add_argument(
        '--manifest',
        default=MANIFEST_DEFAULT,
        help=f'Manifest path (default: {MANIFEST_DEFAULT}).',
    )
    args = parser.parse_args()

    manifest_path = Path(args.manifest)
    manifest = load_manifest(manifest_path)
    entry = find_target_entry(manifest, args.version)

    version = entry.get('version', '<unknown>')
    build = entry.get('build', '<unknown>')
    print(f'Target version: {version}+{build}')

    changed = False
    for platform in SUPPORTED_PLATFORMS:
        changed = upsert_lanzou(entry, platform) or changed

    if not changed:
        print('\nNo changes made.')
        return

    save_manifest(manifest_path, manifest)
    print(f'\nUpdated manifest: {manifest_path}')


if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        print('\nCancelled.')
        raise SystemExit(130)
