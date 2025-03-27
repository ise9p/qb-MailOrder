local QBCore = exports['qb-core']:GetCoreObject()
local Mailboxes = {}


RegisterNetEvent('QBCore:Server:OnPlayerLoaded')
AddEventHandler('QBCore:Server:OnPlayerLoaded', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local mailid = Player.PlayerData.metadata["mailid"]
    if not Mailboxes[mailid] then
        Mailboxes[mailid] = {}
    end
end)

QBCore.Functions.CreateCallback('qb-MailOrder:server:getMailID', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    local mailid = Player.PlayerData.metadata["mailid"]
    cb(mailid)
end)



RegisterNetEvent('qb-MailOrder:server:checkAnyMailbox')
AddEventHandler('qb-MailOrder:server:checkAnyMailbox', function(mailid)
    local src = source
    if Config.inventory == "ox" then
        exports.ox_inventory:RegisterStash("mailbox_"..mailid, "Mail Box #"..mailid, Config.Storage.slots, Config.Storage.weight)
    elseif Config.inventory == "qb" then
        -- QB Inventory doesn't need stash registration
    end
    TriggerClientEvent('qb-MailOrder:client:openStash', src, mailid)
end)

RegisterNetEvent('qb-MailOrder:server:checkMailbox')
AddEventHandler('qb-MailOrder:server:checkMailbox', function(mailid)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.metadata["mailid"] == mailid then
    else
        if Config.Notify == "qb" then
            TriggerClientEvent('QBCore:Notify', src, "Invalid Mail ID!", "error")
        elseif Config.Notify == "ox" then
            TriggerClientEvent('ox_lib:notify', src, {
                type = 'error',
                description = 'Invalid Mail ID!'
            })
        end
    end
end)
