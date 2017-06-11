local Util = {}

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
    return table.slice(tbl, 2)
  end
end

function Util.deep_copy(old_table, new_table)
  new_table = new_table or {}
  for k,v in pairs(old_table) do
    if type(v) == "table" then
      new_table[k] = table.deep_copy(v)
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
