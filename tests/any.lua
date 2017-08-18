local class = require("../class")
local any = require("../classes/any")

local a = any("Hello, World!")

assert(class.type(a) == "any")
assert(a.value == "Hello, World!")
assert(a.type == "string")
assert(a 'is' "string")

print("class 'any' tests passed")
