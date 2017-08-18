local class = require("../class")
local class_util = require("../class_util")
local any = require("../classes/any")

local function next_index(tbl, index)
  while tbl[index] ~= nil do
    index = index + 1
  end
  return index
end

local enum = class("enum")

enum:add_variable("index", 1)
enum:add_variable("values", {})
enum:add_variable("strings", {})
enum:add_variable("keys", {})

enum:add_constructor({"table"}, function (self, tbl)
  for _,v in ipairs(tbl) do
    self 'add' (v)
  end
end)

enum:add_method("get_value", function (self, key)
  return self.privates.keys[key]
end)

enum:add_method("get_key", function (self, value)
  return self.privates.values[value]
end)

enum:add_method("get_string", function (self, key)
  return self.privates.strings[key] or ""
end)

enum:add_overloaded_method("add_value", {"any", "number"}, function (self, val, n)
  self.privates.index = next_index(self.privates.values, n)
  self.privates.values[self.privates.index] = val.value
  self.privates.keys[val.value] = self.privates.index
  return self.privates.index
end)

enum:add_overloaded_method("add_value", {"any", "string", "number"}, function (self, val, s, n)
  local index = self:add_value(val, n)
  self.privates.strings[index] = s
  return index
end)

enum:add_overloaded_method("add_value", {"any"}, function (self, val)
  return self:add_value(val, self.privates.index)
end)

enum:add_overloaded_method("add_value", {"any", "string"}, function (self, val, s)
  return self:add_value(val, s, self.privates.index)
end)

enum:add_infix_method("add", function (self, tbl)
  return self:add_value(any(tbl[1]), table.unpack(class_util.rest(tbl)))
end)

local mt = getmetatable(enum)
local oindex = mt.__index
function mt.__index(self, key)
  local val = oindex(self, key)
  if val ~= nil then
    return val
  else
    return self:get_value(key)
  end
end

return enum
