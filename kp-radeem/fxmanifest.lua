fx_version 'cerulean'
lua54 'yes'
game 'gta5'

author 'KP'
description 'KP-Radeem - Redemption Code System'
version '1.0.0'

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    'config.lua',
    'locales/init.lua',
    'locales/*.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/database.lua',
    'server/main.lua'
}

ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/assets/css/style.css',
    'ui/assets/js/app.js',
    'ui/assets/img/*.png',
    'ui/assets/img/*.jpg',
    'ui/assets/img/*.svg'
}

dependencies {
    'es_extended',
    'ox_lib',
    'oxmysql',
    'ox_inventory'
}