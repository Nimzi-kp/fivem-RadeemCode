Config = {}

Config.Locale = 'en'
Config.Debug = true

-- Redemption Code Settings
Config.CodePrefix = "KP" -- Prefix for all redemption codes
Config.CodeLength = 10   -- Total length of redemption codes (including prefix)
Config.numberLenth = 6 -- numberplate length


-- Default garage id/name when saving to owned_vehicles (for ESX-based garages)
Config.DefaultGarage = 'Main Garage'

-- Webhook Settings for Logging
Config.Webhooks = {
    Created = "https://discord.com/api/webhooks/1035556595083509851/6PLqdI8HBuB-FRI-l3s19x6LgyhPM-O5apbag9MtASh6H4Io09xpCuVpE9sxDvuZMQnr",  -- Webhook for code creation logs
    Claimed = "https://discord.com/api/webhooks/1403994670744207443/yCtrO9sBpGjAUjSNO9aRx72QVb57BduzWsyXXDhWk6CyKJ7og1SiIMYj30bKSCAeK-jb",  -- Webhook for code redemption logs
    Deleted = "https://discord.com/api/webhooks/1403994753112211476/Cf71hYAHopnAP9FhwNUOBI8fTJLiWCJNag2GwdldsoPrIYZVbMvawoESyCnr-VH-Bzjr"   -- Webhook for code deletion logs
}

-- Permission Settings
Config.AdminGroups = {
    ["admin"] = true,
    ["superadmin"] = true,
    ["mod"] = true
}

-- Command Settings
Config.Commands = {
    Admin = "createradeem",  -- Command for admins to open the creation UI
    User = "redeem"          -- Command for users to redeem codes
}


Config.vehicles = {
    { model = "adder", label = "Adder" },
    { model = "zentorno", label = "Zentorno" },
    { model = "t20", label = "T20" },
    { model = "kuruma", label = "Kuruma" },
    { model = "bati", label = "Bati 801" },
    { model = "sanchez", label = "Sanchez" },
    { model = "faggio", label = "Faggio" },
    { model = "sultan", label = "Sultan" },
    { model = "sultanrs", label = "Sultan RS" },
    { model = "buffalo", label = "Buffalo" },
    { model = "buffalo2", label = "Buffalo S" },
    { model = "comet", label = "Comet" },
    { model = "elegy", label = "Elegy" },
    { model = "elegy2", label = "Elegy Retro Custom" }
}

Config.items = {
    { name = "bread", label = "Bread" },
    { name = "water", label = "Water" },
    { name = "phone", label = "Phone" },
    { name = "lockpick", label = "Lockpick" },
    { name = "bandage", label = "Bandage" },
    { name = "medikit", label = "Medikit" },
    { name = "weapon_pistol", label = "Pistol" },
    { name = "weapon_smg", label = "SMG" },
    { name = "ammo-9", label = "9mm Ammo" },
    { name = "radio", label = "Radio" },
    { name = "binoculars", label = "Binoculars" },
    { name = "armor", label = "Body Armor" }
}