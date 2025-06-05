local M = {
  -- env: Get an environment variable
  env = function(name)
    return os.getenv(name)
  end,
  -- isTable: Check if variable is a collection
  isCollection = function(input)
    return type(input) == 'table'
  end,
}

return M

