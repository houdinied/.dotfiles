#!/bin/bash
set -u

CARD="alsa_card.pci-0000_00_1f.3-platform-skl_hda_dsp_generic"
SPEAKER_SINK="alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Speaker__sink"
HP_SINK="alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Headphones__sink"
SPEAKER_PROFILE="HiFi (HDMI1, HDMI2, HDMI3, Mic1, Mic2, Speaker)"
HP_PROFILE="HiFi (HDMI1, HDMI2, HDMI3, Headphones, Mic1, Mic2)"

switch_profile() {
  local hp_avail
  hp_avail=$(pactl list cards | grep -A10 "Headphones" | grep "available:" | awk '{print $2}')

  if [[ $hp_avail == "yes" ]]; then
    pactl set-card-profile "$CARD" "$HP_PROFILE"
    pactl set-default-sink "$HP_SINK"
  else
    pactl set-card-profile "$CARD" "$SPEAKER_PROFILE"
    pactl set-default-sink "$SPEAKER_SINK"
  fi
}

switch_profile

pactl subscribe | while read -r line; do
  case "$line" in
    *"card"*) switch_profile ;;
  esac
done
