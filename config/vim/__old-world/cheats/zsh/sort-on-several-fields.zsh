
local suggestions="$(\
  docker images \
  --format '{{.Repository}}\:{{.Tag}}:{{.CreatedSince}} ({{.Size}})''{{.Repository}}|{{.Tag}}|{{.ID}}|{{.CreatedSince}}|{{.Size}}' \
  | sort \
    --field-separator '|' \
    --key 1,1d \
    --key 2,2r
)"
