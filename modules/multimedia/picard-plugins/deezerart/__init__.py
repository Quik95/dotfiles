# Deezer cover art plugin port, based on the legacy plugin by Fabio Forni.
# Copyright (C) Fabio Forni
# SPDX-License-Identifier: GPL-3.0-or-later

from functools import partial
import re
from urllib.parse import parse_qsl, urlencode, urlsplit, urlunsplit

from picard.plugin3.api import (
    CoverArtImage,
    CoverArtProvider,
    PluginApi,
    ProviderOptions,
    t_,
)
from picard.util.astrcmp import astrcmp
from PyQt6.QtWidgets import QComboBox, QFormLayout, QSpinBox


DEEZER_API = "https://api.deezer.com"
DEFAULT_SIMILARITY_THRESHOLD = 0.6
COVER_SIZE_FIELDS = {
    "small": "cover_small",
    "": "cover",
    "medium": "cover_medium",
    "big": "cover_big",
    "xl": "cover_xl",
}
COVER_SIZE_OPTIONS = (
    ("Thumbnail", "small"),
    ("Small", ""),
    ("Medium", "medium"),
    ("Big", "big"),
    ("Large", "xl"),
)


def is_similar(first, second, threshold):
    """Keep the legacy substring-or-Levenshtein matching behavior."""
    return (
        isinstance(first, str)
        and isinstance(second, str)
        and (first in second or astrcmp(first, second) >= threshold)
    )


def deezer_album_id(url):
    """Return an album ID only for direct Deezer album links."""
    try:
        parsed = urlsplit(url)
        host = parsed.hostname
    except (TypeError, ValueError):
        return None
    if not host or not (host == "deezer.com" or host.endswith(".deezer.com")):
        return None

    path = [part for part in parsed.path.split("/") if part]
    if len(path) >= 3 and re.fullmatch(r"[a-z]{2}", path[0], re.IGNORECASE):
        path = path[1:]
    if len(path) < 2 or path[0] != "album" or not path[1].isdigit():
        return None
    return path[1]


def quote_query_value(value):
    """Escape a value used inside a quoted Deezer advanced-search field."""
    return value.replace("\\", "\\\\").replace('"', '\\"')


class DeezerCoverArtImage(CoverArtImage):
    """Front cover image downloaded from Deezer."""

    support_types = True
    sourceprefix = "DEEZER"


class DeezerOptionsPage(ProviderOptions):
    NAME = "deezerart"
    TITLE = t_("provider.title", "Deezer")

    def __init__(self, parent=None):
        super().__init__(parent=parent)
        layout = QFormLayout(self)
        self.cover_size = QComboBox(self)
        for label, value in COVER_SIZE_OPTIONS:
            self.cover_size.addItem(label, value)
        self.min_similarity = QSpinBox(self)
        self.min_similarity.setRange(0, 100)
        self.min_similarity.setSuffix(" %")
        layout.addRow(t_("option.cover_size", "Cover size:"), self.cover_size)
        layout.addRow(
            t_("option.min_similarity", "Minimal similarity for matches:"),
            self.min_similarity,
        )

    def load(self):
        settings = self.api.plugin_config
        index = self.cover_size.findData(settings["cover_size"])
        self.cover_size.setCurrentIndex(max(index, 0))
        self.min_similarity.setValue(round(settings["min_similarity"] * 100))

    def save(self):
        settings = self.api.plugin_config
        settings["cover_size"] = self.cover_size.currentData()
        settings["min_similarity"] = self.min_similarity.value() / 100.0


