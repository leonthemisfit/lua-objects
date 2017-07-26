local Util = require("Util")

local Errors = {
  KEY_EXISTS = "The key you are attempting to add already exists in object.",
  KEY_VIOLATION = "Keys cannot be added to the onject with dot notation.",
  READONLY = "This property is readonly and cannot be assigned to.",
  BAD_SIGNATURE = "The method call did not match any known signature.",
  SIGNATURE_EXISTS = "The signature supplied already exists in the object.",
  PARAM_ERROR = "Constructor parameter does not match an object property.",
  DUPLICATE_INHERITOR = "This object is already inherited.",
  INVALID_META = "The metafunction name provided is not valid."
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

local Class = {}

function Class.Type(obj)
  if type(obj) == "table" and obj.__name then
    return obj.__name
  else
    return type(obj)
  end
end

function Class.Proto()
  local proto = {
    __getters = {},
    __setters = {},
    __variables = {},
    __methods = {},
    __static = {},
    __overloads = {},
    __constructors = {},
    __inheritors = {},
    __privates = {},
    __locks = {},
    __name = "",

    __caller = function (self, ...)
      self.__locks[#self.__locks+1] = true
      local func = rawget(self, "__callfunc")
      self.__privates = self.__variables
      local res = func(self, ...)
      rawset(self, "__callfunc", nil)
      self.__locks = Util.rest(self.__locks)
      if #self.__locks == 0 then
        self.__privates = {}
      end
      return res
    end,

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

    Add_Constructor = function (self, sig_table, func)
      local sig = Util.signature_from_table(sig_table)
      if self.__constructors[sig] then
        error(Errors.SIGNATURE_EXISTS)
      end
      self.__constructors[sig] = func
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
      name = "P_" .. name
      if self.__variables[name] then
        error(Errors.KEY_EXISTS)
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
      else
        error(Errors.INVALID_META)
      end
    end,

    Implements = function (self, obj)
      if self.__inheritors[obj.__name] then
        error(Errors.DUPLICATE_INHERITOR)
      end

      self.__inheritors[obj.__name] = true

      for i,tbl in ipairs(obj.__inherited) do
        for k,v in pairs(tbl) do
          if tbl == obj.__getters then
            self:Add_Getter(k, v)
          elseif tbl == obj.__setters then
            self:Add_Setter(k, v)
          elseif tbl == obj.__variables then
            self:Add_Variable(k:sub(3), v)
          elseif tbl == obj.__methods then
            self:Add_Method(k, v)
          elseif tbl == obj.__static then
            self:Add_Static_Method(k, v)
          elseif tbl == obj.__overloads then
            for sig,func in ipairs(v.__sigs) do
              self:Add_Overloaded_Method(k,
               Util.split(sig, Util.sig_separator), func)
            end
          elseif tbl == obj.__inheritors then
            self.__inheritors[k] = true
          end
        end
      end

    end,

    Is_Instance = function (self, tbl)
      return getmetatable(self) == getmetatable(tbl)
    end,

    Is_Inherited = function (self, obj)
      if obj.__inheritors[self.__name] then
        return true
      else
        return self:Is_Instance(obj)
      end
    end,

    New = function (self, ...)
      local obj = {}
      obj.__name = self.__name
      obj.__variables = Util.deep_copy(self.__variables)
      obj.__getters = Util.deep_copy(self.__getters)
      obj.__setters = Util.deep_copy(self.__setters)
      obj.__methods = Util.deep_copy(self.__methods)
      obj.__overloads = Util.deep_copy_meta(self.__overloads, Sig_Meta)
      obj.__constructors = Util.deep_copy(self.__constructors)
      obj.__inheritors = Util.deep_copy(self.__inheritors)
      obj.__static = self.__static
      obj.__privates = {}
      obj.__locks = {}
      obj.__caller = self.__caller
      obj.__indexed =
        {obj.__getters, obj.__methods, obj.__static, obj.__overloads}
      setmetatable(obj, getmetatable(self))

      local sig = Util.signature(...)
      if obj.__constructors[sig] then
        rawset(obj, "__callfunc", obj.__constructors[sig])
        obj.__caller(obj, ...)
      elseif sig == "table" then
        local params = table.pack(...)
        for prop,val in pairs(params[1]) do
          if not obj.__setters[prop] then
            error(Errors.PARAM_ERROR)
          end
          rawset(obj, "__callfunc", obj.__setters[prop])
          obj.__caller(obj, prop, val)
        end
      elseif sig == "" then
        return obj
      else
        error(Errors.BAD_SIGNATURE)
      end

      return obj
    end
  }

  proto.__indexed =
    {proto.__getters, proto.__methods, proto.__static, proto.__overloads}
  proto.__inherited =
    {proto.__getters, proto.__setters, proto.__variables, proto.__methods,
     proto.__static, proto.__overloads}
  return proto
end

Class.Meta = {
  __call = function (tbl, ...)
    return tbl:New(...)
  end,

  __index = function(tbl, key)
    if tbl.__getters[key] then
      rawset(tbl, "__callfunc", tbl.__getters[key])
      return tbl.__caller(tbl, key)
    elseif tbl.__privates[key] then
      return tbl.__privates[key]
    else
      for _, itbl in ipairs(tbl.__indexed) do
        if itbl[key] then
          if itbl ~= tbl.__static then
            rawset(tbl, "__callfunc", itbl[key])
            return tbl.__caller
          else
            return itbl[key]
          end
        end
      end
    end
  end,

  __newindex = function (tbl, key, val)
    if tbl.__setters[key] then
      rawset(tbl, "__callfunc", tbl.__setters[key])
      tbl.__caller(tbl, key, val)
    elseif tbl.__privates[key] then
      tbl.__variables[key] = val
    else
      error(Errors.KEY_VIOLATION)
    end
  end
}

function Class.New(name)
  local obj = Class.Proto()
  obj.__name = name
  setmetatable(obj, Util.deep_copy(Class.Meta))
  return obj
end

local meta = {
  __call = function (tbl, name)
    return Class.New(name)
  end,

  __newindex = function (tbl, key, val)
    error(Errors.KEY_VIOLATION)
  end
}

setmetatable(Class, meta)

return Class
