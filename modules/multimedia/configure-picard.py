"""Apply audited Picard defaults without replacing credentials or Qt UI state.

The INI remains writable by Picard. Preserve the pre-migration configuration
in XDG state with private permissions before changing named QSettings keys.
"""

import os
from pathlib import Path
import shutil
import sys

from PyQt6.QtCore import QSettings


ini, state, music, fpcalc = map(Path, sys.argv[1:])
state.mkdir(parents=True, exist_ok=True)
backup = state / "Picard.ini.before-managed-settings"
if ini.exists() and not backup.exists():
    with backup.open("xb") as output:
        os.chmod(backup, 0o600)
        with ini.open("rb") as source:
            shutil.copyfileobj(source, output)

settings = QSettings(str(ini), QSettings.Format.IniFormat)
values = {
    "persist/view_cover_art": True,
    "persist/view_metadata_view": True,
    "setting/save_images_to_tags": True,
    "setting/save_images_to_files": False,
    "setting/ca_providers": [
        ("Cover Art Archive", True),
        ("Deezer", True),
        ("CaaReleaseGroup", True),
        ("fanarttv.CoverArtProviderFanartTv", True),
        ("Local Files", True),
    ],
    "setting/preserve_images": False,
    "setting/clear_existing_tags": False,
    "setting/rename_files": True,
    "setting/move_files": True,
    "setting/enable_tag_saving": True,
    "setting/active_file_naming_script_id": "Preset 2",
    "setting/move_additional_files": False,
    "setting/delete_empty_dirs": False,
    "setting/starting_directory": True,
    "setting/starting_directory_path": str(music),
    "setting/acoustid_fpcalc": str(fpcalc),
    "setting/save_acoustid_fingerprints": True,
    "setting/show_new_user_dialog": False,
    "plugin.20be1ec3-ab24-4e1a-b262-1a6587ae3fd6/add_synced_lyrics": True,
    "plugin.20be1ec3-ab24-4e1a-b262-1a6587ae3fd6/never_replace_lyrics": True,
    "plugin.20be1ec3-ab24-4e1a-b262-1a6587ae3fd6/exported_lrc": False,
    "plugin.20be1ec3-ab24-4e1a-b262-1a6587ae3fd6/never_replace_lrc": True,
    "plugin.8ee475c2-cdbe-49c0-9db2-6e45cd8103de/cover_size": "xl",
    "plugin.8ee475c2-cdbe-49c0-9db2-6e45cd8103de/min_similarity": 0.9,
    "setting/plugins3_enabled_plugins": [
        "20be1ec3-ab24-4e1a-b262-1a6587ae3fd6",  # LRCLIB
        "d80f6f27-b141-438a-b644-fffb752e0ba2",  # fanart.tv (needs client key)
        "16812cfb-5e3a-4db2-b8c7-f7a1fa04a075",  # BPM
        "8ee475c2-cdbe-49c0-9db2-6e45cd8103de",  # Deezer cover art
    ],
}
for key, value in values.items():
    settings.setValue(key, value)
settings.sync()
if settings.status() != QSettings.Status.NoError:
    raise RuntimeError(f"Unable to write Picard settings: {settings.status().name}")
