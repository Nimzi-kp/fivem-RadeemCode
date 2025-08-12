local ESX = exports['es_extended']:getSharedObject()
local isUIOpen = false

-- Open admin UI
RegisterNetEvent('kp-radeem:client:openAdminUI')
AddEventHandler('kp-radeem:client:openAdminUI', function()
    if isUIOpen then return end
    
    -- Request active codes from server
    TriggerServerEvent('kp-radeem:server:getActiveCodes')
    
    -- Open UI
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openAdminUI'
    })
    
    isUIOpen = true
end)

-- Receive active codes from server
RegisterNetEvent('kp-radeem:client:receiveActiveCodes')
AddEventHandler('kp-radeem:client:receiveActiveCodes', function(codes)
    SendNUIMessage({
        action = 'updateCodes',
        codes = codes
    })
end)

-- Code created notification
RegisterNetEvent('kp-radeem:client:codeCreated')
AddEventHandler('kp-radeem:client:codeCreated', function(code)
    SendNUIMessage({
        action = 'codeCreated',
        code = code
    })
end)

-- Code deleted notification
RegisterNetEvent('kp-radeem:client:codeDeleted')
AddEventHandler('kp-radeem:client:codeDeleted', function(code)
    SendNUIMessage({
        action = 'codeDeleted',
        code = code
    })
    
    -- Refresh codes list
    TriggerServerEvent('kp-radeem:server:getActiveCodes')
end)

-- NUI Callbacks

-- Close UI
RegisterNUICallback('closeUI', function(data, cb)
    SetNuiFocus(false, false)
    isUIOpen = false
    cb('ok')
end)

-- Create code
RegisterNUICallback('createCode', function(data, cb)
    TriggerServerEvent('kp-radeem:server:createCode', data)
    cb('ok')
end)

-- Delete code
RegisterNUICallback('deleteCode', function(data, cb)
    TriggerServerEvent('kp-radeem:server:deleteCode', data.code, data.reason)
    cb('ok')
end)

-- Get vehicle models for dropdown
RegisterNUICallback('getVehicleModels', function(data, cb)
    local vehicles = Config.vehicles
    
    cb(vehicles)
end)

-- Get item list for dropdown
RegisterNUICallback('getItemList', function(data, cb)
    local items = Config.items
    
    cb(items)
end)

-- Command suggestion for redeem command
CreateThread(function()
    TriggerEvent('chat:addSuggestion', '/' .. Config.Commands.User, 'Redeem a code', {
        { name = "code", help = "The redemption code" }
    })
    
    TriggerEvent('chat:addSuggestion', '/' .. Config.Commands.Admin, 'Open redemption code management')
end)

-- Fallback client-side commands to ensure recognition in chat
RegisterCommand(Config.Commands.Admin, function()
    TriggerServerEvent('kp-radeem:server:requestOpenAdminUI')
end, false)

RegisterCommand(Config.Commands.User, function(_, args)
    if not args or not args[1] or args[1] == '' then return end
    TriggerServerEvent('kp-radeem:server:redeemCode', args[1])
end, false)