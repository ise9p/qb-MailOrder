local QBCore = exports['qb-core']:GetCoreObject()
local mailBot = nil


CreateThread(function()
    local model = `a_m_m_hillbilly_01`
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(0)
    end
    
    mailBot = CreatePed(4, model, Config.BotLocation.x, Config.BotLocation.y, Config.BotLocation.z, false, true)
    SetEntityHeading(mailBot, Config.BotLocation.w)
    FreezeEntityPosition(mailBot, true)
    SetEntityInvincible(mailBot, true)
    SetBlockingOfNonTemporaryEvents(mailBot, true)
    
    local blip = AddBlipForCoord(Config.BotLocation.x, Config.BotLocation.y, Config.BotLocation.z)
    SetBlipSprite(blip, Config.Blip.sprite)
    SetBlipColour(blip, Config.Blip.color)
    SetBlipScale(blip, Config.Blip.scale)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.Blip.label)
    EndTextCommandSetBlipName(blip)


    if DoesEntityExist(mailBot) then
        if Config.target == "qb" then
            exports['qb-target']:AddTargetEntity(mailBot, {
                options = {
                    {
                        type = "client",
                        event = "qb-MailOrder:client:showMailID",
                        icon = "fas fa-id-card",
                        label = "Show My Mail ID",
                    },
                    {
                        type = "client",
                        event = "qb-MailOrder:client:openMailMenu",
                        icon = "fas fa-envelope",
                        label = "Access Mailbox",
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
                        TriggerEvent('qb-MailOrder:client:showMailID')
                    end
                },
                {
                    name = 'access_mailbox',
                    icon = "fas fa-envelope",
                    label = "Access Mailbox",
                    onSelect = function()
                        TriggerEvent('qb-MailOrder:client:openMailMenu')
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
