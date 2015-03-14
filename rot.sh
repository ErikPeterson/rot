# Rot Hidden Service Manager
#
# Most of this script is ripped from NVM. 
# Credit to Tim Caswell <tim@creationix.com>
#
# Author: Erik Sälgström Peterson
#		  <eriksalgstrom@gmail.com>
# ==========================

ROT_SCRIPT_SOURCE=$_

if [ -z "$ROT_DIR" ]; then
	if [ -n "$BASH_SOURCE" ]; then
		ROT_SCRIPT_SOURCE="${BASH_SOURCE[0]}"
	fi
	export ROT_DIR=$(cd $(dirname "${ROT_SCRIPT_SOURCE:-$0}") > /dev/null && \pwd)
fi
unset ROT_SCRIPT_SOURCE 2> /dev/null

rot_get_os(){
  local ROT_UNAME
  ROT_UNAME="$(uname -a)"
  local ROT_OS
  case "$ROT_UNAME" in
      Linux\ *) ROT_OS=linux ;;
      Darwin\ *) ROT_OS=darwin ;;
      SunOS\ *) ROT_OS=sunos ;;
      FreeBSD\ *) ROT_OS=freebsd ;;
  esac
  echo "$ROT_OS"
}

rot () {
	if [ $# -lt 1 ]; then
		rot help
		return
	fi

	case $1 in
		"help" | "h" )
           	\cat "$ROT_DIR/help.txt"
		;;
        "setup" | "s" )
            local ROT_OS
            ROT_OS=$(rot_get_os)
            local ROT_PORT
            ROT_PORT=9050
            local ROT_TORRC_PATH
            ROT_TORRC="$ROT_DIR/torrc"
            COUNTER=2

            for ARG in $@; do 
               case "$ARG" in
                 -p )
                     ROT_PORT=$(echo "$@" | cut -d " " -f $COUNTER)
                     ;;
                 --port=* )
                     ROT_PORT=$( echo "$ARG" | grep -oE "\d+") 
                     ;;
                 -f )
                     ROT_TORRC_PATH=$(echo "$@" | cut -d " " -f $COUNTER)
                     ;;
                 --file=* )
                     ROT_TORRC_PATH=$( echo "$ARG" | grep -oE "=.*" | grep -oE "[^=].*")
                     ROT_TORRC_PATH=$( echo "$(cd $(dirname $ROT_TORRC_PATH) &> /dev/null; pwd)/$(basename "$ROT_TORRC_PATH")") 
                     ;;
               esac
               let COUNTER=COUNTER+1
            done

            case "$ROT_OS" in
               "darwin" | "linux" | "sunos" | "freebsd" )
                    echo "$ROT_PORT $ROT_TORRC_PATH" 
               ;;
            esac
        ;;
    esac
}
