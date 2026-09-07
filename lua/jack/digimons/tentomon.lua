return {
  name = "Tentomon",
  catchphrase = "🪲 Tentomon digivolve to... Kabuterimon!",
  art = {
    "       ▄██▀     ▄▄▄        ",
    "      ███     ▄██▀         ",
    "    ▄██▀     ███           ",
    "    ███    ▄██▀            ",
    "     ██▄   ███      ▄▄     ",
    "     ▀██  █████████████    ",
    "       █  ▄████████████▄   ",
    "       ▄█████████████████  ",
    "      ████████████████████▄",
    "      ████████████████████▀",
    "    ▄▄▄███████████████████ ",
    " ▄████████▀██████████████▄ ",
    "████████▀▄████████████████ ",
    "▀▀       ▀▀▀▀▀█████▀███████",
    "              ▀▀     ▀▀    ",
  },
  -- Tentomon isn't part of the normal Digimon World (1999) digivolution
  -- tree, so there's no official target-stat table for it like the
  -- others; these are approximate, scaled to match the rest.
  stats = { hp = 600, mp = 600, offense = 90, defense = 70, speed = 80, brains = 90 },
}
