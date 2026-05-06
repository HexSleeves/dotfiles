# ============================================================
# Base Dev Container Image for Distrobox
# Managed by chezmoi — edit in dotfiles/home/dot_config/distrobox/
# Deploys to: ~/.config/distrobox/dev.Dockerfile
#
# Build:  podman build -t dev-base:latest -f ~/.config/distrobox/dev.Dockerfile ~/.config/distrobox
# Create: distrobox create --name dev --image dev-base:latest --yes
# ============================================================
FROM archlinux:latest

# Locale
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && locale-gen
ENV LANG=en_US.UTF-8

# Full system update
RUN pacman -Syu --noconfirm

# === Core Dev Tools =========================================
RUN pacman -S --noconfirm --needed \
    git base-devel \
    neovim \
    starship \
    fzf \
    ripgrep \
    fd \
    bat \
    eza \
    zoxide \
    stow \
    jq \
    yq \
    rsync \
    unzip \
    plocate \
    man-db \
    wl-clipboard \
    python \
    python-pip \
    nodejs \
    npm \
    go \
    rust \
    gcc \
    make \
    cmake \
    curl \
    wget \
    openssh \
    tmux \
    lazygit \
    direnv \
    shellcheck \
    shfmt \
    tree \
    htop \
    btop \
    ncdu \
    duf \
    difftastic \
    git-delta \
    tldr \
    httpie \
    zsh \
    zsh-completions \
    zsh-syntax-highlighting \
    zsh-autosuggestions

# === Additional modern CLI tools ============================
RUN pacman -S --noconfirm --needed \
    glow \
    gum \
    entr \
    just \
    watchexec \
    sd \
    dust \
    procs \
    bandwhich \
    xh

# === Use host's podman/docker inside container ==============
# Avoids nested containers. All container commands
# forwarded to the host runtime.
RUN ln -sf /usr/bin/distrobox-host-exec /usr/local/bin/podman && \
    ln -sf /usr/bin/distrobox-host-exec /usr/local/bin/docker

# === Install paru (AUR helper) ==============================
RUN useradd -m builduser && \
    echo "builduser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    su - builduser -c "cd /tmp && \
        curl -L -O https://aur.archlinux.org/cgit/aur.git/snapshot/paru-bin.tar.gz && \
        tar xf paru-bin.tar.gz && \
        cd paru-bin && \
        makepkg -si --noconfirm" && \
    userdel -r builduser && \
    sed -i '/builduser ALL=(ALL) NOPASSWD: ALL/d' /etc/sudoers

# === Shell setup ============================================
# Starship prompt for bash and zsh
RUN echo 'eval "$(starship init bash)"' >> /etc/bash.bashrc && \
    echo 'eval "$(starship init zsh)"' >> /etc/zsh/zshrc

# FZF keybindings
RUN echo 'source /usr/share/fzf/key-bindings.bash' >> /etc/bash.bashrc && \
    echo 'source /usr/share/fzf/completion.bash' >> /etc/bash.bashrc

# Zoxide init
RUN echo 'eval "$(zoxide init bash)"' >> /etc/bash.bashrc && \
    echo 'eval "$(zoxide init zsh)"' >> /etc/zsh/zshrc

# Direnv hook
RUN echo 'eval "$(direnv hook bash)"' >> /etc/bash.bashrc && \
    echo 'eval "$(direnv hook zsh)"' >> /etc/zsh/zshrc

# Default to bash
CMD ["/bin/bash"]
