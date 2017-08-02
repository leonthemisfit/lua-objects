local class_util = require("class_util")

local errors = {
  KEY_EXISTS = "The key you are attempting to add already exists in object.",
  KEY_VIOLATION = "Keys cannot be added to the object with dot notation.",
  READONLY = "This property is readonly and cannot be assigned to.",
  BAD_SIGNATURE = "The method call did not match any known signature.",
  SIGNATURE_EXISTS = "The signature supplied already exists in the object.",
  PARAM_ERROR = "Constructor parameter does not match an object property.",
  DUPLICATE_INHERITOR = "This object is already inherited.",
  INVALID_META = "The metafunction name provided is not valid.",
  META_NOT_FUNCTION = "Only functions may be set for meta values.",
  DUPLICATE_CAST = "A cast to the specified type has already been adedded.",
  INVALID_CAST = "Attempt to cast to a type without a cast function specified."
}

local defaults = {
  GETTER = function (self, key)
    return self.__variables[key]
  end,

  SETTER = function (self, key, val)
    self.__variables[key] = val
  end,

  READONLY = function (...)
    error(errors.READONLY)
  end,
}

local meta_setters = {
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

local signature = {}

local sig_meta = {
  __call = function (self, ...)
    local sig = class_util.signature(...)
    if self.__sigs and self.__sigs[sig] then
      return self.__sigs[sig](...)
    else
      error(errors.BAD_SIGNATURE)
    end
  end
}

function signature.proto()
  local sig = {
    __sigs = {}
  }
  return sig
end

local class = {}

class.type = class_util.type

function class.proto()
  local proto = {
    __getters = {},
    __setters = {},
    __variables = {},
    __methods = {},
    __static = {},
    __overloads = {},
    __constructors = {},
    __inheritors = {},
    __locks = {},
    __casts = {},
    __name = "",
    privates = nil,

    __get_caller = function (self, func)
      return function (self, ...)
        self.__locks[#self.__locks+1] = true
        rawset(self, "privates", self.__variables)
        local res = func(self, ...)
        self.__locks = class_util.rest(self.__locks)
        if #self.__locks == 0 then
          rawset(self, "privates", nil)
        end
        return res
      end
    end,

    validate_index_key = function (self, key)
      for _,tbl in ipairs(self.__indexed) do
        if tbl[id] then
          error(errors.KEY_EXISTS)
        end
      end
    end,

    validate_overload_key = function (self, key)
      for _,tbl in ipairs(self.__indexed) do
        if (tbl ~= self.__overloads and tbl[key]) then
          error(errors.KEY_EXISTS)
        end
      end
    end,

    add_constructor = function (self, sig_table, func)
      local sig = class_util.signature_from_table(sig_table)
      if self.__constructors[sig] then
        error(errors.SIGNATURE_EXISTS)
      end
      self.__constructors[sig] = func
    end,

    add_custom_property = function (self, name, val, getter, setter)
      self:add_variable(name, val)
      self:add_getter(name, getter)
      self:add_setter(name, setter)
    end,

    add_property = function (self, name, val)
      self:add_custom_property(name, val, defaults.GETTER, defaults.SETTER)
    end,

    add_custom_readonly_property = function (self, name, val, getter)
      self:add_custom_property(name, val, getter, defaults.READONLY)
    end,

    add_readonly_property = function (self, name, val)
      self:add_custom_readonly_property(name, val, defaults.GETTER)
    end,

    add_method = function (self, name, func)
      self:validate_index_key(name)
      self.__methods[name] = func
    end,

    add_variable = function (self, name, val)
      if self.__variables[name] then
        error(errors.KEY_EXISTS)
      end
      self.__variables[name] = val
    end,

    add_getter = function (self, name, func)
      self:validate_index_key(name)
      self.__getters[name] = func
    end,

    add_setter = function (self, name, func)
      if self.__setters[name] then
        error(errors.KEY_EXISTS)
      end
      self.__setters[name] = func
    end,

    add_static_method = function (self, name, func)
      self:validate_index_key(name)
      self.__static[name] = func
    end,

    add_overloaded_method = function (self, name, sig_table, func)
      self:validate_overload_key(name)

      if not self.__overloads[name] then
        self.__overloads[name] = signature.proto()
      end

      sig_table = class_util.prepend(sig_table, self.__name)
      local sig = class_util.signature_from_table(sig_table)
      if self.__overloads[name].__sigs[sig] then
        error(errors.SIGNATURE_EXISTS)
      end

      self.__overloads[name].__sigs[sig] = func
    end,

    set_meta = function (self, name, val)
      local raw_name = meta_setters[name]
      if raw_name then
        if type(val) == "function" then
          local meta = getmetatable(self)
          meta[raw_name] = self:__get_caller(val)
        else
          error(errors.META_NOT_FUNCTION)
        end
      else
        error(errors.INVALID_META)
      end
    end,

    implements = function (self, obj)
      if self.__inheritors[obj.__name] then
        error(errors.DUPLICATE_INHERITOR)
      end

      self.__inheritors[obj.__name] = true

      for i,tbl in ipairs(obj.__inherited) do
        for k,v in pairs(tbl) do
          if tbl == obj.__getters then
            self:add_getter(k, v)
          elseif tbl == obj.__setters then
            self:add_setter(k, v)
          elseif tbl == obj.__variables then
            self:add_variable(k, v)
          elseif tbl == obj.__methods then
            self:add_method(k, v)
          elseif tbl == obj.__static then
            self:add_static_method(k, v)
          elseif tbl == obj.__overloads then
            for sig,func in ipairs(v.__sigs) do
              self:add_overloaded_method(k,
               class_util.split(sig, class_util.sig_separator), func)
            end
          elseif tbl == obj.__inheritors then
            self.__inheritors[k] = true
          end
        end
      end

    end,

    is_instance = function (self, tbl)
      return getmetatable(self) == getmetatable(tbl)
    end,

    is_inherited = function (self, obj)
      if obj.__inheritors[self.__name] then
        return true
      else
        return self:is_instance(obj)
      end
    end,

    add_cast = function (self, type_string, func)
      if self.__casts[type_string] then
        error(errors.DUPLICATE_CAST)
      else
        self.__casts[type_string] = func
      end
    end,

    cast = function (self, type_string)
      if self.__casts[type_string] then
        local func = self.__casts[type_string]
        local caller = self:__get_caller(func)
        return caller(self, type_string)
      else
        error(errors.INVALID_CAST)
      end
    end,

    new = function (self, ...)
      local obj = {}
      obj.__name = self.__name
      obj.__variables = class_util.deep_copy(self.__variables)
      obj.__getters = class_util.deep_copy(self.__getters)
      obj.__setters = class_util.deep_copy(self.__setters)
      obj.__methods = class_util.deep_copy(self.__methods)
      obj.__overloads = class_util.deep_copy_meta(self.__overloads, sig_meta)
      obj.__constructors = class_util.deep_copy(self.__constructors)
      obj.__inheritors = class_util.deep_copy(self.__inheritors)
      obj.__casts = class_util.deep_copy(self.__casts)
      obj.__static = self.__static
      obj.privates = nil
      obj.__locks = {}
      obj.__get_caller = self.__get_caller
      obj.cast = self.cast
      obj.__indexed =
        {obj.__getters, obj.__methods, obj.__static, obj.__overloads}
      setmetatable(obj, getmetatable(self))

      local sig = class_util.signature(...)
      if obj.__constructors[sig] then
        local func = obj.__constructors[sig]
        local caller = obj.__get_caller(obj, func)
        caller(obj, ...)
      elseif sig == "table" then
        local params = table.pack(...)
        for prop,val in pairs(params[1]) do
          if not obj.__setters[prop] then
            error(errors.PARAM_ERROR)
          end
          local func = obj.__setters[prop]
          local caller = obj.__get_caller(obj, func)
          caller(obj, prop, val)
        end
      elseif sig == "" then
        return obj
      else
        error(errors.BAD_SIGNATURE)
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

class.meta = {
  __call = function (self, ...)
    return self:new(...)
  end,

  __index = function(self, key)
    if self.__getters[key] then
      local func = self.__getters[key]
      local caller = self:__get_caller(func)
      return caller(self, key)
    else
      for _, tbl in ipairs(self.__indexed) do
        if tbl[key] then
          if tbl ~= self.__static then
            return self:__get_caller(tbl[key])
          else
            return tbl[key]
          end
        end
      end
    end
  end,

  __newindex = function (self, key, val)
    if self.__setters[key] then
      local func = self.__setters[key]
      local caller = self:__get_caller(func)
      caller(self, key, val)
    else
      error(errors.KEY_VIOLATION)
    end
  end
}

function class.new(name)
  local obj = class.proto()
  obj.__name = name
  setmetatable(obj, class_util.deep_copy(class.meta))
  return obj
end

local meta = {
  __call = function (self, name)
    return class.new(name)
  end,

  __newindex = function (self, key, val)
    error(errors.KEY_VIOLATION)
  end
}

setmetatable(class, meta)

return class
