# Path to your oh-my-zsh installation.
export ZSH="/home/falk/.oh-my-zsh"
export MANPATH="/usr/local/man:$MANPATH"

# Theme {{{
# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME="robbyrussell"
ZSH_THEME="falk"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )
# Theme }}}
# Completion {{{

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Completion }}}
# Updates {{{

# Uncomment the following line to disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Updates }}}
# Misc {{{{{{
# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder
# Misc }}}}}}
# Auxilary Support Functions {{{
   # arg1    str    string to highlight
   function _HL () {
      printf "\033[1;38;5;222m%s\033[0m" $1
   }
   
   # arg 1:  R;G;B   new FG
   FG () {
      printf "\[\033[38;2;%sm\]" $1
   }
   
   # arg 1:  R;G;B   new BG
   BG () {
      printf "\[\033[48;2;%sm\]" $1
   }

   # arg 1: 256 color code   new FG
   # arg 2: str              text to color
   FG256 () {
      printf "\033[38;5;%sm%s\033[0m" "$1" "$2"
   }

   # arg 1: 256 color code   new BG
   # arg 2: str              text to color
   BG256 () {
      printf "\033[48;5;%sm%s\033[0m" "$1" "$2"
   }
   
   # arg 1:  R;G;B  line color
   LINE () {
      FG $1
      for x in `seq 2 $(stty size | awk '{print $2}')`;
         do printf "─";
      done
   }
   
   # no args
   CLEAR () {
      printf "\[\033[39;49m\]"
   }
# Auxilary Support Functions }}} 
# Plugins {{{

# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/{{{}}}
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)
source $ZSH/oh-my-zsh.sh
# Plugins }}}
# Scripts {{{
# VPN {{{
function vpn() {
   if [ $# -eq 0 ] || [ "$1" = "status" ]; then
      nordvpn status | sed '1 i\ ' | sed -r "s/(.*:)/    $(tput setaf 254)\1$(tput setaf 246)/g; s/Connected/$(tput setaf 2)Connected\!$(tput sgr0)/; s/Disconnected/$(tput setaf 203)Disconnected\!/"
   elif [ "$1" = "reconnect" ] || [ "$1" = "rc" ]; then
      nordvpn disconnect > /dev/null; echo "\nReconnecting...";
      if [ $# -eq 2 ]; then
         nordvpn connect $2
      else
         nordvpn connect
      fi
   elif [ "$1" = "disconnect" ] || [ "$1" = "dc" ]; then
      nordvpn disconnect | sed '1 i\ ' | sed '/^How/d' | sed "s/You are not connected to NordVPN/    $(tput setaf 245)You are not connected/g; s/You are disconnected from NordVPN/    $(tput setaf 245)You are disconnected/g"
   else
      echo ""; nordvpn connect $1
   fi
}
# }}}
# Move &  Link {{{
function mvl() {
   set -e
   original="$1" target="$2"
   if [ -d "$target" ]; then
     target="$target/${original##*/}"
   fi
   mv -- "$original" "$target"
   case "$original" in
      */*)
      case "$target" in
         /*) :;;
         *) target="$(cd -- "$(dirname -- "$target")" && pwd)/${target##*/}"
      esac
   esac
   ln -s -- "$target" "$original"
}
# Move & Link }}}
# PrintPath {{{
printpath () {
   printf "\e[1;38;5;222m%s\e[0m\n" "$(printf "    $PATH" | sed "s/:/\n    /g" | sort)"
}
# PrintPath }}}
# Twitch Stalk {{{ 
   function twitchstalk() {
      if [ $# -eq 0 ]
      then
          echo "No arguments supplied"
      elif [ $# -eq 1 ]
      then # Presents everyone in a Twitch channel as an interactive json tree.
         (echo -n "{ \"$1\": "; curl -s "https://tmi.twitch.tv/group/user/$1/chatters"; printf "}" ) | fx
      elif [ $# -eq 2 ]
      then # Looks for argument 1 in argument 2's channel
         local result=$( curl -s "https://tmi.twitch.tv/group/user/$2/chatters" | grep "$1" )
         if [ -z $result ]
         then
            printf "Target \033[1;38;5;221m%s\033[0m is not present in \033[1;38;5;255m%s\033[0m's channel!\n" $1 $2
         else
            printf "Found target \033[1;38;5;221m%s\033[0m in \033[1;38;5;255m%s\033[0m's channel!\n" $1 $2
         fi
      fi
   }
# Twitch List }}}
# Up {{{
   # Move 'up' N directories
   up() {
      cd $(eval printf '../'%.0s {1..$1}) && pwd;
   }
# Up }}}
# Extract {{{
extract () {
   if [ -f $1 ] ; then
      case $1 in
         *.tar.bz2)   tar xvjf $1   ;;
         *.tar.gz)    tar xvzf $1   ;;
         *.bz2)       bunzip2 $1    ;;
         *.rar)       unrar x $1    ;;
         *.gz)        gunzip $1     ;;
         *.tar)       tar xvf $1    ;;
         *.tbz2)      tar xvjf $1   ;;
         *.tgz)       tar xvzf $1   ;;
         *.zip)       unzip $1      ;;
         *.Z)         uncompress $1 ;;
         *.7z)        7z x $1       ;;
         *) echo "[ERROR] Unsupported format of file: '$1'..." ;;
      esac
   else
      echo "'$1' is not a valid file!"
   fi
}
# Extract }}}
# Git {{{
function gitpush() {
  git add .; git commit -m "${1}"; git push
}

