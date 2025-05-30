# General Settings
PROMPT="%F{white}%n %B%F{brightwhite}%~
%F{%(?.blue.red)}%Bλ%b%f "
autoload -Uz compinit && compinit
setopt AUTO_CD CORRECT INTERACTIVE_COMMENTS SHARE_HISTORY

# Aliases
alias g="git"
alias ls="sls -cli"
alias la="sls -clia"
alias mkdir="mkdir -p"
alias dig="deno install -gArf"
alias sf="swift format --recursive --in-place"
alias sl="swift format lint --recursive"
alias sr="swift run"
alias st="swift test"
alias sb="swift build"
alias sbr="swift build -c release"
alias spu="swift package update"
alias v="vim"

# Kill Port
kp() { kill -9 $(lsof -ti tcp:$1) }

# Make Directory and Navigate Into
mkcd() { mkdir $1 && cd $1; }

# Add Localhost Domain
add_vhost() {
  DOMAIN=$1
  DIR=$2

  if [ -z "$DOMAIN" ] || [ -z "$DIR" ]; then
    echo "Usage: add_vhost <domain> <directory>"
    return 1
  fi

  HOSTS_LINE="127.0.0.1 ${DOMAIN}.local"
  HOSTS_FILE="/etc/hosts"
  VHOST_FILE="/etc/apache2/extra/httpd-vhosts.conf"
  LOG_PREFIX="/private/var/log/apache2/${DOMAIN}.local"

  # Add to /etc/hosts if missing
  if ! grep -q "$HOSTS_LINE" "$HOSTS_FILE"; then
    echo "🔧 Adding $HOSTS_LINE to $HOSTS_FILE"
    echo "$HOSTS_LINE" | sudo tee -a "$HOSTS_FILE" > /dev/null
  else
    echo "✅ Hosts entry already present."
  fi

  # Add VirtualHost block
  echo "📝 Adding VirtualHost to $VHOST_FILE"
  sudo tee -a "$VHOST_FILE" > /dev/null <<EOF

<VirtualHost *:80>
    ServerName ${DOMAIN}.local
    DocumentRoot "${DIR}"

    <Directory "${DIR}">
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
				RewriteEngine On
        RewriteCond %{REQUEST_FILENAME} !-d
        RewriteCond %{REQUEST_FILENAME} !-f
        RewriteCond %{REQUEST_FILENAME}.html -f
        RewriteRule ^(.*)$ $1.html [L]
    </Directory>

    ErrorLog "${LOG_PREFIX}-error_log"
    CustomLog "${LOG_PREFIX}-access_log" common
</VirtualHost>
EOF

  echo "🔄 Restarting Apache..."
  sudo apachectl restart
}
