local M = {}

-- Detect Hugo template files as gotmpl
function M.onInit()
  vim.filetype.add({
    pattern = {
      ['.*/layouts/.*%.html'] = 'gotmpl',
      ['.*/archetypes/.*%.md'] = 'gotmpl',
    }
  })
end

return M
