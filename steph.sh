#!/bin/bash

clear

echo "===================="
echo " macOS SETUP SCRIPT "
echo "===================="
echo ""

echo "Installing Brew & Xcode's Command Line Tools"
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew analytics off

git clone https://github.com/stephjackson/dotfiles.git ~/.dotfiles

echo "Closing System Preferences if open..."
osascript -e 'tell application "System Preferences" to quit'

echo "Enabling charging toggle sound..."
defaults write com.apple.PowerChime ChimeOnAllHardware -bool true; open /System/Library/CoreServices/PowerChime.app &

echo "Syncing time..."
sudo ntpdate -u time.apple.com

echo "Enabling keyrepeat globally..."
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

echo "Enabling Safari developer options..."
defaults write com.apple.Safari IncludeDevelopMenu -bool true && \
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true && \
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true && \
defaults write -g WebKitDeveloperExtras -bool true

echo "Dimming hidden Dock icons..."
defaults write com.apple.Dock showhidden -bool YES && killall Dock

echo "Disabling Gatekeeper..."
sudo spctl --master-disable
spctl --status

echo "Enabling tap to click for this user & login screen..."
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

echo "Enabling dark mode..."
defaults write /Library/Preferences/.GlobalPreferences.plist _HIEnableThemeSwitchHotKey -bool true

echo "Upping bluetooth audio quality..."
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Max (editable)" 80
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" 80
defaults write com.apple.BluetoothAudioAgent "Apple Initial Bitpool (editable)" 80
defaults write com.apple.BluetoothAudioAgent "Apple Initial Bitpool Min (editable)" 80
defaults write com.apple.BluetoothAudioAgent "Negotiated Bitpool" 80
defaults write com.apple.BluetoothAudioAgent "Negotiated Bitpool Max" 80
defaults write com.apple.BluetoothAudioAgent "Negotiated Bitpool Min" 80
sudo killall coreaudiod

echo "Expanding save panel by default..."
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

echo "Disabling automatically rearranging spaces..."
defaults write com.apple.dock mru-spaces -bool false

echo "Require password immediately after sleep..."
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

echo "Enabling Ctrl + scroll to zoom screen..."
defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true
defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144

echo "Disabling Dashboard..."
defaults write com.apple.dashboard mcx-disabled -bool true
defaults write com.apple.dock dashboard-in-overlay -bool true

echo "Activity monitor showing stats in dock..."
defaults write com.apple.ActivityMonitor IconType -int 5

echo "Sorting Activity Monitor results by CPU usage..."
defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
defaults write com.apple.ActivityMonitor SortDirection -int 0

echo "Column view by default..."
defaults write com.apple.Finder FXPreferredViewStyle clmv

echo "Allowing text-selection in Quick Look"
defaults write com.apple.finder QLEnableTextSelection -bool true

echo "Speeding up key repeat..."
defaults write -g KeyRepeat -int 2

echo "Searching current dir by default..."
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

echo "Avoiding creation of .DS_Store files on network or USB volumes"
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

echo "Enabling \"Do Not Track\" on Safari..."
defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true

echo "Disabling parental controls on guest user..."
sudo dscl . -mcxdelete /Users/guest
sudo rm -rf /Library/Managed\ Preferences/guest

echo "Disabling opening application prompt..."
defaults write com.apple.LaunchServices LSQuarantine -bool false

echo "Disabling file extension editing warning..."
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

echo "Keeping folders on top of file views..."
defaults write com.apple.finder _FXSortFoldersFirst -bool true

echo "Enabling autoupdates for Safari extensions..."
defaults write com.apple.Safari InstallExtensionUpdatesAutomatically -bool true

echo "Enabling SSH"
sudo systemsetup -setremotelogin on

echo "Changing screenshot location..."
defaults write com.apple.screencapture location ~/Pictures/Screenshots/ && killall SystemUIServer

echo "Enabling daily autoupdates..."
defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1
defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1
defaults write com.apple.commerce AutoUpdate -bool true

echo "Updating system..."
softwareupdate -l && sudo softwareupdate -i

echo "Setting up folders..."
mkdir ~/Pictures/Screenshots/
mkdir ~/Pictures/Wallpapers/
mkdir ~/Code/

echo "Cloning repositories..."
cd ~/Code || exit
git clone git@github.com:stephjackson/dotfiles.git

echo "Linking config files..."
ln -s ~/.dotfiles/config/.zshrc ~/.zshrc
ln -s ~/.dotfiles/config/.gitconfig ~/.gitconfig
ln -s ~/.dotfiles/config/.gitignore_global ~/.gitignore_global
git config --global core.excludesfile ~/.gitignore_global
git config --list

echo "Installing command-line applications..."
installBrews="brew install "
brews=(
    cask # Install GUI applications
    dockutil # Dock rearragment cli
    mas # Mac App Store CLI
    htop # Terminal activity monitor
    neofetch # Displays system info
    node
    r
    ruby
    python
    python3
    shellcheck # Bash file linting
    tldr # man pages for humans
    tree # Prints filetree
    unrar # rar archive cli
    wget
    yarn
    wifi-password #CLI to pull up currently connected wifi's password
)