function gitpushf() {
  git add .; git commit -m "${1}"; git push --force 
}
# Git }}}
# Runebook {{{
# TODO: Make runes persistent via file I/O?
# Variables & Config {{{
declare -A runebook=(
   # add persistent rune entries below:
   [tmp]=~/Temp
   [dl]=~/Downloads
   [doc]=~/Documents
   [code]=~/Code
   [home]=~
   [repos]=~/.repos
   [scripts]=~/Code/Scripts
   [cfg]=~/.config
)

verbose_rune_system="true"
# Variables & Config }}}
# Functions {{{
# Mark {{{
# # arg1    str    rune name
function mark () {
   runebook[$1]=$(pwd)
   if [[ "$verbose_rune_system" == "true" ]]; then
      printf "Marking rune '%s' at '%s'... %s\n" "$(FG256 "228" $1)" "$(FG256 "228" ${runebook[$1]})" "$(FG256 "231" "Kal Por Ylem")" 
   fi
}
# Mark }}}
# Recall {{{
# arg1    str    rune name
function recall () {
   if [[ -z ${runebook[$1]} ]]; then
      if [[ "$verbose_rune_system" == 'true' ]]; then
         printf "Rune '%s' is unmarked.\n" $(_HL $1)
      fi
   else
      if [[ "$verbose_rune_system" == 'true' ]]; then
         printf "Recalling rune '%s'... %s\n" "$(FG256 "228" $1)" "$(FG256 "231" "Kal Ort Por")"
      fi
      cd ${runebook[$1]}
   fi
}
# Recall }}}
# Rune {{{
# arg1    str    rune name
function rune () {
   if [[ -z ${runebook[$1]} ]]; then
      printf "Rune '%s' is unmarked.\n" $(_HL $1)
   else
      printf "Rune '%s' is marked at '%s'.\n" $(_HL $1) $(_HL ${runebook[$1]})
   fi
}
# Rune }}}
# Runes {{{
function runes () {
   printf "\n$(tput setaf 231) Listing all currently marked runes:$(tput sgr0)\n"
   for i in "${(@k)runebook}"
   do
      local name=$i
      local destination=${runebook[$i]}
      printf "   %-18s %s\n" "$name" "$(_HL $destination)"
   done
}
# Runes }}}
# Functions }}}
# Runebook }}}
# Translate {{{
   # Usage:   translate <phrase> <output-language> 
   # Example: translate "Bonjour! Ca va?" en 
   # See this for a list of language codes: http://en.wikipedia.org/wiki/List_of_ISO_639-1_codes
   function translate() {
      wget -U "Mozilla/5.0" -qO - "http://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=$2&dt=t&q=$(echo $1 | sed "s/[\"'<>]//g")" | sed "s/,,,0]],,.*//g" | awk -F'"' '{print $2, $6}';
   }
