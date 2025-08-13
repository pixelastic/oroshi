return {
  -- concat: Concatenate multiple tables together
  concat = function(...)
    local ret = {}
    for _, tbl in ipairs({ ... }) do
      for i = 1, #tbl do
        ret[#ret + 1] = tbl[i]
      end
    end
    return ret
  end,

  -- clone: Copy the collection to a new one
  clone = function(collection)
    return vim.deepcopy(collection)
  end,

  -- each: Run callback on each element of the collection
  each = function(collection, callback)
    for key, value in pairs(collection) do
      callback(value, key, collection)
    end
  end,

  -- endsWith: Check if string ends with a specific substring
  endsWith = function(input, prefix)
    return string.find(input, prefix, -#prefix, true) == #input - #prefix + 1
  end,

  -- first: Returns the first element of a collection
  first = function(collection)
    return collection[1]
  end,

  -- get: Return the value at the given path in the collection
  get = function(collection, path, defaultValue)
    local keys = F.split(path, ".")

    local current = collection or {}
    for _, key in ipairs(keys) do
      if current[key] == nil then
        return defaultValue
      end
      current = current[key]
    end

    return current
  end,

  -- includes: Check if a given value exists in a table
  includes = function(collection, value)
    return vim.tbl_contains(collection, value)
  end,

  -- empty: Check if the collection is empty
  isEmpty = function(collection)
    return #collection == 0
  end,

  -- join: Join a collection with a delimiter
  join = function(collection, delimiter)
    return table.concat(collection, delimiter or ", ")
  end,

  -- last: Returns the last element of a collection
  last = function(collection)
    return collection[#collection]
  end,

  -- length: Returns the length of the string or collection
  length = function(input)
    if F.isString(input) then
      return #input
    end

    if F.isCollection(input) then
      return vim.tbl_count(input)
    end

    return 0
  end,

  -- map: Creates an table of values by running each element thru callback
  map = function(collection, callback)
    -- Usage:
    -- _.map(collection, 'key')          -- Return table of all keys
    -- _.map(collection, function() end) -- apply function to all items

    -- If a string, return the key by that name
    if type(callback) == "string" then
      local key = callback
      callback = function(item)
        return item[key]
      end
    end

    local ret = {}
    -- TODO: ipairs will iterate only on numeric keys and stop on any gap. pairs
    -- will iterate on everything, but do not guarantee order.
    for _, value in ipairs(collection) do
      F.append(ret, callback(value))
    end
    return ret
  end,

  -- merge: Recursively merge tables
  merge = function(one, two)
    return vim.tbl_deep_extend("force", {}, one or {}, two or {})
  end,

  -- replace: Replace all occurrences of a string with another
  replace = function(input, from, to)
    return string.gsub(input, from, to)
  end,

  -- set: Set the value of a given key in a collection
  set = function(collection, path, value)
    local keys = F.split(path, ".")

    -- Create the objects up to the last key if needed
    local current = collection or {}
    for i = 1, #keys - 1 do
      local key = keys[i]
      if not current[key] then
        current[key] = {}
      end
      current = current[key]
    end

    current[F.last(keys)] = value
  end,

  -- split: Split a string on a delimiter
  split = function(input, delimiter)
    return vim.split(input, delimiter, { plain = true })
  end,

  -- startsWith: Check if string starts with a specific substring
  startsWith = function(input, prefix)
    return string.find(input, prefix, 1, true) == 1
  end,

  -- trim: Remove starting/trailing characters
  trim = function(input, characters)
    if not characters then
      characters = "%s" -- Default to whitespace
    end
    return F.replace(input, "^" .. characters .. "*(.-)" .. characters .. "*$", "%1")
  end,
}
