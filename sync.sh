#!/bin/bash
set -e
DOTFILES="$HOME/.dotfiles"
HOSTNAME=$(hostname)

# cp -r into an existing dir nests the source inside it (dst/src); replace instead
copy_dir() {
    [ -d "$1" ] || return 0
    rm -rf "$2"
    cp -r "$1" "$2"
}

# Copy configs into dotfiles (common)
copy_dir ~/.config/nvim        "$DOTFILES/nvim"
copy_dir ~/.config/fastfetch   "$DOTFILES/fastfetch"
copy_dir ~/.config/tmux        "$DOTFILES/tmux"
mkdir -p "$DOTFILES/.local/bin" "$DOTFILES/.local/share" "$DOTFILES/.config/opencode" "$DOTFILES/.codex"
cp ~/.local/bin/cs2-reaction "$DOTFILES/.local/bin/cs2-reaction" 2>/dev/null || true
copy_dir ~/.local/share/cs2-reactions "$DOTFILES/.local/share/cs2-reactions"
cp ~/.config/opencode/opencode.json "$DOTFILES/.config/opencode/opencode.json" 2>/dev/null || true
cp ~/.config/opencode/package.json "$DOTFILES/.config/opencode/package.json" 2>/dev/null || true
copy_dir ~/.config/opencode/plugins "$DOTFILES/.config/opencode/plugins"
cp ~/.codex/config.toml "$DOTFILES/.codex/config.toml" 2>/dev/null || true
copy_dir ~/.codex/hooks "$DOTFILES/.codex/hooks"

# Machine-specific configs
if [ "$HOSTNAME" = "carbon" ]; then
    copy_dir ~/.config/hypr    "$DOTFILES/hypr"
    copy_dir ~/.config/waybar  "$DOTFILES/waybar"
    copy_dir ~/.config/ghostty "$DOTFILES/ghostty"
    cp ~/.zshrc             "$DOTFILES/.zshrc.omarchy"
    cp ~/.config/tmux/tmux.conf "$DOTFILES/.tmux.conf.omarchy"
elif [ "$HOSTNAME" = "do" ] || [ "$HOSTNAME" = "ubuntui3" ]; then
    copy_dir ~/.config/kitty   "$DOTFILES/kitty"
    copy_dir ~/.config/ghostty "$DOTFILES/ghostty"
    copy_dir ~/.config/i3      "$DOTFILES/i3"
    copy_dir ~/.config/i3blocks "$DOTFILES/i3blocks"
    copy_dir ~/.config/waybar  "$DOTFILES/waybar"
    cp ~/.zshrc             "$DOTFILES/.zshrc.ubuntui3"
    cp ~/.config/tmux/tmux.conf "$DOTFILES/.tmux.conf.ubuntui3" 2>/dev/null || true
fi

# Commit and push
cd "$DOTFILES"
git add -A
git diff --cached --quiet || git commit -m "sync: $HOSTNAME $(date '+%Y-%m-%d %H:%M')"
git push

rm -rf nvim hypr systemd tmux waybar ghostty fastfetch

echo "Done."
