local class = require("../class")

local errors = {
  TYPE_ERROR = "Specified value is not a string or string_builder."
}

local string_builder = class("string_builder")

string_builder:add_readonly_property("string", "")

string_builder:add_constructor({"string"}, function (self, s)
  if class.type(s) == "string" then
    self.privates.string = s
  else
    error(errors.TYPE_ERROR)
  end
end)

string_builder:add_overloaded_method("append", {"string"}, function (self, s)
  self.privates.string = self.string .. s
  return self.string
end)

string_builder:add_overloaded_method("append", {"string_builder"}, function (self, s)
  return self:append(s.string)
end)

string_builder:add_overloaded_method("prepend", {"string"}, function (self, s)
  self.privates.string = s .. self.string
  return self.string
end)

string_builder:add_overloaded_method("prepend", {"string_builder"}, function (self, s)
  return self:prepend(s.string)
end)

string_builder:add_method("equals", function (self, s)
  local t = class.type(s)
  if t == "string_builder" then
    return self.string == s.string
  elseif t == "string" then
    return self.string == s
  else
    error(errors.TYPE_ERROR)
  end
end)

string_builder:add_method("interpolate", function (self, t)
  local p = "($%b{})"

  local function word(w)
    local s = w:sub(3, -2)
    return t[s] or w
  end

  return self.string:gsub(p, word)
end)

string_builder:add_infix_method("<<", function (self, s)
  return self:prepend(s)
end)

string_builder:add_infix_method(">>", function (self, s)
  return self:append(s)
end)

string_builder:add_infix_method("eq", function (self, s)
  return self:equals(s)
end)

string_builder:add_infix_method("$", function (self, t)
  return self:interpolate(t)
end)

return string_builder
