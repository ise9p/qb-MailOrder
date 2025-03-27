# QB Mail Order System

A mail system for FiveM servers with flexible framework support for both QB and OX resources.

## Features
- Unique mail ID for each player
- Secure mailbox storage system
- Support for both QB and OX frameworks
- Configurable storage capacity
- Easy to use interface

## Dependencies
- QBCore
- One of the following combinations:
  - qb-target, qb-input, qb-inventory
  - ox_target, ox_lib, ox_inventory

## Installation
1. Place the resource in your server's resources folder
2. Add `ensure qb-MailOrder` to your server.cfg
3. Configure the config.lua to match your preferred framework

## Configuration
```lua
Config.inventory = "ox/qb"  -- Choose inventory system
Config.input = "ox/qb"      -- Choose input dialog system
Config.target = "ox/qb"     -- Choose target system
Config.Notify = "ox/qb"     -- Choose notification system

Config.Storage = {
    slots = 5,      -- Number of inventory slots
    weight = 50000  -- Maximum weight capacity
}
```

## Installation Instructions:
1. Configuring Player Metadata:
Open the qb-core/config.lua file and add the following under the metadata section:

```lua
metadata = {
    mailid = function() return GenerateMailID() end,
}
```

2. Configuring Player function:
Open the qb-core/server/player.lua file and add the following under the function section:

```lua
function GenerateMailID()
    return tostring(math.random(100000, 999999))
end
```

## Usage
1. Players receive a unique mail ID on first join
2. Access the mail system through the NPC
3. View your mail ID or access mailboxes
4. Use any valid mail ID to access corresponding mailbox

## Support
- Framework: QBCore
- Optional: OX Suite Support
