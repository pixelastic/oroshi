local DEBUG_STARTTIME=$(($(date +%s%N)/1000000))

# Creates $COLOR[red1], $FG[red1], $BG[red1] syntactic sugar variables
# It works by iterating on the list of color groups (red, blue, etc) in the same
# order as they are defined in kitty.conf, then iterate from 1 to 9 and create
# the entries

local -a orderedColors
local -A COLOR
orderedColors=(gray red green yellow blue purple teal orange indigo pink)
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

local DEBUG_ENDTIME=$(($(date +%s%N)/1000000))
[[ $ZSH_DEBUG == 1 ]] && echo "[debug]: ${0:t}: $(($DEBUG_ENDTIME - $DEBUG_STARTTIME))ms"
