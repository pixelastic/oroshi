local M = {}

M.configureLinter = function(lint)
  lint.linters.oroshi_fly_lint = {
    cmd = "fly-lint",
    stdin = false, -- Reading from filepath
    ignore_exitcode = true, -- Do not fail on exit 1
    parser = require("lint.parser").from_errorformat("%f:%l:%c:%t%*[^:]:%m", {
      warning = "warning",
      error = "error",
      source = "fly-lint",
    }),
  }
end

return M
