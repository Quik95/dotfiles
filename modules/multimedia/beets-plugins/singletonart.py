"""Fetch missing singleton artwork after import has copied the audio file.

Reuse fetchart's configured sources, validation and resizing. Album objects
below are metadata-only views: they are never added to the library.
"""

import os

from beets import config, plugins
from beets.library import Album
from beets.plugins import BeetsPlugin
from beetsplug._utils import art
from beetsplug.fetchart import FetchArtPlugin


class SingletonArtPlugin(BeetsPlugin):
    def __init__(self):
        super().__init__()
        self.register_listener("item_imported", self.imported)

    def imported(self, lib, item):
        if item.album_id or not config["import"]["write"].get(bool):
            return
        if art.get_art(self._log, item):
            self._log.debug("Keeping existing artwork for {}", item)
            return

        fetcher = next(
            (plugin for plugin in plugins.find_plugins()
             if isinstance(plugin, FetchArtPlugin)),
            None,
        )
        if fetcher is None:
            self._log.error("singletonart requires the fetchart plugin")
            return

        album = Album({key: item.get(key) for key in Album._fields if key in item})
        album.albumartist = item.albumartist or item.artist
        album.album = item.album or item.title
        if item.get("cover_art_url"):
            album["cover_art_url"] = item.cover_art_url

        candidate = fetcher.art_for_album(album, [os.path.dirname(item.path)])
        if candidate is None:
            self._log.info("No artwork found for {}", item)
            return
        try:
            art.embed_item(self._log, item, candidate.path, ifempty=True)
            if art.get_art(self._log, item):
                item["art_source"] = candidate.source_name
                item.store()
                self._log.info("Embedded {} artwork for {}", candidate.source_name, item)
        finally:
            for source in fetcher.sources:
                if source.ID == candidate.source_name:
                    source.cleanup(candidate)
                    break
