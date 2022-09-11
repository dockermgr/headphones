#!/usr/bin/env bash
# shellcheck shell=bash
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
##@Version           :  202209111159-git
# @@Author           :  Jason Hempstead
# @@Contact          :  jason@casjaysdev.com
# @@License          :  LICENSE.md
# @@ReadME           :  install.sh --help
# @@Copyright        :  Copyright: (c) 2022 Jason Hempstead, Casjays Developments
# @@Created          :  Sunday, Sep 11, 2022 11:59 EDT
# @@File             :  install.sh
# @@Description      :  
# @@Changelog        :  New script
# @@TODO             :  Better documentation
# @@Other            :  
# @@Resource         :  
# @@Terminal App     :  no
# @@sudo/root        :  no
# @@Template         :  installers/dockermgr
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
APPNAME="headphones"
VERSION="202209111159-git"
HOME="${USER_HOME:-$HOME}"
USER="${SUDO_USER:-$USER}"
RUN_USER="${SUDO_USER:-$USER}"
SCRIPT_SRC_DIR="${BASH_SOURCE%/*}"
SCRIPTS_PREFIX="dockermgr"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Set bash options
#if [ ! -t 0 ] && { [ "$1" = --term ] || [ $# = 0 ]; }; then { [ "$1" = --term ] && shift 1 || true; } && TERMINAL_APP="TRUE" myterminal -e "$APPNAME $*" && exit || exit 1; fi
[ "$1" = "--debug" ] && set -x && export SCRIPT_OPTS="--debug" && export _DEBUG="on"
[ "$1" = "--raw" ] && export SHOW_RAW="true"
set -o pipefail
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Import functions
CASJAYSDEVDIR="${CASJAYSDEVDIR:-/usr/local/share/CasjaysDev/scripts}"
SCRIPTSFUNCTDIR="${CASJAYSDEVDIR:-/usr/local/share/CasjaysDev/scripts}/functions"
SCRIPTSFUNCTFILE="${SCRIPTSAPPFUNCTFILE:-mgr-installers.bash}"
SCRIPTSFUNCTURL="${SCRIPTSAPPFUNCTURL:-https://github.com/dfmgr/installer/raw/main/functions}"
connect_test() { curl -q -ILSsf --retry 1 -m 1 "https://1.1.1.1" | grep -iq 'server:*.cloudflare' || return 1; }
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
if [ -f "$PWD/$SCRIPTSFUNCTFILE" ]; then
  . "$PWD/$SCRIPTSFUNCTFILE"
elif [ -f "$SCRIPTSFUNCTDIR/$SCRIPTSFUNCTFILE" ]; then
  . "$SCRIPTSFUNCTDIR/$SCRIPTSFUNCTFILE"
elif connect_test; then
  curl -q -LSsf "$SCRIPTSFUNCTURL/$SCRIPTSFUNCTFILE" -o "/tmp/$SCRIPTSFUNCTFILE" || exit 1
  . "/tmp/$SCRIPTSFUNCTFILE"
