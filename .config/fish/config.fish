abbr ytdm       'youtube-dl -f bestaudio -i --embed-thumbnail --no-playlist --add-metadata -x --audio-format mp3 -o "./%(title)s.%(ext)s"'
abbr ytdv       'youtube-dl -f "bestvideo[height<=?1080][vcodec!=vp9, vcodec!*=av01]+bestaudio/best" -i --embed-thumbnail --add-metadata -o "./%(title)s.%(ext)s"'
abbr vim        'nvim'
abbr mkdir      'mkdir -p'
abbr trash      'gio trash'
abbr rm         'rm -I'
abbr cp         'cp -riv'
abbr ffcut      'ffmpeg -i in.mp4 -ss 00:00:00 -to 00:00:00 -async 1 out.mp4'
abbr weather	'curl wttr.in/Sępopol'
abbr wlp	    'systemctl --user start wallpaper-changer.service'
abbr du	        'du -sh'
abbr lgscan	    'loudgain --tagmode=e --lowercase --track --noclip'
abbr btm        'btm --battery --group --mem_as_value --color gruvbox'

alias update-hosts 'cd ~/Documents/hosts-generator/ && python3 ./updateHostsFile.py --extensions fakenews --replace'
alias config '/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
alias cdm 'cd ~/Music/'

set EDITOR "nvim"
set BROWSER "firefox"
set TERMINAL "alacritty"

set -x GOPATH ~/Documents/projects/golang
set PATH $PATH $GOPATH/bin

function fish_prompt
    eval /usr/bin/powerline-go -error $status -jobs (jobs -p | wc -l) --theme gruvbox --shell bare
end

function fish_greeting
    fortune
end

set NPM_PACKAGES "$HOME/.npm-global"
set PATH $PATH $NPM_PACKAGES/bin
set MANPATH $NPM_PACKAGES/share/man $MANPATH
