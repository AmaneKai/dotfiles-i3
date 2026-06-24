#!/usr/bin/env bash

readonly ROFI_THEME="$HOME/.config/rofi/rose-pine.rasi"
readonly DELIMITER="###"

build_menu() {
  local temp_file="$1"

  echo "─────  󰕾  OUTPUTS  ─────${DELIMITER}header${DELIMITER}" >> "$temp_file"

  while IFS= read -r line; do
    local sink_name description icon

    sink_name=$(echo "$line" | awk '{print $2}')
    description=$(pactl list sinks \
      | grep -A 30 "Name: $sink_name" \
      | grep "Description:" \
      | head -1 \
      | sed 's/.*Description: //')

    [ -z "$description" ] && description="$sink_name"

    icon="󰕾"
    [[ "$sink_name" == *bluez* ]] && icon="󰋋"

    echo "${icon}  ${description}${DELIMITER}sink${DELIMITER}${sink_name}" >> "$temp_file"
  done < <(pactl list sinks short)

  echo "─────  󰍬  INPUTS  ──────${DELIMITER}header${DELIMITER}" >> "$temp_file"

  while IFS= read -r line; do
    local source_name description icon

    source_name=$(echo "$line" | awk '{print $2}')
    [[ "$source_name" == *monitor* ]] && continue

    description=$(pactl list sources \
      | grep -A 30 "Name: $source_name" \
      | grep "Description:" \
      | head -1 \
      | sed 's/.*Description: //')

    [ -z "$description" ] && description="$source_name"

    icon="󰍬"
    [[ "$source_name" == *bluez* ]] && icon="󰋎"

    echo "${icon}  ${description}${DELIMITER}source${DELIMITER}${source_name}" >> "$temp_file"
  done < <(pactl list sources short)
}

find_header_indices() {
  local temp_file="$1"
  local index=0
  local indices=""

  while IFS= read -r line; do
    [[ "$line" == *"${DELIMITER}header${DELIMITER}"* ]] && indices+="${index},"
    ((index++))
  done < "$temp_file"

  echo "${indices%,}"
}

apply_sink_selection() {
  local device="$1"
  local label="$2"

  pactl set-default-sink "$device"

  pactl list sink-inputs short | awk '{print $1}' | while read -r stream
    do pactl move-sink-input "$stream" "$device" 2>/dev/null || true
  done

  notify-send "󰕾 Output" "$label"
}

apply_source_selection() {
  local device="$1"
  local label="$2"

  pactl set-default-source "$device"

  pactl list source-outputs short | awk '{print $1}' | while read -r stream
    do pactl move-source-output "$stream" "$device" 2>/dev/null || true
  done

  notify-send "󰍬 Input" "$label"
}

main() {
  local temp_file
  temp_file=$(mktemp)
  trap "rm -f $temp_file" EXIT

  build_menu "$temp_file"

  local header_indices
  header_indices=$(find_header_indices "$temp_file")

  local rofi_arguments=(-dmenu -i -p "audio" -theme "$ROFI_THEME" -format i)
  [ -n "$header_indices" ] && rofi_arguments+=(-a "$header_indices")

  local chosen_index
  chosen_index=$(awk -F"$DELIMITER" '{print $1}' "$temp_file" | rofi "${rofi_arguments[@]}")

  [ -z "$chosen_index" ] && exit 0

  local chosen_line type device label
  chosen_line=$(awk "NR==$((chosen_index + 1))" "$temp_file")
  type=$(echo "$chosen_line" | awk -F"$DELIMITER" '{print $2}')
  device=$(echo "$chosen_line" | awk -F"$DELIMITER" '{print $3}')
  label=$(echo "$chosen_line" | awk -F"$DELIMITER" '{print $1}')

  [ "$type" == "header" ] && exit 0
  [ -z "$device" ] && exit 0

  case "$type" in
    sink)   apply_sink_selection "$device" "$label" ;;
    source) apply_source_selection "$device" "$label" ;;
  esac
}

main
