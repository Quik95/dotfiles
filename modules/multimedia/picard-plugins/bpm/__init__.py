"""Picard 3 port of the legacy aubio BPM Analyzer plugin."""

from functools import partial
import math
import shutil
import statistics
import subprocess
import tempfile

from picard.plugin3.api import BaseAction, File, PluginApi, Track, t_
from picard.util import thread

from .options import BPMOptionsPage, BPM_SLIDER_PARAMETER


# Preserve the three settings from the legacy plugin's bpm_slider_settings.
# Each tuple is (sample rate, aubio FFT buffer size, aubio hop size).
BPM_PRESETS = {
    1: (44100, 1024, 512),
    2: (8000, 512, 128),
    3: (4000, 128, 64),
}


class CalculateBPMAction(BaseAction):
    TITLE = t_("action.calculate_bpm", "Calculate BPM…")

    def callback(self, objs):
        files = []
        seen_files = set()
        for obj in objs:
            if isinstance(obj, File):
                candidates = (obj,)
            elif isinstance(obj, Track):
                candidates = obj.files
            else:
                continue

            for file in candidates:
                identity = id(file)
                if identity not in seen_files:
                    seen_files.add(identity)
                    files.append(file)

        if not files:
            return

        preset = self.api.plugin_config[BPM_SLIDER_PARAMETER]
        settings = BPM_PRESETS.get(preset)
        if settings is None:
            self.api.logger.error("Invalid BPM analysis preset: %r", preset)
            return

        for file in files:
            self.api.tagger.window.set_statusbar_message(
                self.api.tr(
                    "statusbar.bpm.in_progress",
                    'Calculating BPM for "{filename}"…',
                    filename=file.filename,
                )
            )
            thread.run_task(
                partial(calculate_bpm, file.filename, settings),
                partial(self._calculation_finished, file),
            )

    def _calculation_finished(self, file, result=None, error=None):
        if error is not None:
            self.api.logger.error(
                "Could not calculate BPM for %s: %s", file.filename, error
            )
            self.api.tagger.window.set_statusbar_message(
                self.api.tr(
                    "statusbar.bpm.failure",
                    'Could not calculate BPM for "{filename}".',
                    filename=file.filename,
                )
            )
            return

        # Picard's MP4 writer requires an integer for the native tmpo atom.
        file.metadata["bpm"] = str(round(result))
        file.update()
        self.api.tagger.window.set_statusbar_message(
            self.api.tr(
                "statusbar.bpm.success",
                'BPM for "{filename}" successfully calculated.',
                filename=file.filename,
            )
        )


def calculate_bpm(path: str, settings: tuple[int, int, int]) -> float:
    """Decode audio and return the median BPM between aubio-tracked beats."""
    samplerate, buf_size, hop_size = settings
    ffmpeg = shutil.which("ffmpeg")
    aubiotrack = shutil.which("aubiotrack")
    if ffmpeg is None:
        raise FileNotFoundError("ffmpeg was not found on PATH")
    if aubiotrack is None:
        raise FileNotFoundError("aubiotrack was not found on PATH")

    with tempfile.TemporaryDirectory(prefix="picard-bpm-") as temp_dir:
        wav_path = f"{temp_dir}/decoded.wav"
        ffmpeg_result = subprocess.run(
            [
                ffmpeg,
                "-nostdin",
                "-hide_banner",
                "-loglevel",
                "error",
                "-i",
                path,
                "-map",
                "0:a:0",
                "-vn",
                "-ac",
                "1",
                "-ar",
                str(samplerate),
                "-c:a",
                "pcm_s16le",
                "-f",
                "wav",
                wav_path,
            ],
            check=False,
            capture_output=True,
            text=True,
        )
        if ffmpeg_result.returncode:
            detail = ffmpeg_result.stderr.strip()
            raise RuntimeError(detail or "FFmpeg could not decode this audio file")

        aubio_result = subprocess.run(
            [
                aubiotrack,
                "-i",
                wav_path,
                "-r",
                str(samplerate),
                "-B",
                str(buf_size),
                "-H",
                str(hop_size),
                "-T",
                "seconds",
            ],
            check=False,
            capture_output=True,
            text=True,
        )
        if aubio_result.returncode:
            detail = aubio_result.stderr.strip()
            raise RuntimeError(detail or "aubio could not analyze this audio file")

    beat_times = []
    for line in aubio_result.stdout.splitlines():
        if line.strip():
            beat_time = float(line)
            if not math.isfinite(beat_time) or beat_time < 0:
                raise ValueError("aubio returned an invalid beat timestamp")
            beat_times.append(beat_time)

    intervals = [
        following - previous for previous, following in zip(beat_times, beat_times[1:])
    ]
    if not intervals:
        raise ValueError("aubio did not detect at least two beats")
    if any(interval <= 0 for interval in intervals):
        raise ValueError("aubio returned beat timestamps out of order")

    return statistics.median(60.0 / interval for interval in intervals)


def enable(api: PluginApi) -> None:
    """Register the BPM action, tuning option, and plugin preferences page."""
    api.plugin_config.register_option(
        BPM_SLIDER_PARAMETER,
        1,
        "Legacy BPM analysis preset",
    )
    api.register_file_action(CalculateBPMAction)
    api.register_track_action(CalculateBPMAction)
    api.register_options_page(BPMOptionsPage)
