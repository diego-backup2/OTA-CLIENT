--[[
Config - create, load and save config file (.json / .cfg)
Used by cavebot and other things
]]--

local context = G.botContext
context.Config = {}
local Config = context.Config

Config.exist = function(dir, basePath)
  basePath = basePath or context.configDir
  return g_resources.directoryExists(basePath .. "/" .. dir)
end

Config.create = function(dir, basePath)
  basePath = basePath or context.configDir
  
  local fullPath = basePath .. "/" .. dir
  local parts = string.split(fullPath, "/")
  local current_path = "/"
  if parts[1] ~= "" then
    current_path = ""
  end
  for _, part in ipairs(parts) do
    if part ~= "" then
      current_path = current_path .. part .. "/"
      if not g_resources.directoryExists(current_path) then
        g_resources.makeDir(current_path)
      end
    end
  end

  return Config.exist(dir, basePath)
end

Config.list = function(dir, basePath)
  basePath = basePath or context.configDir
  if not Config.exist(dir, basePath) then
    if not Config.create(dir, basePath) then
      return context.error("Can't create config dir: " .. basePath .. "/" .. dir)
    end
  end
  local list = g_resources.listDirectoryFiles(basePath .. "/" .. dir)
  local correctList = {}
  for k,v in ipairs(list) do -- filter files
    local nv = v:gsub(".json", ""):gsub(".cfg", "") 
    if nv ~= v then
      table.insert(correctList, nv)
    end
  end
  return correctList
end

-- load config from string insteaf of file
Config.parse = function(data)
  local status, result = pcall(function()
    if data:len() < 2 then return {} end
    return json.decode(data)
  end)
  if status and type(result) == 'table' then 
    return result
  end
  local status, result = pcall(function()
    return table.decodeStringPairList(data)
  end)  
  if status and type(result) == 'table' then 
    return result
  end
  return context.error("Invalid config format")
end

Config.load = function(dir, name, basePath)
  basePath = basePath or context.configDir
  local file = basePath .. "/" .. dir .. "/" .. name .. ".json"  
  if g_resources.fileExists(file) then -- load json
      local status, result = pcall(function()
        local data = g_resources.readFileContents(file)
        if data:len() < 2 then return {} end
        return json.decode(data)
      end)
      if not status then
        context.error("Invalid json config (" .. name .. "): " .. result)
        return {}
      end
      return result
  end 
  file = basePath .. "/" .. dir .. "/" .. name .. ".cfg"
  if g_resources.fileExists(file) then -- load cfg
    local status, result = pcall(function()
      return table.decodeStringPairList(g_resources.readFileContents(file))
    end)
    if not status then
      context.error("Invalid cfg config (" .. name .. "): " .. result)
      return {}
    end
    return result
  end   
  return context.error("Config " .. file .. " doesn't exist")
end

Config.loadRaw = function(dir, name, basePath)
  basePath = basePath or context.configDir
  local file = basePath .. "/" .. dir .. "/" .. name .. ".json"
  if g_resources.fileExists(file) then -- load json
    return g_resources.readFileContents(file)
  end 
  file = basePath .. "/" .. dir .. "/" .. name .. ".cfg"
  if g_resources.fileExists(file) then -- load cfg
    return g_resources.readFileContents(file)
  end   
  return context.error("Config " .. file .. " doesn't exist")
end

Config.save = function(dir, name, value, forcedExtension, basePath)
  basePath = basePath or context.configDir
  if not Config.exist(dir, basePath) then
    if not Config.create(dir, basePath) then
      return context.error("Can't create config dir: " .. basePath .. "/" .. dir)
    end
  end
  if type(value) ~= 'table' then
    return context.error("Invalid config value type: " .. type(value) .. ", should be table")  
  end
  local file = basePath .. "/" .. dir .. "/" .. name
  if (table.isStringPairList(value) and forcedExtension ~= "json") or forcedExtension == "cfg" then -- cfg
    g_resources.writeFileContents(file .. ".cfg", table.encodeStringPairList(value))
  else
    g_resources.writeFileContents(file .. ".json", json.encode(value, 2))    
  end
  return true
end

Config.remove = function(dir, name, basePath)
  basePath = basePath or context.configDir
  local file = basePath .. "/" .. dir .. "/" .. name .. ".json"
  local ret = false
  if g_resources.fileExists(file) then
    g_resources.deleteFile(file)    
    ret = true
  end 
  file = basePath .. "/" .. dir .. "/" .. name .. ".cfg"
  if g_resources.fileExists(file) then
    g_resources.deleteFile(file)    
    ret = true
  end     
  return ret
