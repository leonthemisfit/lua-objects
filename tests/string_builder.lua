local string_builder = require("../classes/string_builder")

local a = string_builder()

assert(a:prepend("l") == "l")
assert(a.string == "l")
assert(a:prepend(string_builder("e")) == "el")
assert(a.string == "el")
assert(a '<<' "H" == "Hel")
assert(a.string == "Hel")
assert(a:append("l") == "Hell")
assert(a.string == "Hell")
assert(a:append(string_builder("o")) == "Hello")
assert(a.string == "Hello")
assert(a '>>' "," == "Hello,")
assert(a.string == "Hello,")
assert(a '<<' (string_builder(" ")) == " Hello,")
assert(a.string == " Hello,")
assert(a '>>' (string_builder(" world! ")) == " Hello, world! ")
assert(a.string == " Hello, world! ")
assert(a:equals(" Hello, world! "))
assert(a:equals(string_builder(" Hello, world! ")))
assert(a 'eq' " Hello, world! ")
assert(a 'eq' (string_builder(" Hello, world! ")))

local b = string_builder("Hello, ${place}!")

assert(b.string == "Hello, ${place}!")
assert(b:interpolate {place = "World"} == "Hello, World!")
assert(b '$' {place = "World"} == "Hello, World!")

local c = string_builder("test")

assert(c.length == 4)
assert(c '>>' "ing" == "testing")
assert(c.length == 7)

if _VERSION ~= "Lua 5.1" then
  assert(#c == 7)
end

print("class 'string_builder' tests passed")
