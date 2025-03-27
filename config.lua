Config = {}

Config.inventory = "ox" -- "qb" for qb-inventory or "ox" for ox_inventory
Config.input = "ox"     -- "qb" for qb-input or "ox" for ox_lib input
Config.target = "qb"    -- "qb" for qb-target or "ox" for ox_target
Config.Notify = "ox"    -- "qb" for QBCore.Functions.Notify or "ox" for lib.notify

Config.BotLocation = vector4(-232.09, -915.49, 31.31, 337.52)

Config.Blip = {
    sprite = 478, 
    color = 16,    
    scale = 0.6,
    label = "Mail Service"
}

Config.Storage = {
    slots = 5,    
    weight = 50000 
}

Config.TimeRestriction = {
    enabled = true,
    closeTime = 23, -- 11 PM
    openTime = 6    -- 6 AM
}

Config.Ped = {
    model = `a_m_y_bevhills_01`,
    animation = {
        dict = "missfam4",
        name = "base",
        flag = 49
    },
    scenario = nil, -- if you want scenario instead of animation
    props = {
        {
            model = `p_amb_clipboard_01`,
            bone = 36029,
            coords = vec3(0.16, 0.08, 0.1),
            rotation = vec3(-130.0, -50.0, 0.0)
        }
    }
}

Config.Webhooks = {
    enabled = true,
    url = "", -- Your Discord webhook URL
    color = 3447003, -- Blue color
    footer = "Mail System Logs",
    title = "Mail System"
}
