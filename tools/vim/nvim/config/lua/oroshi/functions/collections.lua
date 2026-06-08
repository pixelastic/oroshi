return {
  -- append: Add an element at the end of a table
  append = function(container, item)
    table.insert(container, item)
  end,
  -- prepend: Add an element at the beginning of a table
  prepend = function(container, item)
    table.insert(container, 1, item)
  end,
}
