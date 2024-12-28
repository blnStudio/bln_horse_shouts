Config = {}

-- Time between voice lines (in seconds)
Config.MinTimeBetweenVoices = 5.0
Config.MaxTimeBetweenVoices = 15.0

-- Chance settings
Config.ChanceToSpeak = 85 -- Percentage chance to trigger voice line

-- Voice line variations 
-- If more than one voice line is provided, a random one will be selected
Config.VoiceLines = {
    male = {
        sprint = {
            {"0711_G_M_M_UNIRANCHERS_01_WHITE_01", "GIDDY_UP"},
            {"EAGLE_FLIES", "GIDDY_UP"}
            -- add more voice lines here
        },
        pat = {
           {"0457_U_M_M_STRSHERRIFF_01", "CALM_HORSE"}
           -- add more voice lines here
        },
        jump = {
            {"0711_G_M_M_UNIRANCHERS_01_WHITE_01", "WHOA_ESCALATED"}
            -- add more voice lines here
        }
    },
    female = {
        sprint = {
            {"MARYBETH", "GIDDY_UP"},
        },
        pat = {
           {"1050_A_F_M_FEMALEROUGHTRAVELLERS_01_WHITE_03", "CALM_HORSE"}
        },
        jump = {
            {"MARYBETH", "WHOA_ESCALATED"}
        }
    }
}