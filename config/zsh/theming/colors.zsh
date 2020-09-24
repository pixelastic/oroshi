# Colors
#
# This will define the $COLOR associative array. Each key is named after a color
# and its value is the index of the color in the range 0-255
#
# Examples:
#   $COLOR[red1], $COLOR[blue4], $COLOR[green]
# 
# Each color ranges from 1 to 9, and the version without a number re-uses the
# value from the 6th step

# The order of the colors is important and must match what is defined in
# kitty.cong
local -a orderedColors
orderedColors=(gray red green yellow blue purple teal orange indigo pink)

local -A COLOR
for colorGroupName in $orderedColors; do
  local colorGroupIndex=${orderedColors[(i)$colorGroupName]} # array index
  local colorBucketPrefix=$(($colorGroupIndex+1)) # kitty group (1X, 2X, etc)
  for colorIndex in {1..9}; do
    local colorName="${colorGroupName}${colorIndex}";
    local colorValue="${colorBucketPrefix}${colorIndex}";
    COLOR[$colorName]=$colorValue
  done
  # Easy access to the color
  COLOR[$colorGroupName]=$COLOR[${colorGroupName}6]
done

export COLOR
