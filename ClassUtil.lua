local ClassUtil = {}

function ClassUtil.split(str, sep)
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

function ClassUtil.slice(tbl, x, y)
  local ntbl = {}
  for i = x, y or #tbl do
    ntbl[#ntbl+1] = tbl[i]
  end
  return ntbl
end

function ClassUtil.rest(tbl)
  if #tbl < 2 then
    return {}
  else
    return ClassUtil.slice(tbl, 2)
  end
end

function ClassUtil.deep_copy(old_table, new_table)
  new_table = new_table or {}
  for k,v in pairs(old_table) do
    if type(v) == "table" then
      new_table[k] = ClassUtil.deep_copy(v)
    else
      new_table[k] = v
    end
  end
  return new_table
end

function ClassUtil.deep_copy_meta(old_table, meta_table, new_table)
  new_table = new_table or {}
  for k,v in pairs(old_table) do
    if type(v) == "table" then
      new_table[k] = setmetatable(ClassUtil.deep_copy(v), ClassUtil.deep_copy(meta_table))
    else
      new_table[k] = v
    end
  end
  return new_table
end

function ClassUtil.list(tbl)
  for k,v in pairs(tbl) do
    print(tostring(k) .. ": " .. tostring(v))
  end
end

ClassUtil.sig_separator = "."
function ClassUtil.signature_from_table(tbl)
  return table.concat(tbl, ClassUtil.sig_separator)
end

function ClassUtil.signature(...)
  local tbl = {}
  for i,v in ipairs(table.pack(...)) do
    tbl[i] = type(v)
  end
  return ClassUtil.signature_from_table(tbl)
end

return ClassUtil
