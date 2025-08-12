local ESX = exports['es_extended']:getSharedObject()

-- Optimized helper functions
local function IsAdmin(xPlayer)
    return xPlayer and Config.AdminGroups[xPlayer.getGroup()]
end

local function NotifyPlayer(source, type, description)
    TriggerClientEvent('ox_lib:notify', source, {
        title = _U('script_name'),
        description = description,
        type = type
    })
end

local function GenerateRedeemCode()
    local code = Config.CodePrefix
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local length = Config.CodeLength - #Config.CodePrefix
    
    for i = 1, length do
        local rand = math.random(1, #chars)
        code = code .. string.sub(chars, rand, rand)
    end
    
    -- Debug: Verify code length
    if Config.Debug then
        print(('^3[kp-radeem]^7 Generated code: %s (Length: %d, Expected: %d)'):format(code, #code, Config.CodeLength))
    end
    
    return GetRedeemCode(code) and GenerateRedeemCode() or code
end

local function SendWebhook(webhookType, message, color)
    local webhook = Config.Webhooks[webhookType]
    if webhook and webhook ~= "" then
        local embeds = {
            {
                ["title"] = "KP-Radeem: " .. webhookType,
                ["description"] = message,
                ["type"] = "rich",
                ["color"] = color or 7506394,
                ["footer"] = {
                    ["text"] = "KP-Radeem | " .. os.date("%Y-%m-%d %H:%M:%S")
                }
            }
        }
        
        PerformHttpRequest(webhook, function() end, 'POST', json.encode({embeds = embeds}), { ['Content-Type'] = 'application/json' })
    end
end

local function FormatRewardsForWebhook(rewards)
    local formattedRewards = ""
    
    for _, reward in ipairs(rewards) do
        if reward.type == "money" then
            formattedRewards = formattedRewards .. "• Money: " .. (reward.amount or 0) .. " (" .. (reward.subtype or "money") .. ")\n"
        elseif reward.type == "item" then
            formattedRewards = formattedRewards .. "• Item: " .. (reward.label or reward.name or "item") .. " x" .. (reward.amount or 0) .. "\n"
        elseif reward.type == "vehicle" then
            local plateInfo = reward.plate and reward.plate ~= "" and " (Plate: " .. reward.plate .. ")" or ""
            formattedRewards = formattedRewards .. "• Vehicle: " .. (reward.name or reward.model or "vehicle") .. plateInfo .. "\n"
        end
    end
    
    return formattedRewards
end

-- Optimized event handlers
RegisterNetEvent('kp-radeem:server:createCode')
AddEventHandler('kp-radeem:server:createCode', function(data)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not IsAdmin(xPlayer) then
        NotifyPlayer(source, 'error', _U('admin_only'))
        return
    end
    
    local code = GenerateRedeemCode()
    local codeId = CreateRedeemCode(code, xPlayer.getName(), data.description, data.usageLimit)
    
    if not codeId then
        NotifyPlayer(source, 'error', _U('error_creating_code'))
        return
    end
    
    -- Add rewards efficiently
    for _, reward in ipairs(data.rewards) do
        local rewardType = reward.type
        if rewardType == "money" then
            AddReward(codeId, "money", reward.subtype, reward.subtype, reward.amount, nil)
        elseif rewardType == "item" then
            AddReward(codeId, "item", nil, reward.name, reward.amount, nil)
        elseif rewardType == "vehicle" then
            AddReward(codeId, "vehicle", nil, reward.model, nil, reward.plate)
        end
    end
    
    NotifyPlayer(source, 'success', _U('code_created', code))
    
    -- Optimized logging
    local logMessage = ("**Admin:** %s (%s)\n**Code:** %s\n**Description:** %s\n**Usage Limit:** %s\n**Rewards:**\n%s"):format(
        xPlayer.getName(), xPlayer.identifier, code, data.description, data.usageLimit, FormatRewardsForWebhook(data.rewards)
    )
    
    SendWebhook("Created", logMessage, 3066993)
    TriggerClientEvent('kp-radeem:client:codeCreated', source, code)
end)

RegisterNetEvent('kp-radeem:server:getActiveCodes')
AddEventHandler('kp-radeem:server:getActiveCodes', function()
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not IsAdmin(xPlayer) then
        NotifyPlayer(source, 'error', _U('admin_only'))
        return
    end
    
    local codes = GetAllActiveCodes()
    local formattedCodes = {}
    
    for _, code in ipairs(codes) do
        table.insert(formattedCodes, {
            id = code.id,
            code = code.code,
            creator = code.creator,
            description = code.description,
            usageLimit = code.usage_limit,
            usageCount = code.usage_count,
            createdAt = code.created_at,
            rewards = GetCodeRewards(code.id)
        })
    end
    
    TriggerClientEvent('kp-radeem:client:receiveActiveCodes', source, formattedCodes)
end)

RegisterNetEvent('kp-radeem:server:deleteCode')
AddEventHandler('kp-radeem:server:deleteCode', function(code, reason)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not IsAdmin(xPlayer) then
        NotifyPlayer(source, 'error', _U('admin_only'))
        return
    end
    
    local codeData = GetRedeemCode(code)
    if not codeData then
        NotifyPlayer(source, 'error', _U('error_deleting_code'))
        return
    end
    
    local rewards = GetCodeRewards(codeData.id)
    DeleteRedeemCode(code, xPlayer.getName(), reason)
    
    NotifyPlayer(source, 'success', _U('code_deleted', code))
    
    -- Optimized logging
    local logMessage = ("**Admin:** %s (%s)\n**Code:** %s\n**Creator:** %s\n**Original Description:** %s\n**Delete Reason:** %s\n**Created At:** %s\n**Usage:** %s/%s\n**Rewards:**\n%s"):format(
        xPlayer.getName(), xPlayer.identifier, code, codeData.creator, codeData.description, reason, 
        codeData.created_at, codeData.usage_count, codeData.usage_limit, FormatRewardsForWebhook(rewards)
    )
    
    SendWebhook("Deleted", logMessage, 15158332)
    
    -- Update all admin clients efficiently
    for _, playerId in ipairs(ESX.GetPlayers()) do
        local xTarget = ESX.GetPlayerFromId(playerId)
        if IsAdmin(xTarget) then
            TriggerClientEvent('kp-radeem:client:codeDeleted', playerId, code)
        end
    end
end)

RegisterNetEvent('kp-radeem:server:redeemCode')
AddEventHandler('kp-radeem:server:redeemCode', function(code)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    local codeData = GetRedeemCode(code)
    if not codeData then
        NotifyPlayer(source, 'error', _U('invalid_code'))
        return
    end
    
    if codeData.usage_count >= codeData.usage_limit then
        NotifyPlayer(source, 'error', _U('code_limit_reached'))
        return
    end
    
    if HasUserRedeemedCode(xPlayer.identifier, codeData.id) then
        NotifyPlayer(source, 'error', _U('code_already_used'))
        return
    end
    
    local rewards = GetCodeRewards(codeData.id)
    if #rewards == 0 then
        NotifyPlayer(source, 'error', _U('error_redeeming_code'))
        return
    end
    
    -- Process rewards efficiently
    for _, reward in ipairs(rewards) do
        local rewardType = reward.type
        if rewardType == "money" then
            local moneyType = reward.subtype or "cash"
            local amount = reward.amount or 0
            
            if moneyType == "cash" then
                xPlayer.addMoney(amount)
            elseif moneyType == "bank" then
                xPlayer.addAccountMoney('bank', amount)
            elseif moneyType == "black_money" then
                xPlayer.addAccountMoney('black_money', amount)
            end
            
            NotifyPlayer(source, 'success', _U('received_money', amount, _U(moneyType)))
        elseif rewardType == "item" then
            exports.ox_inventory:AddItem(source, reward.name, reward.amount)
            NotifyPlayer(source, 'success', _U('received_item', reward.amount, reward.name))
        elseif rewardType == "vehicle" then
            local plate = reward.plate or GenerateRandomPlate()
            local modelName = reward.name or reward.model
            local ownerIdentifier = (xPlayer.getIdentifier and xPlayer:getIdentifier()) or xPlayer.identifier
            
            if SaveVehicleToESXGarage(ownerIdentifier, modelName, plate) then
                NotifyPlayer(source, 'success', _U('received_vehicle', modelName))
            else
                NotifyPlayer(source, 'error', 'Failed to save vehicle to garage. Contact an admin.')
            end
        end
    end
    
    RecordRedemption(xPlayer.identifier, codeData.id)
    NotifyPlayer(source, 'success', _U('code_redeemed'))
    
    -- Optimized logging
    local logMessage = ("**User:** %s (%s)\n**Code:** %s\n**Creator:** %s\n**Description:** %s\n**Usage:** %s/%s\n**Rewards:**\n%s"):format(
        xPlayer.getName(), xPlayer.identifier, code, codeData.creator, codeData.description,
        codeData.usage_count + 1, codeData.usage_limit, FormatRewardsForWebhook(rewards)
    )
    
    SendWebhook("Claimed", logMessage, 3447003)
end)

-- Optimized utility functions
function GenerateRandomPlate()
    local desiredLength = Config.numberLenth
    local letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    local prefix = (Config.CodePrefix or ""):upper()
    
    if #prefix > desiredLength then
        prefix = prefix:sub(1, desiredLength)
    end
    
    local plate = prefix
    for i = #plate + 1, desiredLength do
        local rand = math.random(1, #letters)
        plate = plate .. letters:sub(rand, rand)
    end
    
    -- Debug: Verify plate length
    if Config.Debug then
        print(('^3[kp-radeem]^7 Generated plate: %s (Length: %d, Expected: %d)'):format(plate, #plate, desiredLength))
    end
    
    return plate
end

function SaveVehicleToESXGarage(ownerIdentifier, modelName, plate)
    if not ownerIdentifier or not modelName or ownerIdentifier == '' or modelName == '' then 
        return false 
    end

    local function toModelHash(name)
        local hash = GetHashKey(name)
        return type(hash) == 'number' and hash or 0
    end

    local normalizedPlate = (plate or ''):upper()
    if normalizedPlate == '' then
        normalizedPlate = GenerateRandomPlate()
    end

    -- Ensure unique plate efficiently
    local exists = MySQL.query.await('SELECT plate FROM owned_vehicles WHERE plate = ? LIMIT 1', { normalizedPlate })
    while exists and #exists > 0 do
        normalizedPlate = GenerateRandomPlate()
        exists = MySQL.query.await('SELECT plate FROM owned_vehicles WHERE plate = ? LIMIT 1', { normalizedPlate })
    end

    local vehicleProps = {
        model = toModelHash(modelName),
        plate = normalizedPlate,
        color1 = 27, color2 = 27, pearlescentColor = 27,
        fuelLevel = 100.0, engineHealth = 1000.0, bodyHealth = 1000.0,
        windowsBroken = {}, doorsBroken = {}
    }

    local ok, err = pcall(function()
        MySQL.insert.await('INSERT INTO owned_vehicles (owner, plate, vehicle, type, stored, in_garage, garage_id, garage_type) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
            { ownerIdentifier, normalizedPlate, json.encode(vehicleProps), 'car', 0, 1, Config.DefaultGarage or 'Main Garage', 'car' })
    end)

    if not ok then
        print(('^3[kp-radeem]^7 failed to insert owned vehicle: %s'):format(err or 'unknown'))
    end

    return ok
end

-- Optimized commands
RegisterCommand(Config.Commands.User, function(source, args)
    if #args < 1 then
        NotifyPlayer(source, 'error', 'Usage: /' .. Config.Commands.User .. ' [code]')
        return
    end
    
    TriggerEvent('kp-radeem:server:redeemCode', args[1])
end, false)

RegisterCommand(Config.Commands.Admin, function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not IsAdmin(xPlayer) then
        NotifyPlayer(source, 'error', _U('admin_only'))
        return
    end
    
    TriggerClientEvent('kp-radeem:client:openAdminUI', source)
end, false)

RegisterNetEvent('kp-radeem:server:requestOpenAdminUI')
AddEventHandler('kp-radeem:server:requestOpenAdminUI', function()
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not xPlayer or not IsAdmin(xPlayer) then
        NotifyPlayer(source, 'error', _U('admin_only'))
        return
    end
    
    TriggerClientEvent('kp-radeem:client:openAdminUI', source)
end)

-- Initialize random seed
math.randomseed(os.time())