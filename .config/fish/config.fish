abbr ytdm       'youtube-dl -f bestaudio -i --embed-thumbnail --no-playlist --add-metadata -x --audio-format mp3 -o "./%(title)s.%(ext)s"'
abbr ytdv       'youtube-dl -i --embed-thumbnail --add-metadata -o "./%(title)s.%(ext)s"'
abbr mkdir      'mkdir -p'
abbr rm         'rm -I'
abbr cp         'cp -riv'
abbr ffcut      'ffmpeg -i in.mp4 -ss 00:00:00 -to 00:00:00 -async 1 out.mp4'
abbr du	        'du -sh'
abbr lgscan	'loudgain --tagmode=e --lowercase --track --noclip'
abbr paru       'paru --noconfirm'
abbr flatpaki   'flatpak --assumeyes install'
abbr copy       'xclip -selection clipboard'
abbr xbox-pad   'xboxdrv --evdev /dev/input/by-id/usb-BDA_XB1_Spectra_Pro_000012812C2DD4AE-event-joystick --mimic-xpad --evdev-absmap ABS_X=x1,ABS_Y=y1,ABS_RX=x2,ABS_RY=y2,ABS_Z=lt,ABS_RZ=rt,ABS_HAT0X=dpad_x,ABS_HAT0Y=dpad_y --evdev-keymap BTN_A=a,BTN_B=b,BTN_X=x,BTN_Y=y,BTN_TL=lb,BTN_TR=rb,BTN_THUMBL=tl,BTN_THUMBR=tr,BTN_MODE=guide,BTN_SELECT=back,BTN_START=start --axismap -Y1=Y1,-Y2=Y2 --detach-kernel-driver --silent'

alias config '/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
#alias ls 'exa -aFhml --git --icons --no-permissions --no-user'
alias ls 'lsd'
alias ssh 'kitty +kitten ssh'

function fish_prompt
    eval /usr/bin/powerline-go -error $status -jobs (jobs -p | wc -l) --theme gruvbox
end

#starship init fish | source

function fish_greeting
    fortune
end

zoxide init fish | source
alias cd '__zoxide_z'


fenv source .profile
