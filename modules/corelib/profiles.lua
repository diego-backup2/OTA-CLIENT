Profiles = {
    settings = {}
}

-- local variables and functions

-- collection of refresh functions from different modules
local function collectiveReload()
    modules.game_topbar.refresh(true)
    modules.game_actionbar.refresh(true)
    modules.game_bot.refresh()
end

-- profile functions

function Profiles.init()
    connect(g_game, { onGameStart = Profiles.online, onGameEnd = Profiles.offline })

    -- create main settings dir
    if not g_resources.directoryExists("/profiles/") then
        g_resources.makeDir("/profiles/")
    end
end

function Profiles.terminate()
    disconnect(g_game, { onGameStart = Profiles.online, onGameEnd = Profiles.offline })
end

-- loads settings on character login
function Profiles.online()
    
    -- create profiles dirs
    local path = "/profiles/" .. Profiles.getFolderName()
    if not g_resources.directoryExists(path) then
        g_resources.makeDir(path)
    end

    Profiles.load()
end

-- unloads settings on character logout
function Profiles.offline()
    Profiles.onChange(true)
end

-- json handlers

function Profiles.load()
    local file = Profiles.getFilePath("data.json")
    if g_resources.fileExists(file) then
        local status, result = pcall(function()
            return json.decode(g_resources.readFileContents(file))
        end)
        if not status then
            return onError(
                "Error while reading profiles file. To fix this problem you can delete the settings folder of your character. Details: " ..
                result)
        end
        Profiles.settings = result
    end
end

function Profiles.save()
    local file = Profiles.getFilePath("data.json")
    local status, result = pcall(function() return json.encode(Profiles.settings, 2) end)
    if not status then
        return onError(
            "Error while saving profile settings. Data won't be saved. Details: " ..
            result)
    end
    if result:len() > 100 * 1024 * 1024 then
        return onError(
            "Something went wrong, file is above 100MB, won't be saved")
    end
    g_resources.writeFileContents(file, result)
end

-- profile change callback (called in options), saves settings & reloads given module configs
function Profiles.onChange(offline)
    if not offline then
        if not g_game.isOnline() then return end
        -- had to apply some delay
        scheduleEvent(collectiveReload, 100)
    end

    local currentProfile = Profiles.getFolderName()
    local index = g_game.getCharacterName()

    if index then
        Profiles.settings[index] = currentProfile
        Profiles.save()
    end
end

function Profiles.getFolderName()
    local name = g_game.getCharacterName()
    -- Remove caracteres inválidos para nomes de arquivos no Windows
    name = name:gsub("[<>:\"/\\|?*]", "") -- Remove caracteres especiais
    name = name:gsub("%s+", "_")          -- Substitui espaços por underscores
    return name
end

function Profiles.getFilePath(filename)
    return "/profiles/" .. Profiles.getFolderName() .. "/" .. filename
end
