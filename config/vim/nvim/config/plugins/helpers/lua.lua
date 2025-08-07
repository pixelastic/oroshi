local M = {}

M.configureFormatter = function()
	local conform = require("conform")

	-- Configure stylua
	conform.formatters.stylua = {
		prepend_args = { "--indent-type", "Spaces", "--indent", "2" },
	}
end

return M
