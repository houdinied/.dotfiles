#!/usr/bin/env python3
import os
import sys

import gi

gi.require_version("Gtk", "3.0")
from gi.repository import Gtk


DEFAULTS = {
    "FOCUS_MIN": 25,
    "BREAK_MIN": 5,
    "LONG_BREAK_MIN": 15,
    "AUTO_START_BREAKS": 0,
    "AUTO_START_POMODOROS": 0,
    "LONG_BREAK_EVERY": 4,
}


def parse_bool(value):
    return str(value).strip().lower() in {"1", "true", "yes", "on"}


def parse_config(path):
    config = DEFAULTS.copy()
    if not os.path.exists(path):
        return config

    with open(path, "r", encoding="utf-8") as handle:
        for raw_line in handle:
            line = raw_line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            key, value = line.split("=", 1)
            key = key.strip()
            value = value.strip().strip("'\"")
            if key not in config:
                continue
            if key.startswith("AUTO_START"):
                config[key] = 1 if parse_bool(value) else 0
            else:
                try:
                    config[key] = int(value)
                except ValueError:
                    pass
    return config


def write_config(path, config):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as handle:
        for key in DEFAULTS:
            handle.write(f"{key}={int(config[key])}\n")


class SettingsWindow(Gtk.Window):
    def __init__(self, config_path):
        super().__init__(title="Pomodoro Settings")
        self.config_path = config_path
        self.config = parse_config(config_path)
        self.set_border_width(18)
        self.set_resizable(False)

        outer = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=14)
        self.add(outer)

        title = Gtk.Label()
        title.set_markup("<b>Timer</b>")
        title.set_xalign(0)
        outer.pack_start(title, False, False, 0)

        grid = Gtk.Grid(column_spacing=18, row_spacing=12)
        outer.pack_start(grid, False, False, 0)

        self.focus = self.add_spin(grid, 0, "Pomodoro", "FOCUS_MIN", 1, 240)
        self.short_break = self.add_spin(grid, 1, "Short Break", "BREAK_MIN", 1, 120)
        self.long_break = self.add_spin(grid, 2, "Long Break", "LONG_BREAK_MIN", 1, 180)
        self.auto_breaks = self.add_check(grid, 3, "Auto Start Breaks", "AUTO_START_BREAKS")
        self.auto_pomodoros = self.add_check(grid, 4, "Auto Start Pomodoros", "AUTO_START_POMODOROS")
        self.long_interval = self.add_spin(grid, 5, "Long Break interval", "LONG_BREAK_EVERY", 1, 20)

        buttons = Gtk.ButtonBox(orientation=Gtk.Orientation.HORIZONTAL)
        buttons.set_layout(Gtk.ButtonBoxStyle.END)
        buttons.set_spacing(8)
        outer.pack_start(buttons, False, False, 0)

        cancel = Gtk.Button(label="Cancel")
        cancel.connect("clicked", lambda *_: self.close())
        buttons.add(cancel)

        save = Gtk.Button(label="Save")
        save.get_style_context().add_class("suggested-action")
        save.connect("clicked", self.on_save)
        buttons.add(save)

    def add_label(self, grid, row, text):
        label = Gtk.Label(label=text)
        label.set_xalign(0)
        grid.attach(label, 0, row, 1, 1)
        return label

    def add_spin(self, grid, row, label, key, lower, upper):
        self.add_label(grid, row, label)
        spin = Gtk.SpinButton()
        spin.set_adjustment(Gtk.Adjustment(value=self.config[key], lower=lower, upper=upper, step_increment=1))
        spin.set_numeric(True)
        spin.set_width_chars(5)
        grid.attach(spin, 1, row, 1, 1)
        unit = Gtk.Label(label="minutes" if key != "LONG_BREAK_EVERY" else "pomodoros")
        unit.set_xalign(0)
        grid.attach(unit, 2, row, 1, 1)
        return spin

    def add_check(self, grid, row, label, key):
        check = Gtk.CheckButton(label=label)
        check.set_active(bool(self.config[key]))
        grid.attach(check, 0, row, 3, 1)
        return check

    def on_save(self, *_):
        config = {
            "FOCUS_MIN": self.focus.get_value_as_int(),
            "BREAK_MIN": self.short_break.get_value_as_int(),
            "LONG_BREAK_MIN": self.long_break.get_value_as_int(),
            "AUTO_START_BREAKS": 1 if self.auto_breaks.get_active() else 0,
            "AUTO_START_POMODOROS": 1 if self.auto_pomodoros.get_active() else 0,
            "LONG_BREAK_EVERY": self.long_interval.get_value_as_int(),
        }
        write_config(self.config_path, config)
        self.close()


def main():
    config_path = sys.argv[1] if len(sys.argv) > 1 else os.path.expanduser("~/.config/waybar/pomodoro.conf")
    window = SettingsWindow(config_path)
    window.connect("destroy", Gtk.main_quit)
    window.show_all()
    Gtk.main()


if __name__ == "__main__":
    main()
