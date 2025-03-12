#!/usr/bin/env bash

# tmux-persist-ssh - A tmux plugin to keep SSH connections alive
# through network interruptions
# 
# Usage:
#   Add to your tmux.conf:
#   set -g @plugin 'username/tmux-persist-ssh'
#   
#   Or clone manually and add:
#   run-shell /path/to/tmux-persist-ssh.tmux

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Default settings
default_ssh_command="autossh -M 0"
default_reconnect_interval="10"
default_alive_interval="60"
default_alive_count_max="3"

tmux_option_ssh_command="@persist-ssh-command"
tmux_option_reconnect_interval="@persist-ssh-reconnect-interval"
tmux_option_alive_interval="@persist-ssh-alive-interval"
tmux_option_alive_count_max="@persist-ssh-alive-count-max"

get_tmux_option() {
  local option=$1
  local default_value=$2
  local option_value=$(tmux show-option -gqv "$option")
  if [ -z "$option_value" ]; then
    echo "$default_value"
  else
    echo "$option_value"
  fi
}

set_ssh_options() {
  local ssh_command=$(get_tmux_option "$tmux_option_ssh_command" "$default_ssh_command")
  local reconnect_interval=$(get_tmux_option "$tmux_option_reconnect_interval" "$default_reconnect_interval")
  local alive_interval=$(get_tmux_option "$tmux_option_alive_interval" "$default_alive_interval")
  local alive_count_max=$(get_tmux_option "$tmux_option_alive_count_max" "$default_alive_count_max")
  
  # Set ServerAliveInterval and ServerAliveCountMax in ssh_config
  if ! grep -q "ServerAliveInterval" ~/.ssh/config 2>/dev/null; then
    mkdir -p ~/.ssh
    touch ~/.ssh/config
    echo "# Added by tmux-persist-ssh" >> ~/.ssh/config
    echo "Host *" >> ~/.ssh/config
    echo "    ServerAliveInterval $alive_interval" >> ~/.ssh/config
    echo "    ServerAliveCountMax $alive_count_max" >> ~/.ssh/config
  fi
  
  # Set environment variables for autossh
  tmux set-environment -g AUTOSSH_POLL "$reconnect_interval"
  tmux set-environment -g AUTOSSH_GATETIME 0
  tmux set-environment -g AUTOSSH_PORT 0

  # Create or update the SSH helper script
  cat > "${CURRENT_DIR}/persist-ssh.sh" << EOF
#!/usr/bin/env bash

# Extract the original SSH command
original_cmd="\$@"

# Use autossh instead of regular ssh
$ssh_command \$original_cmd
EOF

  chmod +x "${CURRENT_DIR}/persist-ssh.sh"
  
  # Create key binding to launch persist-ssh
  tmux bind-key S command-prompt -p "SSH to:" "new-window -n '%1' '${CURRENT_DIR}/persist-ssh.sh %1'"
}

main() {
  set_ssh_options
  
  # Add autocomplete for SSH hosts
  if [ -f ~/.ssh/config ]; then
    hosts=$(grep "^Host " ~/.ssh/config | awk '{print $2}' | sort | uniq)
    if [ -n "$hosts" ]; then
      tmux set-option -g "@persist-ssh-hosts" "$hosts"
    fi
  fi
  
  # Load the plugin status bar indicator
  tmux set-option -g status-right "#[fg=green]#(${CURRENT_DIR}/ssh_status.sh) #[fg=white]| %H:%M %d-%b-%y"
  
  # Create the status script
  cat > "${CURRENT_DIR}/ssh_status.sh" << EOF
#!/usr/bin/env bash
ssh_sessions=\$(tmux list-panes -a -F '#{pane_current_command}' | grep -c "ssh\|autossh")
if [ \$ssh_sessions -gt 0 ]; then
  echo "SSH: \$ssh_sessions"
else
  echo ""
fi
EOF
  chmod +x "${CURRENT_DIR}/ssh_status.sh"
}

main
