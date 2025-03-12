# tmux-persist-ssh

A tmux plugin that maintains SSH connections even when the network drops. Say goodbye to disconnected SSH sessions!

![License](https://img.shields.io/github/license/0verflowme/tmux-persist-ssh)
![GitHub stars](https://img.shields.io/github/stars/0verflowme/tmux-persist-ssh?style=social)

## Problem

We've all been there: you're in the middle of an important SSH session, your network hiccups, and suddenly your connection drops. You lose your terminal state, running processes, and context. This is especially frustrating when:

- Working on unstable Wi-Fi
- Using mobile hotspots
- Dealing with VPNs that occasionally disconnect
- SSH sessions to remote servers timeout due to inactivity

## Solution

`tmux-persist-ssh` solves this by:

1. Using `autossh` to automatically reconnect dropped SSH sessions
2. Configuring optimal SSH keepalive settings
3. Providing simple tmux keybindings for persistent SSH connections
4. Adding status indicators for active SSH sessions

## Features

- 🔄 **Auto-reconnect**: Automatically reconnects SSH sessions after network interruptions
- ⏲️ **Keepalive**: Configures optimal SSH keepalive settings to prevent timeouts
- 🚀 **Simple**: Integrates seamlessly with your existing tmux workflow
- 📊 **Status Indicator**: Shows active SSH connections in your tmux status bar
- ⌨️ **Easy Access**: Convenient keybinding to start persistent SSH sessions

## Installation

### Prerequisites

- tmux (version 2.1 or later)
- autossh (`apt-get install autossh`, `brew install autossh`, etc.)

### Using [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm) (recommended)

Add this line to your `.tmux.conf`:

```bash
set -g @plugin '0verflowme/tmux-persist-ssh'
```

Press `prefix + I` to install the plugin.

### Manual Installation

```bash
git clone https://github.com/0verflowme/tmux-persist-ssh.git ~/.tmux/plugins/tmux-persist-ssh
```

Add this line to your `.tmux.conf`:

```bash
run-shell ~/.tmux/plugins/tmux-persist-ssh/tmux-persist-ssh.tmux
```

Reload tmux configuration:

```bash
tmux source-file ~/.tmux.conf
```

## Usage

### Basic Usage

1. Press `prefix + S` (capital S)
2. Enter the SSH destination (e.g., `user@hostname`)
3. A new window will open with your persistent SSH connection

### Configuration Options

Add these to your `.tmux.conf` to customize behavior (showing default values):

```bash
# Command used instead of SSH (default uses autossh)
set -g @persist-ssh-command "autossh -M 0"

# How often to check for reconnection in seconds
set -g @persist-ssh-reconnect-interval "10"

# How often to send keepalive packets in seconds
set -g @persist-ssh-alive-interval "60"

# How many keepalive packets can be missed before connection is considered down
set -g @persist-ssh-alive-count-max "3"
```

## How It Works

1. The plugin replaces standard SSH with autossh, which monitors connections and reconnects them when they drop
2. It configures SSH's built-in keepalive settings to detect disconnections quickly
3. When a network interruption occurs, autossh will automatically attempt to reconnect
4. Your tmux session remains intact, so you can continue where you left off once the connection is restored

## Troubleshooting

### Common Issues

**Q: SSH connections still drop and don't reconnect**
A: Ensure autossh is properly installed and your SSH server allows reconnections. Try increasing the `@persist-ssh-alive-count-max` value.

**Q: The plugin doesn't seem to be working**
A: Make sure you've reloaded your tmux configuration after installation with `tmux source-file ~/.tmux.conf`

**Q: I get "command not found: autossh" errors**
A: Install autossh using your package manager (e.g., `apt-get
