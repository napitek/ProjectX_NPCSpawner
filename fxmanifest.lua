-- Resource Metadata
fx_version 'cerulean'
games { 'gta5' }

author 'napitek'
description 'Projectx_NPCSpawner'
version '0.0.4'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/data.json'
}

shared_script 'config.lua'

client_script {
    '@NativeUI/NativeUI.lua',
    'client/client.lua'
}

server_scripts {
    "server/server.lua",
    "@mysql-async/lib/MySQL.lua"
}