local Queue = require("Queue")
local Util = require("Util")
local Object = require("Object")

local queue = Queue {
  Test = "hunter2"
}

assert(queue.Length == 0)
queue:Push("A")
assert(queue.Length == 1)
queue:Push("B")
assert(queue.Length == 2)
_ = queue + "C"
assert(queue.Length == 3)
assert(queue:Pop() == "A")
assert(queue.Length == 2)
assert(queue:Pop() == "B")
assert(queue.Length == 1)
assert(-queue == "C")
assert(queue.Length == 0)
assert(-queue == nil)
assert(queue.Length == 0)
assert(tostring(queue) == "Hello, world!")
assert(queue.Hello() == "Hello, world!")
assert(Queue.Hello() == "Hello, world!")
assert(queue.Hello == Queue.Hello)
assert(Queue:Is_Instance(queue))
assert(queue:overloaded("test") == "test")
assert(queue:overloaded("test", 2) == "test test")
assert(queue.Test == "hunter2", queue.Test)

local queue2 = Queue("something clever")

assert(queue2.Test == "something clever")

local EventQueue = Object("EventQueue")
EventQueue:Implements(Queue)

local evt = EventQueue()
