__._ = {
  -- concat: Concatenate two tables
  concat = function(one, two)
    -- Use it to concat two arrays together, to create a new array
    local ret = one
    for i = 1, #two do
      ret[#ret + i] = two[i]
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

  -- includes: Check if a given value exists in a table
  includes = function(collection, value)
    return vim.tbl_contains(collection, value)
  end,

  -- empty: Check if the collection is empty
  isEmpty = function(collection)
    return #collection == 0
  end,

  -- map: Creates an table of values by running each element thru callback
  map = function(collection, callback)
    -- Usage:
    -- _.map(collection, 'key')          -- Return table of all keys
    -- _.map(collection, function() end) -- apply function to all items

    -- If a string, return the key by that name
    if type(callback) == 'string' then
      local key = callback
      callback = function(item) 
        return item[key]
      end
    end

    local ret = {}
    -- TODO: ipairs will iterate only on numeric keys and stop on any gap. pairs
    -- will iterate on everything, but do not guarantee order.
    for _, value in ipairs(collection) do
      __.append(ret, callback(value))
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
  end



}
