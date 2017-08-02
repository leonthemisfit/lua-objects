local queue = require("queue")
local class_util = require("class_util")
local class = require("class")

local test_queue = queue {
  test = "hunter2"
}

assert(test_queue.length == 0)
test_queue:push("A")
assert(test_queue.length == 1)
test_queue:push("B")
assert(test_queue.length == 2)
_ = test_queue + "C"
assert(test_queue.length == 3)
assert(test_queue:pop() == "A")
assert(test_queue.length == 2)
assert(test_queue:pop() == "B")
assert(test_queue.length == 1)
assert(-test_queue == "C")
assert(test_queue.length == 0)
assert(-test_queue == nil)
assert(test_queue.length == 0)
assert(tostring(test_queue) == "hunter2")
assert(test_queue.hello() == "Hello, world!")
assert(queue.hello() == "Hello, world!")
assert(test_queue.hello == queue.hello)
assert(queue:is_instance(test_queue))
assert(test_queue:overloaded("test") == "test")
assert(test_queue:overloaded("test", 2) == "test test")
assert(test_queue.test == "hunter2", test_queue.test)

local test_queue2 = queue("something clever")

assert(test_queue2.test == "something clever")

local event_queue = class("event_queue")
event_queue:implements(queue)

event_queue:add_method("register", function (self, event, func)

end)

local evt = event_queue()

assert(evt.length == 0)
assert(evt.register ~= nil)
assert(test_queue.register == nil)
evt:push("test")
assert(evt.length == 1)
assert(test_queue.length == 0)
assert(evt:pop() == "test")
assert(evt.length == 0)
assert(event_queue:is_inherited(evt))
assert(queue:is_inherited(evt))
assert(queue:is_inherited(event_queue))
assert(test_queue.test_queue == nil)
assert(test_queue.Private == nil)
assert(test_queue.private == 0)
test_queue.private = ""
assert(test_queue.private == "")

assert(class.type("Hello world") == "string")
assert(class.type(2) == "number")
assert(class.type({1, 2, 3}) == "table")
assert(class.type(nil) == "nil")
assert(class.type(function () end) == "function")
assert(class.type(test_queue) == "queue")
assert(class.type(evt) == "event_queue")

local casted = test_queue:cast("string")
assert(class.type(casted) == "string")
assert(casted == "Hello, world!")

assert(test_queue.privates == nil)

assert(class_util.prepend({}, "")[1] == "")
