########################################################################################################################
# Find Us                                                                                                              #
# Author: Mehmet ÖĞMEN                                                                                                 #
# Web   : https://x-shell.codes/scripts/redis                                                                          #
# Email : mailto:redis.script@x-shell.codes                                                                            #
# GitHub: https://github.com/x-shell-codes/redis                                                                       #
########################################################################################################################
# Contact The Developer:                                                                                               #
# https://www.mehmetogmen.com.tr - mailto:www@mehmetogmen.com.tr                                                       #
########################################################################################################################

########################################################################################################################
# Constants                                                                                                            #
########################################################################################################################
NORMAL_LINE=$(tput sgr0)
RED_LINE=$(tput setaf 1)
YELLOW_LINE=$(tput setaf 3)
GREEN_LINE=$(tput setaf 2)
BLUE_LINE=$(tput setaf 4)
POWDER_BLUE_LINE=$(tput setaf 153)
BRIGHT_LINE=$(tput bold)
REVERSE_LINE=$(tput smso)
UNDER_LINE=$(tput smul)

########################################################################################################################
# Line Helper Functions                                                                                                #
########################################################################################################################
function ErrorLine() {
  echo "${RED_LINE}$1${NORMAL_LINE}"
}

function WarningLine() {
  echo "${YELLOW_LINE}$1${NORMAL_LINE}"
}

function SuccessLine() {
  echo "${GREEN_LINE}$1${NORMAL_LINE}"
}

function InfoLine() {
  echo "${BLUE_LINE}$1${NORMAL_LINE}"
}

########################################################################################################################
# Version                                                                                                              #
########################################################################################################################
function Version() {
  echo "Redis install script version 1.0.0"
  echo
  echo "${BRIGHT_LINE}${UNDER_LINE}Find Us${NORMAL}"
  echo "${BRIGHT_LINE}Author${NORMAL}: Mehmet ÖĞMEN"
  echo "${BRIGHT_LINE}Web${NORMAL}   : https://x-shell.codes/scripts/redis"
  echo "${BRIGHT_LINE}Email${NORMAL} : mailto:redis.script@x-shell.codes"
  echo "${BRIGHT_LINE}GitHub${NORMAL}: https://github.com/x-shell-codes/redis"
}

########################################################################################################################
# Help                                                                                                                 #
########################################################################################################################
function Help() {
  echo "MySQL install & configuration script."
  echo
  echo "Options:"
  echo "-p | --password    Redis password."
  echo "-r | --isRemote    Is remote access server? (true/false)."
  echo "-h | --help        Display this help."
  echo "-V | --version     Print software version and exit."
  echo
  echo "For more details see https://github.com/x-shell-codes/redis."
}

########################################################################################################################
# Arguments Parsing                                                                                                    #
########################################################################################################################
isRemote="true"
for i in "$@"; do
  case $i in
  -p=* | --password=*)
    password="${i#*=}"
    shift
    ;;
  -r=* | --isRemote=*)
    isRemote="${i#*=}"

    if [ "$isRemote" != "true" ] && [ "$isRemote" != "false" ]; then
      ErrorLine "Is remote value is invalid."
      Help
      exit
    fi

    shift
    ;;
  -V | --version)
    Version
    exit
    ;;
  -* | --*)
    ErrorLine "Unexpected option: $1"
    echo
    echo "Help:"
    Help
    exit
    ;;
  esac
done

########################################################################################################################
# CheckRootUser Function                                                                                               #
########################################################################################################################
function CheckRootUser() {
  if [ "$(whoami)" != root ]; then
    ErrorLine "You need to run the script as user root or add sudo before command."
    exit 1
  fi
}

########################################################################################################################
# Main Program                                                                                                         #
########################################################################################################################
echo "${POWDER_BLUE_LINE}${BRIGHT_LINE}${REVERSE_LINE}REDIS INSTALLATION${NORMAL_LINE}"

CheckRootUser

export DEBIAN_FRONTEND=noninteractive

apt update

apt install -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y --force-yes redis-server

sed -i '/^supervised no/c\supervised systemd' /etc/redis/redis.conf

if [ ! -z "$password" ]; then
  sed -i "s/\(\# requirepass\|requirepass\).*/requirepass $password/" /etc/redis/redis.conf
fi

if [ "$isRemote" == "true" ]; then
  sed -i "s/\(\^bind\|^bind\).*/bind 0.0.0.0/" /etc/redis/redis.conf
else
  sed -i "s/\(\^bind\|^bind\).*/bind 127.0.0.1/" /etc/redis/redis.conf
fi

systemctl restart redis-server
systemctl enable redis-server

SuccessLine "Redis installation is completed."
