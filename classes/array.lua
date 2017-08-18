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

array:set_meta("ipairs", function (self)
  return self:iter()
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
