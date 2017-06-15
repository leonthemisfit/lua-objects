local Util = require("Util")

local Errors = {
  KEY_EXISTS = "The key you are attempting to add already exists in object.",
  KEY_VIOLATION = "Keys cannot be added to the onject with dot notation.",
  READONLY = "This property is readonly and cannot be assigned to.",
  BAD_SIGNATURE = "The method call did not match any known signature.",
  SIGNATURE_EXISTS = "The signature supplied already exists in the object."
}

local Defaults = {
  GETTER = function (tbl, key)
    return tbl.__variables[key]
  end,

  SETTER = function (tbl, key, val)
    tbl.__variables[key] = val
  end,

  READONLY = function (...)
    error(Errors.READONLY)
  end,
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

local Signature = {}

local Sig_Meta = {
  __call = function (tbl, ...)
    local sig = Util.signature(...)
    if tbl.__sigs and tbl.__sigs[sig] then
      return tbl.__sigs[sig](...)
    else
      error(Errors.BAD_SIGNATURE)
    end
  end
}

function Signature.Proto()
  local sig = {
    __sigs = {}
  }
  return sig
end

local Object = {}

function Object.Proto()
  return {
    __getters = {},
    __setters = {},
    __variables = {},
    __methods = {},
    __static = {},
    __overloads = {},
    __indexed = {__getters, __methods, __static, __overloads},
    __name = "",

    Validate_Index_Key = function (self, key)
      for _,tbl in ipairs(self.__indexed) do
        if tbl[id] then
          error(Errors.KEY_EXISTS)
        end
      end
    end,

    Validate_Overload_Key = function (self, key)
      for _,tbl in ipairs(self.__indexed) do
        if (tbl ~= self.__overloads and tbl[key]) then
          error(Errors.KEY_EXISTS)
        end
      end
    end,

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
      self:Validate_Index_Key(name)
      self.__methods[name] = func
    end,

    Add_Variable = function (self, name, val)
      if self.__variables[name] then
        error(Erros.KEY_EXISTS)
      end
      self.__variables[name] = val
    end,

    Add_Getter = function (self, name, func)
      self:Validate_Index_Key(name)
      self.__getters[name] = func
    end,

    Add_Setter = function (self, name, func)
      if self.__setters[name] then
        error(Errors.KEY_EXISTS)
      end
      self.__setters[name] = func
    end,

    Add_Static_Method = function (self, name, func)
      self:Validate_Index_Key(name)
      self.__static[name] = func
    end,

    Add_Overloaded_Method = function (self, name, sig_table, func)
      self:Validate_Overload_Key(name)

      if not self.__overloads[name] then
        self.__overloads[name] = Signature.Proto()
      end

      local sig = Util.signature_from_table(sig_table)
      if self.__overloads[name].__sigs[sig] then
        error(Errors.SIGNATURE_EXISTS)
      end

      self.__overloads[name].__sigs[sig] = func
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
      obj.__overloads = Util.deep_copy_meta(self.__overloads, Sig_Meta)
      obj.__static = self.__static
      obj.__indexed =
        {obj.__getters, obj.__methods, obj.__static, obj.__overloads}
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
      print("getter found")
      return tbl.__getters[key](tbl, key)
    --[[elseif tbl.__methods[key] then
      return tbl.__methods[key]
    elseif tbl.__static[key] then
      return tbl.__static[key]
    elseif tbl.__overloads[key] then
      return tbl.__overloads[key]
    else
      return nil]]
    else
      print("not a getter")
      for _, tbl in ipairs(tbl.__indexed) do
        print("Checking Tables")
        if tbl[key] then return tbl[key] end
      end
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
