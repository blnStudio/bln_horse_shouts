fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

author 'BLN Studio <bln.tebex.io>'
description 'Enhance your horse riding experience with immersive voice lines! Your character will naturally react while riding, jumping, and interacting with their horse, just like in the original RDR2 story mode.'
version '1.0.0'

client_scripts {
    'c/*.lua'
}

server_scripts {
    's/*.lua'
}

shared_scripts {
    'shared/*.lua',
    'config.lua'
}