# Translate }}}
# ccat {{{
   # Prints code files with syntax highlighting, step navigation, and line numbers
   ccat() {
      pygmentize -f terminal -g -O linenos=1 $*
   }
   ccl() {
      ccat $* | less -R
   }
# ccat }}}
# fawk {{{
   # Prints a word from a certain column of the output when piping.
   # Example: cat /path/to/file.txt | fawk 2 --> Print every 2nd word in each line.
   function fawk {
      first="awk '{print "
      last="}'"
      cmd="${first}\$${1}${last}"
      eval $cmd
   }
# fawk }}}
# sbs (Sort-By-Size) {{{
   sbs() {
      du -b --max-depth 1 | sort -nr | perl -pe 's{([0-9]+)}{sprintf "%.1f%s", $1>=2**30? ($1/2**30, "G"):    $1>=2**20? ($1/2**20, "M"): $1>=2**10? ($1/2**10, "K"): ($1, "")}e';
   }
# sbs (Sort-By-Size) }}}
# Task List [DISABLED] {{{
#  TASKFILE="$HOME/.bashtask" # Hidden for neatness
#  NC='\033[0m' # No Color
#  LIGHTRED='\e[1;31m'
#  LIGHTBLUE='\e[1;34m'
#  if [ -f "$TASKFILE" ] && [ $(stat -c %s "$TASKFILE") != 0 ] # Check if file has content
#  then
#      echo -e "${LIGHTRED}Task List${NC} as of ${LIGHTBLUE}$(date -r "$TASKFILE")${NC}"
#      echo ""
#      cat "$TASKFILE"
#      printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' "-"
#  else
#      echo "No tasks!"
#      printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' "-"
#      touch "$TASKFILE"
#  fi
#  
#  alias tasklist="bash"
#  
#  # Add a task
#  function taskadd() {
#     echo "- $1" >> "$TASKFILE";
#  } # Example: taskadd "Go grocery shopping"
#  
#  # Insert a task between two items
#  function taskin() {
#     sed -i "$1i- $2" "$TASKFILE";
#  } # Example: TODO
#  
#  # Remove a task
#  function taskrm() {
#     sed -i "$1d" "$TASKFILE";
#  } # Example: taskrm 2 --> Removes second item in list
#  
#  # Clears all tasks
#  function taskclr() {
#     rm "$TASKFILE"; touch "$TASKFILE";
#  }
# Task List }}}
# Conversion {{{
 #Converting audio and video files
function 2ogg  () { eyeD3 --remove-all-images "$1"; fname="${1%.*}"; sox "$1" "$fname.ogg" && rm "$1"; }
function 2wav  () { fname="${1%.*}"; ffmpeg -threads 0 -i "$1" "$fname.wav" && rm "$1"; }
function 2aif  () { fname="${1%.*}"; ffmpeg -threads 0 -i "$1" "$fname.aif" && rm "$1"; }
function 2mp3  () { fname="${1%.*}"; ffmpeg -threads 0 -i "$1" "$fname.mp3" && rm "$1"; }
function 2mov  () { fname="${1%.*}"; ffmpeg -threads 0 -i "$1" "$fname.mov" && rm "$1"; }
function 2mp4  () { fname="${1%.*}"; ffmpeg -threads 0 -i "$1" "$fname.mp4" && rm "$1"; }
function 2avi  () { fname="${1%.*}"; ffmpeg -threads 0 -i "$1" "$fname.avi" && rm "$1"; }
function 2webm () { fname="${1%.*}"; ffmpeg -threads 0 -i "$1" -c:v libvpx "$fname.webm" && rm "$1"; }
function 2h265 () { fname="${1%.*}"; ffmpeg -threads 0 -i "$1" -c:v libx265 "$fname'_converted'.mp4" && rm "$1"; }
function 2flv  () { fname="${1%.*}"; ffmpeg -threads 0 -i "$1" "$fname.flv" && rm "$1"; }
function 2mpg  () { fname="${1%.*}"; ffmpeg -threads 0 -i "$1" "$fname.mpg" && rm "$1"; }

