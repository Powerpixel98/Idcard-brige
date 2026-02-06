fx_version 'cerulean'
game 'gta5'
lua54 'yes'

dependencies {
  'ox_lib',
  'ox_inventory',
  'oxmysql',
  'es_extended',
  'esx_license',
  'jsfour-idcard'
}

shared_scripts {
  '@ox_lib/init.lua'
}

client_scripts {
  'client.lua'
}

server_scripts {
  '@oxmysql/lib/MySQL.lua',
  'server.lua'
}
