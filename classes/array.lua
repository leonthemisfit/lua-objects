local class = require("../class")
local class_util = require("../class_util")

local defaults = {
  string = "",
  number = 0,
  table = {}
}

local errors = {
  OUT_OF_BOUNDS = "Array index is out of bounds.",
  TYPE_ERROR = "Specified type does not match array type.",
  LENGTH_ERROR = "Length specified is not valid."
}

local array = class("array")

array:add_readonly_property("length", 0)
array:add_readonly_property("type", "")

array:add_variable("table", {})

array:add_getter("first", function (self)
  return self[1]
end)

array:add_getter("rest", function (self)
  local t = class_util.rest(self.privates.table)
  return array(t)
end)

array:add_getter("unique", function (self)
  local keys = {}
  for v in self:foreach() do
    keys[v] = true
  end

  local arr = array(self.type, #keys)
  local i = 1
  for k, _ in pairs(keys) do
    arr[i] = k
    i = i + 1
  end

  return arr
end)

array:add_constructor({"string", "number"}, function (self, type_string, length)
  if length > 0 then
    self.privates.length = length
    self.privates.type = type_string
  else
    error(errors.LENGTH_ERROR)
  end
end)

array:add_constructor({"table"}, function (self, vals)
  local length = #vals
  if length > 0 then
    local type = class.type(vals[1])
    self.privates.type = type
    self.privates.length = length

    for i, v in ipairs(vals) do
      self[i] = v
    end
  else
    error(errors.LENGTH_ERROR)
  end
end)

array:add_method("iter", function (self)
  local i = 0
  return function ()
    i = i + 1
    if i <= self.length then
      return i, self[i]
    end
  end
end)

array:add_method("foreach", function (self, func)
  local i = 0
  return function ()
    i = i + 1
    if i <= self.length then
      return self[i]
    end
  end
end)

array:add_method("table_map", function (self, func)
  local t = {}
  for i,v in self:iter() do
    t[i] = func(v)
  end
  return t
end)

array:add_method("map", function (self, func)
  return array(self:table_map(func))
end)

array:add_overloaded_method("slice", {"number"}, function (self, x)
  return array(class_util.slice(self.privates.table, x))
end)

array:add_overloaded_method("slice", {"number", "number"}, function (self, x, y)
  return array(class_util.slice(self.privates.table, x, y))
end)

array:add_method("any", function (self, func)
  for v in self:foreach() do
    if func(v) then
      return true
    end
  end
  return false
end)

array:add_method("any_value", function (self, val)
  for v in self:foreach() do
    if v == val then
      return true
    end
  end
  return false
end)

array:add_method("all", function (self, func)
  for v in self:foreach() do
    if not func(v) then
      return false
    end
  end
  return true
end)

array:add_method("all_values", function (self, val)
  for v in self:foreach() do
    if v ~= val then
      return false
    end
  end
  return true
end)

array:add_method("where", function (self, func)
  local t = {}
  for v in self:foreach() do
    if func(v) then
      t[#t+1] = v
    end
  end
  if #t > 0 then
    return array(t)
  end
end)

array:add_method("where_value", function (self, val)
  local t = {}
  for v in self:foreach() do
    if v == val then
      t[#t+1] = v
    end
  end
  if #t > 0 then
    return array(t)
  end
end)

array:add_infix_method("any", function (self, func)
  return self:any(func)
end)

array:add_infix_method("any_value", function (self, val)
  return self:any_value(val)
end)

array:add_infix_method("all", function (self, func)
  return self:all(func)
end)

array:add_infix_method("all_values", function (self, val)
  return self:all_values(val)
end)

array:add_infix_method("where", function (self, func)
  return self:where(func)
end)

array:add_infix_method("where_value", function (self, val)
  return self:where_value(val)
end)

array:set_meta("ipairs", function (self)
  return self:iter()
end)

array:set_meta("len", function (self)
  return self.length
end)

array:add_cast("table", function (self)
  return self.privates.table
end)

local mt = getmetatable(array)
local oindex = mt.__index
local onindex = mt.__newindex

local function index(self, key)
  if class.type(key) == "number" then
    if key > 0 and key <= self.length then
      return self.privates.table[key] or defaults[self.type]
    else
      error(errors.OUT_OF_BOUNDS)
    end
  else
    return oindex(self, key)
  end
end

function mt.__index (self, key)
  local caller = self:__get_caller(index)
  return caller(self, key)
end

local function newindex(self, key, val)
  if class.type(key) == "number" then
    if key > 0 and key <= self.length then
      if class.type(val) == self.type then
        self.privates.table[key] = val
      else
        error(errors.TYPE_ERROR)
      end
    else
      error(errors.OUT_OF_BOUNDS)
    end
  else
    return onindex(self, key, val)
  end
end

function mt.__newindex(self, key, val)
  local caller = self:__get_caller(newindex)
  return caller(self, key, val)
end

return array