class DeezerCoverArtProvider(CoverArtProvider):
    """Fetch front cover art from Deezer's public API."""

    NAME = "Deezer"
    TITLE = t_("provider.title", "Deezer")
    OPTIONS = DeezerOptionsPage

    def queue_images(self):
        relation_album_id = self._deezer_relation_album_id()
        if relation_album_id:
            task_id = "album-relation"
            if self._request_json(
                task_id,
                f"{DEEZER_API}/album/{relation_album_id}",
                None,
                partial(self._album_response, task_id, "URL relation"),
                "Looking up Deezer album URL relation",
            ):
                return self.QueueState.WAIT
            return self.QueueState.FINISHED

        artist = self._artist()
        album = self._first_value(self.metadata.get("album", ""))
        if not artist or not album:
            self.api.logger.debug("Skipping Deezer search: artist or album is missing")
            return self.QueueState.FINISHED

        task_id = "search-album"
        query = f'artist:"{quote_query_value(artist)}" album:"{quote_query_value(album)}"'
        if self._queue_search(task_id, query, False):
            return self.QueueState.WAIT
        return self.QueueState.FINISHED

    def _deezer_relation_album_id(self):
        album_ids = []
        self.match_url_relations(("free streaming",), album_ids.append)
        for url in album_ids:
            if album_id := deezer_album_id(url):
                return album_id
        return None

    def _artist(self):
        getraw = getattr(self.metadata, "getraw", None)
        if getraw:
            artists = getraw("~albumartists")
            if artist := self._first_value(artists):
                return artist
        for tag in ("albumartist", "artist"):
            if artist := self._first_value(self.metadata.get(tag)):
                return artist
        return ""

    @staticmethod
    def _first_value(value):
        if isinstance(value, (list, tuple)):
            return str(value[0]) if value and value[0] else ""
        return str(value) if value else ""

    def _queue_search(self, task_id, query, fallback):
        return self._request_json(
            task_id,
            f"{DEEZER_API}/search",
            {"q": query},
            partial(self._search_response, task_id, fallback),
            "Searching Deezer for album artwork",
        )

    def _request_json(self, task_id, url, queryargs, handler, description):
        def create_request():
            return self.api.web_service.get_url(
                url=url,
                unencoded_queryargs=queryargs,
                handler=handler,
                parse_response_type="json",
                priority=True,
                important=False,
            )

        # Let Picard's transfer timeout produce the callback. Album-task timeout
        # aborts silently as OperationCanceledError and can strand the WAIT queue.
        try:
            self.api.add_album_task(
                self.album,
                task_id,
                description,
                request_factory=create_request,
            )
        except Exception:
            self.api.logger.exception("Could not start Deezer API request")
            try:
                self.api.complete_album_task(self.album, task_id)
            except Exception:
                self.api.logger.exception("Could not complete failed Deezer API task")
            self.error("Could not start Deezer API request")
            return False
        return True

    def _album_response(self, task_id, source, data, reply, error):
        try:
            if error:
                self.error(f"Deezer album request failed: {error}")
            elif api_error := self._api_error(data):
                self.error(f"Deezer album request failed: {api_error}")
            elif not isinstance(data, dict) or data.get("type") != "album":
                self.error("Deezer album request did not return an album")
            elif image_url := cover_url_for_size(self.api, data):
                self.queue_put(DeezerCoverArtImage(image_url, types=["front"]))
                self.api.logger.debug("Queued Deezer cover from %s", source)
            else:
                self.error("Deezer album response contained no cover art")
        except Exception:
            self.api.logger.exception("Could not process Deezer album response")
        finally:
            self._finish_request(task_id)

    def _search_response(self, task_id, fallback, data, reply, error):
        start_fallback = False
        try:
            if error:
                self.error(f"Deezer search request failed: {error}")
            elif api_error := self._api_error(data):
                self.error(f"Deezer search request failed: {api_error}")
            elif not isinstance(data, dict) or not isinstance(data.get("data"), list):
                self.error("Deezer returned an unexpected search response")
            else:
                results = data["data"]
                if not results and not fallback:
                    track = self._fallback_track_title()
                    artist = self._artist()
                    if artist and track:
                        query = (
                            f'artist:"{quote_query_value(artist)}" '
                            f'track:"{quote_query_value(track)}"'
                        )
                        start_fallback = self._queue_search("search-track", query, True)
                    if not start_fallback:
                        self.error("No Deezer search results found")
                elif not results:
                    self.error("No Deezer search results found")
                elif not self._queue_matching_result(results):
                    self.error("No Deezer search result matched the album")
        except Exception:
            self.api.logger.exception("Could not process Deezer search response")
        finally:
            try:
                self.api.complete_album_task(self.album, task_id)
            finally:
                if not start_fallback:
                    self.next_in_queue()

    def _queue_matching_result(self, results):
        artist = self._artist()
        album = self._first_value(self.metadata.get("album", ""))
        threshold = self.api.plugin_config["min_similarity"]
        for result in results:
            if not isinstance(result, dict) or result.get("type") != "track":
                continue
            result_artist = result.get("artist")
            result_album = result.get("album")
            if not isinstance(result_artist, dict) or not isinstance(result_album, dict):
                continue
            if not is_similar(artist, result_artist.get("name", ""), threshold):
                continue
            if not is_similar(album, result_album.get("title", ""), threshold):
                continue
            if image_url := cover_url_for_size(self.api, result_album):
                self.queue_put(DeezerCoverArtImage(image_url, types=["front"]))
                self.api.logger.debug("Queued Deezer cover from album search")
                return True
        return False

    def _fallback_track_title(self):
        try:
            media = self.release.get("media", [])
            tracks = media[0].get("tracks", [])
            return self._first_value(tracks[1].get("title", ""))
        except (AttributeError, IndexError, TypeError):
            return ""

    @staticmethod
    def _api_error(data):
        if not isinstance(data, dict) or "error" not in data:
            return None
        error = data["error"]
        if isinstance(error, dict):
            return error.get("message", "Deezer returned an API error")
        return str(error)

    def _finish_request(self, task_id):
        try:
            self.api.complete_album_task(self.album, task_id)
        except Exception:
            self.api.logger.exception("Could not complete Deezer album task")
        finally:
            self.next_in_queue()


def cover_url_for_size(api, album):
    """Select a cover URL using the current plugin setting."""
    if not isinstance(album, dict):
        return None

    size = api.plugin_config["cover_size"]
    field = COVER_SIZE_FIELDS.get(size)
    if field is None:
        return None
    url = album.get(field)
    if isinstance(url, str) and url:
        return url

    url = album.get("cover")
    if not isinstance(url, str) or not url:
        return None
    if not size:
        return url
    parsed = urlsplit(url)
    query = [(key, value) for key, value in parse_qsl(parsed.query) if key != "size"]
    query.append(("size", size))
    return urlunsplit(parsed._replace(query=urlencode(query)))


def migrate_legacy_settings(api):
    settings = api.global_config.setting
    plugin_config = api.plugin_config
    legacy_size = settings.raw_value("deezerart_size", qtype=str)
    if legacy_size is not None:
        if "cover_size" not in plugin_config and legacy_size in COVER_SIZE_FIELDS:
            plugin_config["cover_size"] = legacy_size
        api.global_config.remove("deezerart_size")

    legacy_similarity = settings.raw_value("deezerart_min_similarity", qtype=float)
    if legacy_similarity is not None:
        if "min_similarity" not in plugin_config and 0.0 <= legacy_similarity <= 1.0:
            plugin_config["min_similarity"] = legacy_similarity
        api.global_config.remove("deezerart_min_similarity")


def enable(api: PluginApi) -> None:
    api.plugin_config.register_option("cover_size", "big")
    api.plugin_config.register_option(
        "min_similarity", DEFAULT_SIMILARITY_THRESHOLD
    )
    migrate_legacy_settings(api)
    api.register_cover_art_provider(DeezerCoverArtProvider)
