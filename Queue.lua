local Object = require("Object")
local Util = require("Util")

local Queue = Object("Queue")

Queue:Add_Constructor({"string"}, function (self, str)
  self.Test = str
end)

Queue:Add_Variable("queue", {})

Queue:Add_Getter("Length", function (tbl)
  return #tbl.__variables.queue
end)

Queue:Add_Property("Test", 2)

Queue:Add_Method("Push", function (self, obj)
  self.__variables.queue[self.Length+1] = obj
end)

Queue:Add_Method("Pop", function (self)
  if self.Length == 0 then
    return nil
  else
    local val = self.__variables.queue[1]
    local tbl = Util.rest(self.__variables.queue)
    self.__variables.queue = tbl
    return val
  end
end)

Queue:Add_Static_Method("Hello", function ()
  return "Hello, world!"
end)

Queue:Set_Meta("tostring", function (self)
  return "Hello, world!"
end)

Queue:Set_Meta("add", function (self, object)
  self:Push(object)
end)

Queue:Set_Meta("unm", function (self)
  return self:Pop()
end)

Queue:Add_Overloaded_Method("overloaded", {"table", "string"}, function (self, s)
  return s
end)

Queue:Add_Overloaded_Method("overloaded", {"table", "string", "number"}, function (self, s, n)
  local t = {}
  for i = 1, n do
    t[i] = s
  end
  return table.concat(t, " ")
end)

return Queue
