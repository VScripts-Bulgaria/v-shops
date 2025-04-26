fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'V-Shops'
description 'Shops system with multiple payment methods and inventory support'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    '@qb-core/shared/locale.lua',
    'locale/bg.lua',
    'locale/*.lua',
    'items.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua',
}

server_script 'server/main.lua'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/img/*.png'
}

ui_page 'html/index.html'

dependencies {
    'qb-core',
    'ox_lib',
    'qb-target'
} 