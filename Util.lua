local Util = {}

function Util.split(str, sep)
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

function Util.slice(tbl, x, y)
  local ntbl = {}
  for i = x, y or #tbl do
    ntbl[#ntbl+1] = tbl[i]
  end
  return ntbl
end

function Util.rest(tbl)
  if #tbl < 2 then
    return {}
  else
    return Util.slice(tbl, 2)
  end
end

function Util.deep_copy(old_table, new_table)
  new_table = new_table or {}
  for k,v in pairs(old_table) do
    if type(v) == "table" then
      new_table[k] = Util.deep_copy(v)
    else
      new_table[k] = v
    end
  end
  return new_table
end

function Util.deep_copy_meta(old_table, meta_table, new_table)
  new_table = new_table or {}
  for k,v in pairs(old_table) do
    if type(v) == "table" then
      new_table[k] = setmetatable(Util.deep_copy(v), Util.deep_copy(meta_table))
    else
      new_table[k] = v
    end
  end
  return new_table
end

function Util.list(tbl)
  for k,v in pairs(tbl) do
    print(tostring(k) .. ": " .. tostring(v))
  end
end

function Util.signature_from_table(tbl)
  return table.concat(tbl, ".")
end

function Util.signature(...)
  local tbl = {}
  for i,v in ipairs(table.pack(...)) do
    tbl[i] = type(v)
  end
  return Util.signature_from_table(tbl)
end

return Util
