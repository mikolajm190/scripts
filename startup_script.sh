#############################################
##### CachyOS + KDE post install script #####
#############################################

set -euo pipefail

### system update ###
echo "[Step 1]: system update"
sudo pacman -Syu --noconfirm

### package installation ###
echo "[Step 2]: package installation"
sudo pacman -S --noconfirm --needed \
    gimp \
    inkscape \
    intellij-idea-community-edition \
    libreoffice-still \
    libreoffice-still-pl \
    neovim \
    papirus-icon-theme \
    pnpm \
    podman-docker \
    stow \
    tree \
    wl-clipboard \
    vlc \
    zed \
    zen-browser-bin

# tldr update
tldr --update

### cursor + icons ###
echo "[Step 3]: getting cursor and icon theme"
iconsDir="$HOME/.local/share/icons"
mkdir -p "$iconsDir"
rm -rf "$iconsDir/Bibata-Modern-Ice"
tmpDir="$(mktemp -d)"
trap 'rm -rf "$tmpDir"' EXIT
curl -fL --retry 3 --retry-delay 2 -o "$tmpDir/Bibata-Modern-Ice.tar.xz" "https://github.com/ful1e5/Bibata_Cursor/releases/latest/download/Bibata-Modern-Ice.tar.xz"
tar -xJf "$tmpDir/Bibata-Modern-Ice.tar.xz" -C "$iconsDir"

# rm -rf "$HOME/.local/share/icons/Papirus*"
# curl -fL --retry 3 --retry-delay 2 -o "$HOME/.local/share/icons/papirus-icon-theme-breeze-folders.tar.xz" "https://store.kde.org/p/1166289/papirus-icon-theme-breeze-folders.tar.xz"

### plasma settings (theme, keyboard shortcuts, cursor, icons) ###
echo "[Step 4]: adjusting kde settings (theme, keyboard shortcuts, cursor, icons)"

# theme
plasma-apply-lookandfeel "org.kde.breezedark.desktop"

# animations
kwriteconfig6 --file "$HOME/.config/kdeglobals" --group KDE --key AnimationDurationFactor 0

# icons
kwriteconfig6 --file "$HOME/.config/kdeglobals" --group Icons --key Theme "Papirus-Dark"

# cursor
kwriteconfig6 --file "$HOME/.config/kcminputrc" --group Mouse --key cursorSize 28
kwriteconfig6 --file "$HOME/.config/kcminputrc" --group Mouse --key cursorTheme "Bibata-Modern-Ice"

# shortcuts
kwriteconfig6 --file "$HOME/.config/kglobalshortcutsrc" --group kwin --key "Switch One Desktop to the Left" "Meta+Ctrl+Left,Meta+Ctrl+Left,Switch One Desktop to the Left"
kwriteconfig6 --file "$HOME/.config/kglobalshortcutsrc" --group kwin --key "Switch One Desktop to the Right" "Meta+Ctrl+Right,Meta+Ctrl+Right,Switch One Desktop to the Right"
kwriteconfig6 --file "$HOME/.config/kglobalshortcutsrc" --group kwin --key "Window One Desktop to the Left" "Meta+Ctrl+Shift+Left\tCtrl+Alt+Left,Meta+Ctrl+Shift+Left,Window One Desktop to the Left"
kwriteconfig6 --file "$HOME/.config/kglobalshortcutsrc" --group kwin --key "Window One Desktop to the Right" "Meta+Ctrl+Shift+Right\tCtrl+Alt+Right,Meta+Ctrl+Shift+Right,Window One Desktop to the Right"

cat >> "$HOME/.config/kglobalshortcutsrc" <<EOF

[services][Alacritty.desktop]
_launch=Meta+T

[services][org.kde.krunner.desktop]
_launch=Meta+S\tAlt+Space\tSearch\tAlt+F2
EOF

### dotfiles ###
echo "[Step 5]: dotfiles initialization"
dotfilesDir="$HOME/dotfiles"
if [[ -d "$dotfilesDir/.git" ]]; then
  echo "[Info]: dotfiles repo already exists, pulling latest"
  git -C "$dotfilesDir" pull --ff-only
elif [[ -e "$dotfilesDir" ]]; then
  echo "[Error]: $dotfilesDir exists but is not a git repo"
  exit 1
else
  git clone https://github.com/mikolajm190/dotfiles "$dotfilesDir"
fi
stow -d "$dotfilesDir" -t "$HOME" nvim

### git settings ###
echo "[Step 6]: git settings"
echo "Enter git credentials (name and email separated by ',' - e.g. user,user@example.com): "
IFS="," read gitUsername gitEmail
git config --global user.name "$gitUsername"
git config --global user.email "$gitEmail"
git config --global core.editor nvim
git config --global alias.st "status"
git config --global alias.lo "log --oneline --graph --decorate"

echo "Done. Log out and in for changes to take effect"
