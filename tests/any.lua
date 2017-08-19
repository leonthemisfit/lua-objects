local class = require("../class")
local any = require("../classes/any")

local a = any("Hello, World!")

assert(class.type(a) == "any")
assert(a.value == "Hello, World!")
assert(a.type == "string")
assert(a 'is' "string")
assert(a:is("string"))

local b = any(any("Hello, world!"))

assert(class.type(b) == "any")
assert(b.value.value == "Hello, world!")
assert(b.type == "any")
assert(b 'is' (any))
assert(b 'is' "any")
assert(b:is(any))
assert(b:is("any"))

local c = any("a")

assert(c == any("a"))
assert(c:equals("a"))
assert(c 'eq' "a")

print("class 'any' tests passed")
