return {
  -- env: Get an environment variable
  env = function(name)
    return os.getenv(name)
  end,
  -- isCollection: Check if variable is a collection
  isCollection = function(input)
    return type(input) == 'table'
  end,
  -- isString: Check if variable is a string
  isString = function(input)
    return type(input) == 'string'
  end,
  -- isFunctions: Check if variable is a function
  isFunction = function(input)
    return type(input) == 'function'
  end,
}
