local QBCore = exports['qb-core']:GetCoreObject()
local mailBot = nil
local lastNotificationTime = 0
local mailBlip = nil 

local function isMailServiceAvailable()
    if not Config.TimeRestriction.enabled then return true end
    local hour = GetClockHours()
    if hour >= Config.TimeRestriction.closeTime or hour < Config.TimeRestriction.openTime then
        local currentTime = GetGameTimer()
        if (currentTime - lastNotificationTime) > 60000 then 
            if Config.Notify == "qb" then
                QBCore.Functions.Notify('Mail service is closed (11 PM - 6 AM)', 'error')
            elseif Config.Notify == "ox" then
                lib.notify({
                    type = 'error',
                    description = 'Mail service is closed (11 PM - 6 AM)'
                })
            end
            lastNotificationTime = currentTime
        end
        return false
    end
    return true
end

local function UpdateBlipStatus()
    local hour = GetClockHours()
    local isOpen = not (hour >= Config.TimeRestriction.closeTime or hour < Config.TimeRestriction.openTime)
    
    BeginTextCommandSetBlipName("STRING")
    if isOpen then
        AddTextComponentString(Config.Blip.label .. " [Open]")
    else
        AddTextComponentString(Config.Blip.label .. " [Closed]")
    end
    EndTextCommandSetBlipName(mailBlip)
end

CreateThread(function()
    local model = Config.Ped.model
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(0)
    end
    
    mailBot = CreatePed(4, model, Config.BotLocation.x, Config.BotLocation.y, Config.BotLocation.z, false, true)
    SetEntityHeading(mailBot, Config.BotLocation.w)
    FreezeEntityPosition(mailBot, true)
    SetEntityInvincible(mailBot, true)
    SetBlockingOfNonTemporaryEvents(mailBot, true)
    
    if Config.Ped.scenario then
        TaskStartScenarioInPlace(mailBot, Config.Ped.scenario, 0, true)
    elseif Config.Ped.animation then
        RequestAnimDict(Config.Ped.animation.dict)
        while not HasAnimDictLoaded(Config.Ped.animation.dict) do
            Wait(0)
        end
        TaskPlayAnim(mailBot, Config.Ped.animation.dict, Config.Ped.animation.name, 8.0, 1.0, -1, Config.Ped.animation.flag, 0, false, false, false)
    end
    
    -- Add props if configured
    if Config.Ped.props then
        for _, prop in ipairs(Config.Ped.props) do
            local coords = GetEntityCoords(mailBot)
            local propObj = CreateObject(prop.model, coords.x, coords.y, coords.z, true, true, true)
            AttachEntityToEntity(propObj, mailBot, GetPedBoneIndex(mailBot, prop.bone), 
                prop.coords.x, prop.coords.y, prop.coords.z,
                prop.rotation.x, prop.rotation.y, prop.rotation.z,
                true, true, false, true, 1, true)
        end
    end
    
    mailBlip = AddBlipForCoord(Config.BotLocation.x, Config.BotLocation.y, Config.BotLocation.z)
    SetBlipSprite(mailBlip, Config.Blip.sprite)
    SetBlipColour(mailBlip, Config.Blip.color)
    SetBlipScale(mailBlip, Config.Blip.scale)
    SetBlipAsShortRange(mailBlip, true)
    
    UpdateBlipStatus()
    
    CreateThread(function()
        while true do
            Wait(1000) 
            local gameHour = GetClockHours()
            local gameMinute = GetClockMinutes()
            
            if gameMinute == 0 or gameMinute == 30 then 
                UpdateBlipStatus()
            end
            
            if gameHour == Config.TimeRestriction.openTime or gameHour == Config.TimeRestriction.closeTime then
                UpdateBlipStatus()
            end
        end
    end)

    if DoesEntityExist(mailBot) then
        if Config.target == "qb" then
            exports['qb-target']:AddTargetEntity(mailBot, {
                options = {
                    {
                        type = "client",
                        event = "qb-MailOrder:client:showMailID",
                        icon = "fas fa-id-card",
                        label = "Show My Mail ID",
                        canInteract = function()
                            return isMailServiceAvailable()
                        end
                    },
                    {
                        type = "client",
                        event = "qb-MailOrder:client:openMailMenu",
                        icon = "fas fa-envelope",
                        label = "Access Mailbox",
                        canInteract = function()
                            return isMailServiceAvailable()
                        end
                    }
                },
                distance = 2.5
            })
        elseif Config.target == "ox" then
            exports.ox_target:addLocalEntity(mailBot, {
                {
                    name = 'show_mail_id',
                    icon = "fas fa-id-card",
                    label = "Show My Mail ID",
                    onSelect = function()
                        if isMailServiceAvailable() then
                            TriggerEvent('qb-MailOrder:client:showMailID')
                        end
                    end
                },
                {
                    name = 'access_mailbox',
                    icon = "fas fa-envelope",
                    label = "Access Mailbox",
                    onSelect = function()
                        if isMailServiceAvailable() then
                            TriggerEvent('qb-MailOrder:client:openMailMenu')
                        end
                    end
                }
            })
        end
    end
end)

RegisterNetEvent('qb-MailOrder:client:showMailID')
AddEventHandler('qb-MailOrder:client:showMailID', function()
    QBCore.Functions.TriggerCallback('qb-MailOrder:server:getMailID', function(mailid)
        if Config.Notify == "qb" then
            QBCore.Functions.Notify('Your Mail ID: ' .. mailid, 'primary', 5000)
        elseif Config.Notify == "ox" then
            lib.notify({
                title = 'Mail System',
                description = 'Your Mail ID: ' .. mailid,
                type = 'info',
                duration = 5000
            })
        end
    end)
end)

RegisterNetEvent('qb-MailOrder:client:openMailMenu')
AddEventHandler('qb-MailOrder:client:openMailMenu', function()
    if Config.input == "qb" then
        local dialog = exports['qb-input']:ShowInput({
            header = "Mail System",
            submitText = "Access",
            inputs = {
                {
                    text = "Enter Mail ID",
                    name = "mailid",
                    type = "text",
                    isRequired = true
                },
            },
        })
        if dialog then
            TriggerServerEvent('qb-MailOrder:server:checkAnyMailbox', dialog.mailid)
        end
    elseif Config.input == "ox" then
        local input = lib.inputDialog('Mail System', {
            {
                type = 'input',
                label = 'Enter Mail ID',
                required = true
            }
        })
        if input then
            TriggerServerEvent('qb-MailOrder:server:checkAnyMailbox', input[1])
        end
    end
end)

RegisterNetEvent('qb-MailOrder:client:openStash')
AddEventHandler('qb-MailOrder:client:openStash', function(mailid)
    if Config.inventory == "ox" then
        exports.ox_inventory:openInventory('stash', 'mailbox_'..mailid)
    elseif Config.inventory == "qb" then
        TriggerServerEvent("inventory:server:OpenInventory", "stash", "mailbox_"..mailid, {
            maxweight = Config.Storage.weight,
            slots = Config.Storage.slots,
        })
        TriggerEvent("inventory:client:SetCurrentStash", "mailbox_"..mailid)
    end
end)
