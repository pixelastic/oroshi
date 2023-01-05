# Colors
#
# This will define COLORS environment variables
# - COLOR_RED_0 will be the lightest shade of red
# - COLOR_RED_9 will be the darkest shade of red
# - COLOR_RED will be equivalent to COLOR_RED_5
# - The default variables will return the color number
# - Adding _HEXA at the end will return the hexadecimal value
#
# This will also create a COLORS_INDEX env variable, with all the color names
#
function () {
  # The following ranges and color number should match what is defined in kitty/colors.conf
  # Named colors {{{
  declare -A namedColors
  namedColors=()
  namedColors[0]="BLACK"
  namedColors[1]="RED"
  namedColors[2]="GREEN"
  namedColors[3]="YELLOW"
  namedColors[4]="BLUE"
  namedColors[5]="PURPLE"
  namedColors[6]="CYAN"
  namedColors[7]="WHITE"
  namedColors[8]="BLACK_PURE"
  namedColors[9]="RED_LIGHT"
  namedColors[10]="GREEN_LIGHT"
  namedColors[11]="YELLOW_LIGHT"
  namedColors[12]="BLUE_LIGHT"
  namedColors[13]="PURPLE_LIGHT"
  namedColors[14]="CYAN_LIGHT"
  namedColors[15]="WHITE_PURE"
  namedColors[16]="GRAY"
  namedColors[17]="ORANGE"
  namedColors[18]="EMERALD"
  namedColors[19]="AMBER"
  namedColors[20]="SKY"
  namedColors[21]="VIOLET"
  namedColors[22]="TEAL"
  namedColors[23]="NEUTRAL"
  namedColors[24]="GRAY_LIGHT"
  namedColors[25]="ORANGE_LIGHT"
  namedColors[26]="EMERALD_LIGHT"
  namedColors[27]="AMBER_LIGHT"
  namedColors[28]="SKY_LIGHT"
  namedColors[29]="VIOLET_LIGHT"
  namedColors[30]="TEAL_LIGHT"
  namedColors[31]="NEUTRAL_LIGHT"
  # }}}
  # Color palettes {{{
  local colorRanges=()
  # colorRanges[5]="XXX?"
  colorRanges[6]="RED"
  colorRanges[7]="GREEN"
  colorRanges[8]="YELLOW"
  colorRanges[9]="BLUE"
  colorRanges[10]="PURPLE"
  colorRanges[11]="CYAN"
  # colorRanges[12]="XXX?"
  colorRanges[13]="GRAY"
  colorRanges[14]="ORANGE"
  colorRanges[15]="EMERALD"
  colorRanges[16]="AMBER"
  colorRanges[17]="SKY"
  colorRanges[18]="VIOLET"
  colorRanges[19]="TEAL"
  colorRanges[20]="NEUTRAL"
  # }}}

  local colorsIndex=()

  # We define all ENV variables for all colors
  local kittyColors="$(cat ~/.oroshi/config/kitty/colors.conf | grep '^color')"
  for line in ${(f)kittyColors}; do
    # Full line: color105  #6b7280
    local split=(${=line})
    # Term value: 105
    local colorTermValue=${split[1]:5}
    # Hexadecimal value
    local colorHexaValue=$split[2]

    # Known color
    if [[ $namedColors[$colorTermValue] != "" ]]; then
      local colorKey="$namedColors[$colorTermValue]"
      [[ "$colorKey" == "" ]] && continue
    else
      # Palette color
      # Range start: 10 (GRAY)
      local colorRangeValue=${colorTermValue:0:-1}
      [[ $colorRangeValue == "" ]] && continue
      local colorRangeName=$colorRanges[$colorRangeValue]
      [[ $colorRangeName == "" ]] && continue

      # Scale index: 5
      local colorScaleValue=$colorTermValue[-1]

      local colorKey="${colorRangeName}_${colorScaleValue}"
    fi

    export COLOR_${colorKey}=$colorTermValue
    export COLOR_${colorKey}_HEXA=$colorHexaValue

    colorsIndex+=("${colorKey}")
  done

  # Alphabetical list of all colors
  export COLORS_INDEX=""
  for colorName in ${(o)colorsIndex}; do
    COLORS_INDEX+=" $colorName"
  done
}
