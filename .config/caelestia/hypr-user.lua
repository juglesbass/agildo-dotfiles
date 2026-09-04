-- 🖥️ Monitor Scaling (4K @ 200% / 2.0x)
hl.monitor({
    output   = "HDMI-A-1",
    mode     = "3840x2160@60",
    position = "0x0",
    scale    = 2.00,
})

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 2.00,
})

-- 🖼️ Autostart e Atalhos do Waypaper
hl.on("hyprland.start", function()
    hl.exec_cmd("/home/agildo/.local/bin/hyprland-autostart.sh")
end)

hl.bind("SUPER + W", hl.dsp.exec_cmd("waypaper --random"))
hl.bind("SUPER + SHIFT + W", hl.dsp.exec_cmd("waypaper"))

-- 💻 Atalhos de Terminal
hl.bind("SUPER + RETURN", hl.dsp.exec_cmd("foot"))
hl.bind("SUPER + T", hl.dsp.exec_cmd("foot"))
hl.bind("SUPER + Q", hl.dsp.exec_cmd("foot"))

-- ⬇️ Minimizar Janela (Super + Seta para Baixo / F9 / Super + N)
hl.bind("SUPER + Down", hl.dsp.exec_cmd("/home/agildo/.local/bin/window-minimize.sh minimize"))
hl.bind("SUPER + N", hl.dsp.exec_cmd("/home/agildo/.local/bin/window-minimize.sh minimize"))
hl.bind("F9", hl.dsp.exec_cmd("/home/agildo/.local/bin/window-minimize.sh minimize"))

-- 🔄 Restaurar Janela Minimizada (Super + Seta para Cima / F8 / Super + U)
hl.bind("SUPER + Up", hl.dsp.exec_cmd("/home/agildo/.local/bin/window-minimize.sh restore"))
hl.bind("SUPER + SHIFT + Up", hl.dsp.exec_cmd("/home/agildo/.local/bin/window-minimize.sh restore"))
hl.bind("SUPER + U", hl.dsp.exec_cmd("/home/agildo/.local/bin/window-minimize.sh restore"))
hl.bind("F8", hl.dsp.exec_cmd("/home/agildo/.local/bin/window-minimize.sh restore"))

-- ⬆️ Maximizar / Desmaximizar Janela (Super + M / F10)
hl.bind("SUPER + M", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind("F10", hl.dsp.window.fullscreen({ mode = "maximized" }))

-- 🖥️ Tela Cheia Total (F11 / Super + F)
hl.bind("F11", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind("SUPER + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))

-- 🪟 Barra de Título & Botões Coloridos de Janela (Fechar, Flutuar, Maximizar)
pcall(function()
    hl.plugin.load("/home/agildo/.config/hypr/plugins/hyprbars.so")
end)

hl.config({
    plugin = {
        hyprbars = {
            bar_height = 32,
            bar_color = "rgba(24, 24, 37, 0.95)",
            bar_text_font = "SF Pro Display, sans-serif",
            bar_text_size = 12,
            bar_text_align = "left",
            bar_buttons_alignment = "left",
            bar_part_of_window = true,
            bar_precedence_over_border = true,
        },
    },
})

pcall(function()
    if hl.plugin and hl.plugin.hyprbars and hl.plugin.hyprbars.add_button then
        hl.plugin.hyprbars.add_button({ bg_color = "rgba(ff5555ff)", fg_color = "rgba(ffffffff)", size = 14, icon = "󰅖", action = "hyprctl dispatch killactive" })
        hl.plugin.hyprbars.add_button({ bg_color = "rgba(ffb86cff)", fg_color = "rgba(ffffffff)", size = 14, icon = "󰍵", action = "hyprctl dispatch togglefloating" })
        hl.plugin.hyprbars.add_button({ bg_color = "rgba(50fa7bff)", fg_color = "rgba(ffffffff)", size = 14, icon = "󰊓", action = "hyprctl dispatch fullscreen 1" })
    end
end)