#Converting documents and images
function 2txt() { soffice --headless txt "$1"; }
function 2pdf() {
   if [ ${1: -4} == ".html" ]
   then
      fname="${1%.*}"
      soffice --headless --convert-to odt "$1"
      soffice --headless pdf "$fname.html"
   else
      soffice --headless pdf "$1"
   fi
}
function 2doc() { soffice --headless doc "$1"; }
function 2odt() { soffice --headless odt "$1"; }
function 2jpeg() { fname="${1%.*}"; convert "$1" "$fname.jpg" && rm "$1"; }
function 2jpg() { fname="${1%.*}"; convert "$1" "$fname.jpg" && rm "$1"; }
function 2png() { fname="${1%.*}"; convert "$1" "$fname.png" && rm "$1"; }
function 2bmp() { fname="${1%.*}"; convert "$1" "$fname.bmp" && rm "$1"; }
function 2tiff() { fname="${1%.*}"; convert "$1" "$fname.tiff" && rm "$1"; }
function 2gif() {
   fname="${1%.*}"
   if [ ! -d "/tmp/gif" ]; then mkdir "/tmp/gif"; fi
   if [ ${1: -4} == ".mp4" ] || [ ${1: -4} == ".mov" ] || [ ${1: -4} == ".avi" ] || [ ${1: -4} == ".flv" ] || [ ${1: -4} == ".mpg" ] || [ ${1: -4} == ".webm" ]
   then
      ffmpeg -i "$1" -r 10 -vf 'scale=trunc(oh*a/2)*2:480' /tmp/gif/out%04d.png
      convert -delay 1x10 "/tmp/gif/*.png" -fuzz 2% +dither -coalesce -layers OptimizeTransparency +map "$fname.gif"
   else
      convert "$1" "$fname.gif"
      rm "$1"
   fi
   rm -r "/tmp/gif"
}

ai2svg() {
   local d
   local svg
   for d in *.ai; do
      d=$(echo "$(cd "$(dirname "$d")"; pwd)/$(basename "$d")")
      svg=$(echo "$d" | sed 's/.ai/.svg/')
      echo "Creating $svg ..."
      inkscape -f "$d" -l "$svg"
   done
}

# Conversion }}}
# Scripts }}}
# User config {{{
# JP Input {{{
   export GTK_IM_MODULE=fcitx
   export XMODIFIERS=@im=fcitx
   export QT_IM_MODULE=fcitx
