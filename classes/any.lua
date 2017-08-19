local class = require("../class")
local class_util = require("../class_util")

local any = class("any")

any:add_property("value", {})

any:add_getter("type", function (self)
  return class.type(self.value)
end)

any:add_infix_method("is", function (left, right)
  return left:is(right)
end)

local onew = any.new
function any.new(self, val)
  return onew(self, {value = val})
end

any:add_method("is", function (self, right)
  if class.type(right) == "string" then
    return self.type == right
  elseif right.is_inherited then
    return right:is_inherited(self.value)
  else
    return false
  end
end)

any:add_method("equals", function (self, right)
  if class.type(right) == "any" then
    return self.value == right.value
  else
    return self.value == right
  end
end)

any:add_infix_method("eq", function (self, right)
  return self:equals(right)
end)

any:set_meta("eq", function (self, right)
  return self 'eq' (right)
end)

return any
