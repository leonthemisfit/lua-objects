local util = require("Util")

local Defaults = {
  GETTER = function (tbl, key)
    return tbl.__variables[key]
  end,
  SETTER = function (tbl, key, val)
    tbl.__variables[key] = val
  end,
  READONLY = function (...)
    error("This property is readonly.")
  end
}

local Meta_Setters = {
  tostring = "__tostring",
  len = "__len",
  gc = "__gc",
  unm = "__unm",
  add = "__add",
  sub = "__sub",
  mul = "__mul",
  div = "__div",
  mod = "__mod",
  pow = "__pow",
  concat = "__concat",
  eq = "__eq",
  lt = "__lt",
  le = "__le"
}

local Object = {}

function Object.Proto()
  return {
    __getters = {},
    __setters = {},
    __variables = {},
    __methods = {},
    __static = {},

    Add_Custom_Property = function (self, name, val, getter, setter)
      self:Add_Variable(name, val)
      self:Add_Getter(name, getter)
      self:Add_Setter(name, setter)
    end,

    Add_Property = function (self, name, val)
      self:Add_Custom_Property(name, val, Defaults.GETTER, Defaults.SETTER)
    end,

    Add_Custom_Readonly_Property = function (self, name, val, getter)
      self:Add_Custom_Property(name, val, getter, Defaults.READONLY)
    end,

    Add_Readonly_Property = function (self, name, val)
      self:Add_Custom_Readonly_Property(name, val, Defaults.GETTER)
    end,

    Add_Method = function (self, name, func)
      self.__methods[name] = func
    end,

    Add_Variable = function (self, name, val)
      self.__variables[name] = val
    end,

    Add_Getter = function (self, name, func)
      self.__getters[name] = func
    end,

    Add_Setter = function (self, name, func)
      self.__setters[name] = func
    end,

    Add_Static_Method = function (self, name, func)
      self.__static[name] = func
    end,

    Set_Meta = function (self, name, val)
      local raw_name = Meta_Setters[name]
      if raw_name then
        local meta = table.deep_copy(getmetatable(self))
        meta[raw_name] = val
        setmetatable(self, meta)
        return true
      else
        return false
      end
    end,

    New = function(self)
      local obj = {}
      obj.__variables = table.deep_copy(self.__variables)
      obj.__getters = table.deep_copy(self.__getters)
      obj.__setters = table.deep_copy(self.__setters)
      obj.__methods = table.deep_copy(self.__methods)
      obj.__static = self.__static
      setmetatable(obj, Object.Meta)
      return obj
    end
  }
end

Object.Meta = {
  __call = function (tbl)
    return tbl:New()
  end,

  __index = function(tbl, key)
    if tbl.__getters[key] then
      return tbl.__getters[key](tbl, key)
    elseif tbl.__methods[key] then
      return tbl.__methods[key]
    elseif tbl.__static[key] then
      return tbl.__static[key]
    else
      return nil
    end
  end,

  __newindex = function (tbl, key, val)
    if tbl.__setters[key] then
      tbl.__setters[key](tbl, key, val)
    else
      error("Keys cannot be added to object this way.")
    end
  end
}

local meta = {
  __call = function ()
    local obj = Object.Proto()
    setmetatable(obj, Object.Meta)
    return obj
  end,

  __newindex = function (tbl, key, val)
    error("Keys cannot be added to object this way.")
  end
}

setmetatable(Object, meta)

return Object
