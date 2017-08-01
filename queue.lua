local class = require("class")
local class_util = require("class_util")

local queue = class("queue")

queue:add_constructor({"string"}, function (self, str)
  self.test = str
end)

queue:add_variable("queue", {})
queue:add_variable("private", 0)

queue:add_getter("length", function (tbl)
  return #tbl.P_queue
end)

queue:add_setter("private", function (self, key, val)
  self.P_private = val
end)

queue:add_getter("private", function (self, key)
  return self.P_private
end)

queue:add_property("test", 2)

queue:add_method("push", function (self, obj)
  self.P_queue[self.length+1] = obj
end)

queue:add_method("pop", function (self)
  if self.length == 0 then
    return nil
  else
    local val = self.P_queue[1]
    local tbl = class_util.rest(self.P_queue)
    self.P_queue = tbl
    return val
  end
end)

queue:add_static_method("hello", function ()
  return "Hello, world!"
end)

queue:set_meta("tostring", function (self)
  return "Hello, world!"
end)

queue:set_meta("add", function (self, object)
  self:push(object)
end)

queue:set_meta("unm", function (self)
  return self:pop()
end)

queue:add_overloaded_method("overloaded", {"table", "string"}, function (self, s)
  return s
end)

queue:add_overloaded_method("overloaded", {"table", "string", "number"}, function (self, s, n)
  local t = {}
  for i = 1, n do
    t[i] = s
  end
  return table.concat(t, " ")
end)

queue:add_cast("string", function (self)
  return "Hello, world!"
end)

return queue
