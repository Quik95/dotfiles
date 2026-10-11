from picard.plugin3.api import OptionsPage
from PyQt6.QtWidgets import QComboBox, QFormLayout, QGroupBox, QVBoxLayout

BPM_SLIDER_PARAMETER = "bpm_slider_parameter"


class BPMOptionsPage(OptionsPage):
    TITLE = "BPM"

    def __init__(self, parent=None):
        super().__init__(parent)
        layout = QVBoxLayout(self)
        settings = QGroupBox("BPM analysis parameters", self)
        form = QFormLayout(settings)
        self.preset = QComboBox(settings)
        self.preset.addItem("Super Fast — 44100 Hz / FFT 1024 / hop 512", 1)
        self.preset.addItem("Preset 2 — 8000 Hz / FFT 512 / hop 128", 2)
        self.preset.addItem("Default (legacy label) — 4000 Hz / FFT 128 / hop 64", 3)
        form.addRow("Analysis preset:", self.preset)
        layout.addWidget(settings)
        layout.addStretch(1)

    def load(self):
        value = self.api.plugin_config[BPM_SLIDER_PARAMETER]
        index = self.preset.findData(value)
        self.preset.setCurrentIndex(max(index, 0))

    def save(self):
        self.api.plugin_config[BPM_SLIDER_PARAMETER] = self.preset.currentData()
