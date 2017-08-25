local array = require("../classes/array")

local a = array("string", 3)

assert(a.first == "")
assert(a[1] == "")
assert(a[2] == "")
assert(a[3] == "")
assert(a.type == "string")
assert(a.length == 3)
assert(#a == 3)

a[1] = "Hello"
a[2] = "World"
a[3] = "!"

assert(a.first == "Hello")
assert(a[1] == "Hello")
assert(a[2] == "World")
assert(a[3] == "!")

local b = a.rest

assert(b.type == "string")
assert(b.length == 2)
assert(#b == 2)
assert(b.first == "World")
assert(b[1] == "World")
assert(b[2] == "!")

local c = a:slice(2)

assert(c.type == "string")
assert(c.length == 2)
assert(#c == 2)
assert(c.first == "World")
assert(c[1] == "World")
assert(c[2] == "!")

local d = a:slice(1, 2)

assert(d.type == "string")
assert(d.length == 2)
assert(#d == 2)
assert(d.first == "Hello")
assert(d[1] == "Hello")
assert(d[2] == "World")

local e = array {1, 2, 3}

assert(e.type == "number")
assert(e.length == 3)
assert(#e == 3)
assert(e.first == 1)
assert(e[1] == 1)
assert(e[2] == 2)
assert(e[3] == 3)

for i, v in e:iter() do
  assert(i == v)
end

local f = e:map(function (v) return v * 2 end)

assert(f.type == "number")
assert(f.length == 3)
assert(#f == 3)
assert(f.first == 2)
assert(f[1] == 2)
assert(f[2] == 4)
assert(f[3] == 6)

local indx = 0
for v in f:foreach() do
  indx = indx + 1
  assert(v == indx * 2)
end

local g = array {
  array {1, 2, 3},
  array {"a", "b", "c"}
}

assert(g.type == "array")
assert(g.length == 2)
assert(#g == 2)

assert(g[1].type == "number")
assert(g[1].length == 3)
assert(#g[1] == 3)
assert(g[1][1] == 1)
assert(g[1][2] == 2)
assert(g[1][3] == 3)

assert(g[2].type == "string")
assert(g[2].length == 3)
assert(#g[2] == 3)
assert(g[2][1] == "a")
assert(g[2][2] == "b")
assert(g[2][3] == "c")

local h = array { 1, 2, 2, 3, 4, 4, 5 }

local function even(n)
  return n % 2 == 0
end

local function gtzero(n)
  return n > 0
end

assert(h.type == "number")
assert(h.length == 7)
assert(#h == 7)

assert(h:any(even))
assert(h 'any' (even))
assert(h:any_value(1))
assert(h 'any_value' (1))

assert(h:all(gtzero))
assert(h 'all' (gtzero))
assert(h:all_values(1) == false)
assert(h 'all_values' (1) == false)

local i = h 'where' (even)

assert(i.type == "number")
assert(i.length == 4)
assert(#i == 4)

local j = h 'where_value' (2)

assert(j.type == "number")
assert(j.length == 2)
assert(#j == 2)

local k = h.unique

assert(k.type == "number")
assert(k.length == 5)
assert(#k == 5)
assert(k[1] == 1)
assert(k[2] == 2)
assert(k[3] == 3)
assert(k[4] == 4)
assert(k[5] == 5)

print("class 'array' tests passed")
