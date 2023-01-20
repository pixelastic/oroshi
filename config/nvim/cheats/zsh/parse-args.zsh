# Parse arguments (argsf, argsp)

# ====
local argsp=()
local -A argsf; argsf=()
for arg in $argv; do
  [[ "$arg" =~ "^-" ]] && argsf[$arg]=1 || argsp+="$arg"
done

local branchName="$argsp[1]"
if [[ "$argsf[--with-icon]" != 1 ]]; then
  colorize "$branchName" $branchColor
  exit
fi
# ===
