# Use Debian as a base image
FROM debian:latest

RUN mkdir /root/Tools

# Ensure up-to-date
RUN apt update -y && apt full-upgrade -y
# Install required items
RUN apt install build-essential clang git gdb sudo zsh curl wget luarocks unzip ripgrep lazygit fastfetch fzf tmux vim -y

# Switch to dev user
RUN useradd -m -s $(which zsh) devuser && \
    usermod -aG sudo devuser && \
    echo "devuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER devuser
WORKDIR /home/devuser

# Pull third-party tools
RUN wget https://github.com/neovim/neovim/releases/latest/download/nvim-linux-$(uname -m).tar.gz -P ~/Tools/.pull

# Install third-party tools
RUN tar xzvf ~/Tools/.pull/nvim-linux-$(uname -m).tar.gz -C ~/Tools/.pull && \
    # mv ~/Tools/nvim-linux-$(uname -m) ~/Tools/nvim && \
    ln ~/Tools/.pull/nvim-linux-$(uname -m)/bin/nvim ~/Tools/nvim

# Clone configurations from GitHub
RUN git clone https://github.com/centenv-env/nvim.git ~/.config/nvim && \
    git clone https://github.com/centenv-env/zsh.git ~/.config/zsh && \
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions && \
    git clone https://github.com/centenv-env/centmux.git ~/.config/tmux && \
    git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm

# Post install tasks
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
    rm -f .zshrc && \
    ln ~/.config/zsh/.zshrc ~/.zshrc && \
    ln ~/.config/zsh/.zshenv ~/.zshenv && \
    awk '/ZSH_THEME=/{gsub(/"[^"]*"/, "\"robbyrussell\"")} 1' ~/.zshrc > /tmp/.zshrc_tmp && mv /tmp/.zshrc_tmp ~/.zshrc

# Install languages
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    sudo apt install default-jdk python3 python3-pip -y

# Run until explicitly stopped
CMD [ "sleep", "infinity" ]
