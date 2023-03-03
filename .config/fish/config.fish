abbr mkdir      'mkdir -p'
abbr rm         'rm -I'
abbr cp         'cp -riv'
abbr ffcut      'ffmpeg -i in.mp4 -ss 00:00:00 -to 00:00:00 -async 1 out.mp4'
abbr du	        'du -sh'
abbr copy       'xclip -selection clipboard'
abbr xbox-pad   'xboxdrv --evdev /dev/input/by-id/usb-BDA_XB1_Spectra_Pro_000012812C2DD4AE-event-joystick --mimic-xpad --evdev-absmap ABS_X=x1,ABS_Y=y1,ABS_RX=x2,ABS_RY=y2,ABS_Z=lt,ABS_RZ=rt,ABS_HAT0X=dpad_x,ABS_HAT0Y=dpad_y --evdev-keymap BTN_A=a,BTN_B=b,BTN_X=x,BTN_Y=y,BTN_TL=lb,BTN_TR=rb,BTN_THUMBL=tl,BTN_THUMBR=tr,BTN_MODE=guide,BTN_SELECT=back,BTN_START=start --axismap -Y1=Y1,-Y2=Y2 --detach-kernel-driver --silent'

alias config '/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
alias ls 'exa -aFhm --git --icons --no-permissions --no-user'
#alias ls 'lsd'

function fish_prompt
    eval /usr/bin/powerline-go -error $status -jobs (jobs -p | wc -l) --theme gruvbox
end

#starship init fish | source

function fish_greeting
    fortune
end

zoxide init fish | source
alias cd '__zoxide_z'

fenv source ~/.profile

# TokyoNight Color Palette
  set -l foreground c0caf5
  set -l selection 364A82
  set -l comment 565f89
  set -l red f7768e
  set -l orange ff9e64
  set -l yellow e0af68
  set -l green 9ece6a
  set -l purple 9d7cd8
  set -l cyan 7dcfff
  set -l pink bb9af7
  
  # Syntax Highlighting Colors
  set -g fish_color_normal $foreground
  set -g fish_color_command $cyan
  set -g fish_color_keyword $pink
  set -g fish_color_quote $yellow
  set -g fish_color_redirection $foreground
  set -g fish_color_end $orange
  set -g fish_color_error $red
  set -g fish_color_param $purple
  set -g fish_color_comment $comment
  set -g fish_color_selection --background=$selection
  set -g fish_color_search_match --background=$selection
  set -g fish_color_operator $green
  set -g fish_color_escape $pink
  set -g fish_color_autosuggestion $comment
  
  # Completion Pager Colors
  set -g fish_pager_color_progress $comment
  set -g fish_pager_color_prefix $cyan
  set -g fish_pager_color_completion $foreground
  set -g fish_pager_color_description $comment


# pnpm
set -gx PNPM_HOME "/home/sebastian/.local/share/pnpm"
set -gx PATH "$PNPM_HOME" $PATH
# pnpm end