# JP Input }}}
# Kitty Auto Completion {{{
autoload -Uz compinit
compinit
# Completion for kitty
kitty + complete setup zsh | source /dev/stdin
# Kitty Auto Completion }}}
# Editor Preference {{{
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi
# Editor Preference }}}
# Compilation flags {{{
# export ARCHFLAGS="-arch x86_64"
# Compilation Flags }}}
# Aliases {{{
alias show="kitty +kitten icat"
# # Font Installer {{{
alias install-fonts="sudo mv ~/Downloads/fonts/* /usr/share/fonts ; fc-cache"
# Font Installer }}}
# Zsh {{{
alias zshedit="nvim ~/.zshrc"
alias ohmyzsh="nvim ~/.oh-my-zsh"
alias zshreload="source ~/.zshrc"
# Zsh }}}
# User Safety {{{
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
# User Safety}}}
# Navigation {{{
# Find {{{
alias f='find . -type f -regex '
# Find }}}
# Tree {{{
function pretty_tree() {
   local args
   # if only one argument that's a number, assume it's the desired depth
   if [[ $1 =~ '^[0-9]+$' ]]; then
      tree -L $* -l -q -v --dirsfirst -C | sed -e 's/^/ /g; s/├── /├─● /g; s/└── /└─● /g; s/  / /g; s/  / /g'
   else
      tree $* -l -q -v --dirsfirst -C | sed -e 's/^/ /g; s/├── /├─● /g; s/└── /└─● /g; s/  / /g; s/  / /g'
   fi
}
alias T=pretty_tree
# Tree }}}
# LS {{{
alias ll='ls -l'
alias la='ls -A'
alias lo='ls -o'
alias lh='ls -lh'
alias la='ls -la'
alias sl='ls'
alias l='ls -CF'
alias s='ls'
# LS }}}
# Path {{{
alias 'home'='cd ~/'
alias cd..='cd ..'
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
# Path }}}
# Navigation }}}
# Clear {{{
alias cl='clear'
alias cls='clear'
# Clear }}}
# Make {{{
alias remake='make remake | grep -v "## *\|()"'
# Make }}}
# Git {{{
alias gs='git status'
alias gc='git commit'
# ssh clones repo in arg $1
function gC () {
   git clone git@github.com:$1
}
# pulls, adds all files, commits (with optional message), then pushes
function gpacp () {
   local cmd="gp && ga . && gc "
   if [[ $# -ne 0 ]]; then
      cmd+="-m'"$1"' "
   fi
   cmd+="&& gP"
   eval ${cmd}
}
alias ga='git add'
alias gd='git diff'
alias gb='git branch'
alias gl='git log'
alias gP='git push'
alias gp='git pull'
alias gsb='git show-branch'
alias gco='git checkout'
alias gg='git grep'
alias gk='gitk --all'
alias gr='git rebase'
alias gri='git rebase --interactive'
alias gcp='git cherry-pick'
alias grm='git rm'
# Git }}}
# Logs {{{
alias logs="sudo find /var/log -type f -exec file {} \; | grep 'text' | cut -d' ' -f1 | sed -e's/:$//g'"
# Logs }}}
# Programs {{{
alias discord-tui='TERM=xterm-truecolor 6cord -u frigatzi@gmail.com -p 4Mqlj8is!!Hkd00d!! --properties.sidebar-ratio 2 --properties.chat-padding 1 --properties.show-emoji-urls false --properties.foreground-color 252 --properties.command-prefix "[::b][\${GUILD} \${CHANNEL}][::-][#FF00FF] " --properties.author-format "[#{color}::b]{name}: " --properties.default-status "Type here..."'
alias r=ranger
alias busy="cat /dev/urandom | hexdump -C | grep 'ca fe'"
alias diskspace="du -S | sort -n -r | less"
alias blender='optirun /opt/blender-2.80/blender'
alias subtex3='/opt/sublime_text/sublime_text'
alias rec='recall'
alias lc='lolcat'
# Programs }}}
# Color Support {{{
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto --group-directories-first'
    alias lsd='ls -l -s -h'
    alias d='colorls -A --group-directories-first'
    alias cla='clear; echo -ne "\e[3J"'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi
# Color Support }}}
# Aliases }}}
# Misc {{{
   # colored GCC warnings and errors
   export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
   # make less more friendly for non-text input files, see lesspipe(1)
   [ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"
   # add color in manpages for less:
   export LESS_TERMCAP_mb=$'\E[01;31m'
   export LESS_TERMCAP_md=$'\E[01;31m'
   export LESS_TERMCAP_me=$'\E[0m'
   export LESS_TERMCAP_se=$'\E[0m'
   export LESS_TERMCAP_so=$'\E[01;44;33m'
   export LESS_TERMCAP_ue=$'\E[0m'
   export LESS_TERMCAP_us=$'\E[01;32m'
# Misc }}}
# Path Additions {{{
export PYTHONPATH="${PYTHONPATH}:/usr/local/lib/python2.7/site-packages:/usr/lib/python2.7/site-packages"
export PYTHONPATH="${PYTHONPATH}:/home/falk/.local/bin"

export PATH=$HOME/bin:/usr/local/bin:$PATH
export PATH=$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH
export PATH=$HOME/.gem/ruby/2.7.0/bin:$PATH
export PATH=$HOME/.local/bin:/sbin/:/usr/local/sbin:$PATH
# remove duplicate path entries
PATH=$(printf "%s" "$PATH" | awk -v RS=':' '!a[$1]++ { if (NR > 1) printf RS; printf $1 }')
# Path Additions }}}
# User config }}}
# EOF