else
  echo "Can not load the functions file: $SCRIPTSFUNCTDIR/$SCRIPTSFUNCTFILE" 1>&2
  exit 90
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Define pre-install scripts
run_pre_install() {

  return ${?:-0}
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Define custom functions
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
if [ -f "$PWD/$SCRIPTSFUNCTFILE" ]; then
  . "$PWD/$SCRIPTSFUNCTFILE"
elif [ -f "$SCRIPTSFUNCTDIR/$SCRIPTSFUNCTFILE" ]; then
  . "$SCRIPTSFUNCTDIR/$SCRIPTSFUNCTFILE"
elif connect_test; then
  curl -q -LSsf "$SCRIPTSFUNCTURL/$SCRIPTSFUNCTFILE" -o "/tmp/$SCRIPTSFUNCTFILE" || exit 1
  . "/tmp/$SCRIPTSFUNCTFILE"
else
  echo "Can not load the functions file: $SCRIPTSFUNCTDIR/$SCRIPTSFUNCTFILE" 1>&2
  exit 90
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Call the main function
dockermgr_install
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# trap the cleanup function
trap_exit
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Define extra functions
__sudo() { sudo -n true && eval sudo "$*" || eval "$*" || return 1; }
__sudo_root() { sudo -n true && ask_for_password true && eval sudo "$*" || return 1; }
__enable_ssl() { [ "$SERVER_SSL" = "yes" ] && [ "$SERVER_SSL" = "true" ] && return 0 || return 1; }
__ssl_certs() { [ -f "${1:-$SERVER_SSL_CRT}" ] && [ -f "${2:-SERVER_SSL_KEY}" ] && return 0 || return 1; }
__port_not_in_use() { [ -d "/etc/nginx/vhosts.d" ] && grep -wRsq "${1:-$SERVER_PORT_EXT}" /etc/nginx/vhosts.d && return 0 || return 1; }
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Make sure the scripts repo is installed
scripts_check
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Require a higher version
dockermgr_req_version "$APPVERSION"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Repository variables
REPO="${DOCKERMGRREPO:-https://github.com/dockermgr}/headphones"
APPVERSION="$(__appversion "$REPO/raw/${GIT_REPO_BRANCH:-main}/version.txt")"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Defaults variables
APPNAME="headphones"
INSTDIR="$HOME/.local/share/dockermgr/headphones"
APPDIR="$HOME/.local/share/srv/docker/headphones"
DATADIR="$HOME/.local/share/srv/docker/headphones/files"
DOCKERMGR_HOME="${DOCKERMGR_HOME:-$HOME/.config/myscripts/dockermgr}"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Directory variables for container
SERVER_SSL_DIR="$DATADIR/ssl"
SERVER_DATA_DIR="$DATADIR/data"
SERVER_CONFIG_DIR="$DATADIR/config"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Override container variables
LOCAL_SSL_DIR="${LOCAL_SSL_DIR:-$SERVER_SSL_DIR}"
LOCAL_DATA_DIR="${LOCAL_DATA_DIR:-$SERVER_DATA_DIR}"
LOCAL_CONFIG_DIR="${LOCAL_CONFIG_DIR:-$SERVER_CONFIG_DIR}"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# SSL Setup
SERVER_SSL_DIR="${SERVER_SSL_DIR:-/etc/ssl/CA/CasjaysDev}"
SERVER_SSL_CA="${SERVER_SSL_CA:-$SERVER_SSL_DIR/certs/ca.crt}"
SERVER_SSL_CRT="${SERVER_SSL_CRT:-$SERVER_SSL_DIR/certs/localhost.crt}"
SERVER_SSL_KEY="${SERVER_SSL_KEY:-$SERVER_SSL_DIR/private/localhost.key}"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Setup variables
SERVER_IP="${CURRIP4:-127.0.0.1}"
SERVER_LISTEN="${SERVER_LISTEN:-$SERVER_IP}"
SERVER_DOMAIN="${SERVER_DOMAIN:-"$(hostname -d 2>/dev/null | grep '^' || echo local)"}"
SERVER_HOST="${SERVER_HOST:-$APPNAME.$SERVER_DOMAIN}"
SERVER_TIMEZONE="${TZ:-${TIMEZONE:-America/New_York}}"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Setup nginx proxy variables
NGINX_HTTP="${NGINX_HTTP:-80}"
NGINX_HTTPS="${NGINX_HTTPS:-443}"
NGINX_PORT="${NGINX_HTTPS:-$NGINX_HTTP}"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Port Setup [ _INT is container port ] [ _EXT is docker ]
SERVER_PORT_EXT="${SERVER_PORT_EXT:-}"
SERVER_PORT_INT="${SERVER_PORT_INT:-}"
SERVER_PORT_ADMIN_EXT="${SERVER_PORT_ADMIN_EXT:-}"
SERVER_PORT_ADMIN_INT="${SERVER_PORT_ADMIN_INT:-}"
SERVER_PORT_OTHER_EXT="${SERVER_PORT_OTHER_EXT:-}"
SERVER_PORT_OTHER_INT="${SERVER_PORT_OTHER_INT:-}"
SERVER_WEB_PORT="${SERVER_WEB_PORT:-$SERVER_PORT}"
SERVER_PROXY="${SERVER_PROXY:-https://$SERVER_LISTEN:$SERVER_PORT}"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Show user info message
SERVER_MESSAGE_USER=""
SERVER_MESSAGE_PASS=""
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Show post install message
SERVER_MESSAGE_POST=""
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# URL to container image [docker pull URL]
HUB_URL="hello-world"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# import global variables
if [ -f "$APPDIR/env.sh" ] && [ ! -f "$DOCKERMGR_HOME/env/$APPNAME" ]; then
  mkdir -p "$DOCKERMGR_HOME/env" &&
    cp -Rf "$APPDIR/env.sh" "$DOCKERMGR_HOME/env/$APPNAME"
fi
[ -f "$DOCKERMGR_HOME/env/$APPNAME" ] && . "$DOCKERMGR_HOME/env/$APPNAME"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
if [ -z "$HUB_URL" ] || [ "$HUB_URL" = "hello-world" ]; then
  printf_exit "Please set the url to the containers image"
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Script options IE: --help
show_optvars "$@"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Requires root - no point in continuing
#sudoreq "$0 $*" # sudo required
#sudorun # sudo optional
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Do not update - add --force to overwrite
#installer_noupdate "$@"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Initialize the installer
dockermgr_run_init
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Run pre-install commands
execute "run_pre_install" "Running pre-installation commands"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Ensure directories exist
ensure_dirs
ensure_perms
mkdir -p "$LOCAL_DATA_DIR"
mkdir -p "$LOCAL_CONFIG_DIR"
chmod -Rf 777 "$APPDIR"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Clone/update the repo
if __am_i_online; then
  if [ -d "$INSTDIR/.git" ]; then
    message="Updating $APPNAME configurations"
    execute "git_update $INSTDIR" "$message"
  else
    message="Installing $APPNAME configurations"
    execute "git_clone $REPO $INSTDIR" "$message"
  fi
  # exit on fail
  failexitcode $? "$message has failed"
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Copy over data files - keep the same stucture as -v dataDir/mnt:/mount
if [ -d "$INSTDIR/dataDir" ] && [ ! -f "$DATADIR/.installed" ]; then
  printf_blue "Copying files to $DATADIR"
  cp -Rf "$INSTDIR/dataDir/." "$DATADIR/"
  find "$DATADIR" -name ".gitkeep" -type f -exec rm -rf {} \; &>/dev/null
fi
if [ -f "$DATADIR/.installed" ]; then
  date +'Updated on %Y-%m-%d at %H:%M' >"$DATADIR/.installed"
else
  date +'installed on %Y-%m-%d at %H:%M' >"$DATADIR/.installed"
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Main progam
if cmd_exists docker-compose && [ -f "$INSTDIR/docker-compose.yml" ]; then
  printf_blue "Installing containers using docker-compose"
  sed -i 's|REPLACE_DATADIR|'$DATADIR'' "$INSTDIR/docker-compose.yml"
  if cd "$INSTDIR"; then
    __sudo docker-compose pull &>/dev/null
    __sudo docker-compose up -d &>/dev/null
  fi
else
  __sudo docker stop "$APPNAME" &>/dev/null
  __sudo docker rm -f "$APPNAME" &>/dev/null
  __sudo docker run -d \
    --name="$APPNAME" \
    --hostname "$SERVER_HOST" \
    --restart=always \
    --privileged \
    -e TZ="$SERVER_TIMEZONE" \
    -v $LOCAL_DATA_DIR:/app/data \
    -v $LOCAL_CONFIG_DIR:/app/config \
    -p $SERVER_LISTEN:$SERVER_PORT_EXT:$SERVER_PORT_INT \
    "$HUB_URL" &>/dev/null
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Install nginx proxy
if [ ! -f "/etc/nginx/vhosts.d/$SERVER_HOST.conf" ] && [ -f "$INSTDIR/nginx/proxy.conf" ]; then
  cp -f "$INSTDIR/nginx/proxy.conf" "/tmp/$$.$SERVER_HOST.conf"
  sed -i "s|REPLACE_APPNAME|$APPNAME|g" "/tmp/$$.$SERVER_HOST.conf" &>/dev/null
  sed -i "s|REPLACE_NGINX_PORT|$NGINX_PORT|g" "/tmp/$$.$SERVER_HOST.conf" &>/dev/null
  sed -i "s|REPLACE_SERVER_PORT|$SERVER_PORT_EXT|g" "/tmp/$$.$SERVER_HOST.conf" &>/dev/null
  sed -i "s|REPLACE_SERVER_HOST|$SERVER_DOMAIN|g" "/tmp/$$.$SERVER_HOST.conf" &>/dev/null
  sed -i "s|REPLACE_SERVER_PROXY|$SERVER_PROXY|g" "/tmp/$$.$SERVER_HOST.conf" &>/dev/null
  __sudo_root mv -f "/tmp/$$.$SERVER_HOST.conf" "/etc/nginx/vhosts.d/$SERVER_HOST.conf"
  [ -f "/etc/nginx/vhosts.d/$SERVER_HOST.conf" ] && printf_green "[ ✅ ] Copying the nginx configuration"
  systemctl status nginx | grep -q enabled &>/dev/null && __sudo_root systemctl reload nginx &>/dev/null
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# run post install scripts
run_postinst() {
  dockermgr_run_post
  [ -w "/etc/hosts" ] || return 0
  if ! grep -sq "$SERVER_HOST" /etc/hosts; then
    if [ -n "$SERVER_PORT_INT" ]; then
      if [ $(hostname -d 2>/dev/null | grep '^') = 'local' ]; then
        echo "$SERVER_LISTEN     $APPNAME.local" | sudo tee -a /etc/hosts &>/dev/null
      else
        echo "$SERVER_LISTEN     $APPNAME.local" | sudo tee -a /etc/hosts &>/dev/null
        echo "$SERVER_LISTEN     $SERVER_HOST" | sudo tee -a /etc/hosts &>/dev/null
      fi
    fi
  fi
}
#
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# run post install scripts
execute "run_postinst" "Running post install scripts"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Output post install message

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# create version file
dockermgr_install_version
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# run exit function
if docker ps -a | grep -qs "$APPNAME"; then
  printf_blue "DATADIR in $DATADIR"
  printf_cyan "Installed to $INSTDIR"
  [ -n "$SERVER_IP" ] && [ -n "$SERVER_PORT_EXT" ] && printf_blue "Service is running on: $SERVER_IP:$SERVER_PORT_EXT"
  [ -n "$SERVER_LISTEN" ] && [ -n "$SERVER_WEB_PORT" ] && printf_blue "and should be available at: http://$SERVER_LISTEN:$SERVER_WEB_PORT or http://$SERVER_HOST:$SERVER_WEB_PORT"
  [ -z "$SERVER_WEB_PORT" ] && printf_yellow "This container does not have a web interface"
  [ -n "$SERVER_MESSAGE_USER" ] && printf_cyan "Username is:  $SERVER_MESSAGE_USER"
  [ -n "$SERVER_MESSAGE_PASS" ] && printf_purple "Password is:  $SERVER_MESSAGE_PASS"
  [ -n "$SERVER_MESSAGE_POST" ] && printf_green "$SERVER_MESSAGE_POST"
else
  printf_error "Something seems to have gone wrong with the install"
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# exit
run_exit &>/dev/null
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# End application
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# lets exit with code
exit ${exitCode:-$?}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# end
