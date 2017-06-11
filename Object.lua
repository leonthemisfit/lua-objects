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

local Object = {}

function Object.Proto()
  return {
    __getters = {},
    __setters = {},
    __variables = {},
    __methods = {},

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

    New = function(self)
      local obj = {}
      obj.__variables = table.deep_copy(self.__variables)
      obj.__getters = table.deep_copy(self.__getters)
      obj.__setters = table.deep_copy(self.__setters)
      obj.__methods = table.deep_copy(self.__methods)
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
