local class_util = {}

function class_util.split(str, sep)
  local parts = {}
  local patt = "([^" .. sep .. "]+)"
  for match in str:gmatch(patt) do
    parts[#parts+1] = match
  end
  if #parts == 0 then
    parts[1] = str
  end
  return parts
end

function class_util.slice(tbl, x, y)
  local ntbl = {}
  for i = x, y or #tbl do
    ntbl[#ntbl+1] = tbl[i]
  end
  return ntbl
end

function class_util.rest(tbl)
  if #tbl < 2 then
    return {}
  else
    return class_util.slice(tbl, 2)
  end
end

function class_util.deep_copy(old_table, new_table)
  new_table = new_table or {}
  for k,v in pairs(old_table) do
    if type(v) == "table" then
      new_table[k] = class_util.deep_copy(v)
    else
      new_table[k] = v
    end
  end
  return new_table
end

function class_util.deep_copy_meta(old_table, meta_table, new_table)
  new_table = new_table or {}
  for k,v in pairs(old_table) do
    if type(v) == "table" then
      new_table[k] = setmetatable(class_util.deep_copy(v), class_util.deep_copy(meta_table))
    else
      new_table[k] = v
    end
  end
  return new_table
end

function class_util.list(tbl)
  for k,v in pairs(tbl) do
    print(tostring(k) .. ": " .. tostring(v))
  end
end

function class_util.type(obj)
  if type(obj) == "table" and obj.__name then
    return obj.__name
  else
    return type(obj)
  end
end

class_util.sig_separator = "."
function class_util.signature_from_table(tbl)
  return table.concat(tbl, class_util.sig_separator)
end

function class_util.signature(...)
  local tbl = {}
  for i,v in ipairs(table.pack(...)) do
    tbl[i] = class_util.type(v)
  end
  return class_util.signature_from_table(tbl)
end

function class_util.prepend(tbl, val)
  local ntbl = {val}
  for _,v in ipairs(tbl) do
    ntbl[#ntbl+1] = v
  end
  return ntbl
end

return class_util