end

-- setup is used for BotConfig widget
-- not done yet
Config.setup = function(dir, widget, configExtension, callback)  
  local basePath = context.configDir

  if type(dir) ~= 'string' or dir:len() == 0 then
    return context.error("Invalid config dir")
  end
  if not Config.exist(dir, basePath) and not Config.create(dir, basePath) then
    return context.error("Can't create config dir: " .. dir)
  end
  if type(context.storage._configs) ~= "table" then
    context.storage._configs = {}
  end
  if type(context.storage._configs[dir]) ~= "table" then
    context.storage._configs[dir] = {
      enabled = false,
      selected = ""
    }
  else
    widget.switch:setOn(context.storage._configs[dir].enabled)
  end
  
  local isRefreshing = false
  local refresh = function()
    isRefreshing = true
    local configs = Config.list(dir, basePath)
    local configIndex = 1
    widget.list:clear()
    for v,k in ipairs(configs) do 
      widget.list:addOption(k)
      if k == context.storage._configs[dir].selected then
        configIndex = v
      end
    end
    local data = nil
    if #configs > 0 then
      widget.list:setCurrentIndex(configIndex)
      context.storage._configs[dir].selected = widget.list:getCurrentOption().text
      data = Config.load(dir, configs[configIndex], basePath)
    else
      context.storage._configs[dir].selected = nil
    end
    context.storage._configs[dir].enabled = widget.switch:isOn()
    isRefreshing = false    
    callback(context.storage._configs[dir].selected, widget.switch:isOn(), data)
  end
  
  widget.list.onOptionChange = function(widget)
    if not isRefreshing then
      context.storage._configs[dir].selected = widget:getCurrentOption().text
      refresh()
    end
  end
  
  widget.switch.onClick = function()
    widget.switch:setOn(not widget.switch:isOn())
    refresh()
  end
  
  widget.add.onClick = function()
    context.UI.SinglelineEditorWindow("config_name", {title="Enter config name"}, function(name)
      name = name:gsub("%s+", "_")
      if name:len() == 0 or name:len() >= 30 or name:find("/") or name:find("\\") then
        return context.error("Invalid config name")
      end
      local file = basePath .. "/" .. dir .. "/" .. name .. "." .. configExtension
      if g_resources.fileExists(file) then
        return context.error("Config " .. name .. " already exist")
      end
      if configExtension == "json" then
        g_resources.writeFileContents(file, json.encode({}))
      else
        g_resources.writeFileContents(file, "")      
      end
      context.storage._configs[dir].selected = name
      widget.switch:setOn(false)
      refresh()
    end)
  end
  
  widget.edit.onClick = function()
    local name = context.storage._configs[dir].selected
    if not name then return end
    context.UI.MultilineEditorWindow(Config.loadRaw(dir, name, basePath), {title="Config editor - " .. name .. " in " .. dir}, function(newValue)
        local data = Config.parse(newValue)
        Config.save(dir, name, data, configExtension, basePath)
        refresh()
      end)
  end
  
  widget.remove.onClick = function()
    local name = context.storage._configs[dir].selected
    if not name then return end
    context.UI.ConfirmationWindow("Config removal", "Do you want to remove config " .. name .. " from " .. dir .. "?", function()
      Config.remove(dir, name, basePath)
      widget.switch:setOn(false)
      refresh()
    end)
  end
  
  refresh()

  return {
    isOn = function()
      return widget.switch:isOn()
    end,
    isOff = function()
      return not widget.switch:isOn()    
    end,
    setOn = function(val)
      if val == false then
        if widget.switch:isOn() then
          widget.switch:onClick()
        end
        return
      end
      if not widget.switch:isOn() then
        widget.switch:onClick()
      end
    end,
    setOff = function(val)
      if val == false then
        if not widget.switch:isOn() then
          widget.switch:onClick()
        end
        return
      end
      if widget.switch:isOn() then
        widget.switch:onClick()
      end
    end,
    save = function(data)
      Config.save(dir, context.storage._configs[dir].selected, data, configExtension, basePath)
    end,
    refresh = refresh,
    reload = refresh,
    getActiveConfigName = function()
      return context.storage._configs[dir].selected      
    end    
  }
end