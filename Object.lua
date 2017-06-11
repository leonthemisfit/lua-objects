local Util = require("Util")

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

local Errors = {
  KEY_EXISTS = "The key you are attempting to add already exists in object.",
  KEY_VIOLATION = "Keys cannot be added to the onject with dot notation."
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
    __name = "",

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
      if self.__methods[name] then
        error(Errors.KEY_EXISTS)
      end
      self.__methods[name] = func
    end,

    Add_Variable = function (self, name, val)
      if self.__variables[name] then
        error(Erros.KEY_EXISTS)
      end
      self.__variables[name] = val
    end,

    Add_Getter = function (self, name, func)
      if self.__getters[name] then
        error(Errors.KEY_EXISTS)
      end
      self.__getters[name] = func
    end,

    Add_Setter = function (self, name, func)
      if self.__setters[name] then
        error(Errors.KEY_EXISTS)
      end
      self.__setters[name] = func
    end,

    Add_Static_Method = function (self, name, func)
      if self.__static[name] then
        error(Errors.KEY_EXISTS)
      end
      self.__static[name] = func
    end,

    Set_Meta = function (self, name, val)
      local raw_name = Meta_Setters[name]
      if raw_name then
        local meta = getmetatable(self)
        meta[raw_name] = val
        return true
      else
        return false
      end
    end,

    Is_Instance = function (self, tbl)
      return getmetatable(self) == getmetatable(tbl)
    end,

    New = function(self)
      local obj = {}
      obj.__variables = Util.deep_copy(self.__variables)
      obj.__getters = Util.deep_copy(self.__getters)
      obj.__setters = Util.deep_copy(self.__setters)
      obj.__methods = Util.deep_copy(self.__methods)
      obj.__static = self.__static
      setmetatable(obj, getmetatable(self))
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
      error(Errors.KEY_VIOLATION)
    end
  end
}

local meta = {
  __call = function (tbl, name)
    local obj = Object.Proto()
    obj.__name = name
    setmetatable(obj, Util.deep_copy(Object.Meta))
    return obj
  end,

  __newindex = function (tbl, key, val)
    error(Errors.KEY_VIOLATION)
  end
}

setmetatable(Object, meta)

return Object