for brew in ${brews[@]}
do
    installBrews="$installBrews $brew"
done

eval $installBrews

echo "Updating Mac App Store apps..."
mas upgrade

echo "Installing Mac App Store apps..."
mas install 497799835  #Xcode
mas install 803453959  #Slack
mas install 436203431  #XnConvert
mas install 747633105  #Minify = HTML/CSS/JS minifier
mas install 768053424  #Gapplin = SVG Viewer
mas install 568494494  #Pocket
mas install 1163798887 #Savage = SVG optimizer

echo "Installing casks..."
brew tap caskroom/cask
installCasks="brew cask install "
casks=(
    dash # Offline documentation downloader/indexer w/IDE plugins
    firefox
    flux # Better dimming than nightshift
    google-chrome
    handbrake # Converts video formats
    iterm2 # Alternative Terminal app
    monolingual # removes unneeded languages
    onyx # Computer diagnostic tool
    postman # Great API endpoint testing tool
    sequel-pro # SQL GUI
    steam # Video games
    virtualbox # Virtualization
    vlc # Plays almost any video/audio filetype
    visual-studio-code # text editor

    flycut # clipboard history
    basecamp
    spectacle

    qlcolorcode # Syntax highlighted sourcecode
    qlvideo
    quicklook-csv
    quicklook-json
    qlmarkdown
    qlimagesize # Displays image size in preview
    betterzipql
    webpquicklook # Google's Webp image format
    suspicious-package
    provisionql
    quicklookapk
)

for cask in ${casks[@]}
do
    eval "$installCasks $cask"
done

# TODO: Make this universal
echo "Installing NPM packages..."
yarn global add reload eslint csvtojson

echo "Installing Visual Studio Code extensions..."
installExtension="code --install-extension"
extensions=(
    felipe.nasc-touchbar
    shardulm94.trailing-spaces # Highlights whitespace to be deleted
    dbaeumer.vscode-eslint # JavaScript style linting
    christian-kohler.path-intellisense # validates/autocompletes filepaths
    eamodio.gitlens # Best git intergration
    2gua.rainbow-brackets # alternating bracket colors
    pranaygp.vscode-css-peek # Peek at css definitions
    Zignd.html-css-class-completion
    christian-kohler.npm-intellisense # linting for file paths
    zhuangtongfa.material-theme # Atom One Dark theme
    deerawan.vscode-dash
    mkxml.vscode-filesize # Shows current
    felixfbecker.php-intellisense
    stubailo.ignore-gitignore # applies gitignore rules to search
    christian-kohler.npm-intellisense
    ms-python.python
    timonwong.shellcheck
    shinnn.stylelint
    wayou.vscode-todo-highlight # Highlights TODO: comments
    eg2.vscode-npm-script
    joelday.docthis # generates JS doc
    formulahendry.auto-rename-tag # mirrors tag changes to opening & closing tags
    robertohuertasm.vscode-icons
    ms-vscode.cpptools
)

for extension in ${extensions[@]}
do
    eval "$installExtension $extension"
done

echo "Swapping Chrome print dialogue to expanded native dialogue..."
defaults write com.google.Chrome DisablePrintPreview -bool true
defaults write com.google.Chrome PMPrintingExpandedStateForPrint2 -bool true

echo "Configuring iTerm 2"
defaults write com.googlecode.iterm2 PromptOnQuit -bool false # Don’t display the annoying prompt when quitting iTerm

echo "Cleaning up Brew..."
brew cleanup
brew cask cleanup
brew update; brew upgrade; brew prune; brew cleanup; brew doctor

echo "Alphabetizing Launchpad..."
defaults write com.apple.dock ResetLaunchPad -bool true; killall Dock

echo "Defaulting to Google Chrome..."
open -a "Google Chrome" --args --make-default-browser

echo "Setting up Powerline for ..."
cd ~ || exit
git clone https://github.com/powerline/fonts.git
cd fonts || exit
./install.sh
cd .. || exit
rm -rf fonts

echo "Installing Oh-My-ZSH..."
git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
chsh -s /bin/zsh

echo ""
echo "===================="
echo " THAT'S ALL, FOLKS! "
echo "===================="
echo ""
git --version
node -v
npm -v
python3 --version
php -v
docker -v
echo "Typescript:"
tsc -v
sw_vers # macOS version info
uptime

function reboot() {
  read -p "Do you want to reboot your computer now? (y/N)" choice
  case "$choice" in
    y | Yes | yes ) echo "Yes"; exit;; # If y | yes, reboot
    n | N | No | no) echo "No"; exit;; # If n | no, exit
    * ) echo "Invalid answer. Enter \"y/yes\" or \"N/no\"" && return;;
  esac
}

# Call on the function
if [[ "Yes" == $(reboot) ]]
then
  echo "Rebooting."
  sudo reboot
  exit 0
else
  exit 1
fi
