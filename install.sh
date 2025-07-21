

PHANTOMEYE_SCRIPT="phantomeye.sh"
INSTALL_DIR="/usr/local/bin"
COMMAND_NAME="pe"


RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' 

echo -e "${YELLOW}--- Phantomeye Installation Script ---${NC}"


if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Error: This script needs to be run with sudo or as root for system-wide installation.${NC}"
    echo "Please run: sudo ./install.sh"
    exit 1
fi


if [ ! -f "$PHANTOMEYE_SCRIPT" ]; then
    echo -e "${RED}Error: '$PHANTOMEYE_SCRIPT' not found in the current directory.${NC}"
    echo "Please ensure you run this script from the directory containing '$PHANTOMEYE_SCRIPT'."
    exit 1
fi


PACKAGE_MANAGER=""
if command -v apt-get &> /dev/null; then
    PACKAGE_MANAGER="apt-get"
elif command -v dnf &> /dev/null; then
    PACKAGE_MANAGER="dnf"
elif command -v yum &> /dev/null; then
    PACKAGE_MANAGER="yum"
elif command -v pacman &> /dev/null; then
    PACKAGE_MANAGER="pacman"
elif command -v brew &> /dev/null; then
    PACKAGE_MANAGER="brew" 
fi

DEPENDENCIES=("nmap" "curl" "jq" "getopt") 


echo -e "${YELLOW}Checking and installing dependencies...${NC}"
for dep in "${DEPENDENCIES[@]}"; do
    if ! command -v "$dep" &> /dev/null; then
        echo -e "${YELLOW}  '$dep' not found. Attempting to install...${NC}"
        case "$PACKAGE_MANAGER" in
            "apt-get")
                apt-get update && apt-get install -y "$dep"
                ;;
            "dnf"|"yum")
                "$PACKAGE_MANAGER" install -y "$dep"
                ;;
            "pacman")
                pacman -Sy --noconfirm "$dep"
                ;;
            "brew")
                brew install "$dep"
                ;;
            *)
                echo -e "${RED}  Could not determine package manager or '$dep' cannot be installed automatically.${NC}"
                echo -e "${RED}  Please install '$dep' manually.${NC}"
              
                ;;
        esac
        if command -v "$dep" &> /dev/null; then
            echo -e "${GREEN}  '$dep' installed successfully.${NC}"
        else
            echo -e "${RED}  Failed to install '$dep'. Please install it manually and re-run this script.${NC}"
           
        fi
    else
        echo -e "${GREEN}  '$dep' is already installed.${NC}"
    fi
done

echo -e "${YELLOW}Installing Phantomeye script to $INSTALL_DIR/${COMMAND_NAME}...${NC}"

mkdir -p "$INSTALL_DIR"

if cp "$PHANTOMEYE_SCRIPT" "$INSTALL_DIR/$COMMAND_NAME"; then
    echo -e "${GREEN}Successfully copied '$PHANTOMEYE_SCRIPT' to '$INSTALL_DIR/$COMMAND_NAME'.${NC}"
else
    echo -e "${RED}Error: Failed to copy '$PHANTOMEYE_SCRIPT' to '$INSTALL_DIR'.${NC}"
    exit 1
fi

if chmod +x "$INSTALL_DIR/$COMMAND_NAME"; then
    echo -e "${GREEN}Successfully made '$INSTALL_DIR/$COMMAND_NAME' executable.${NC}"
else
    echo -e "${RED}Error: Failed to make '$INSTALL_DIR/$COMMAND_NAME' executable.${NC}"
    exit 1
fi

echo -e "${GREEN}--- Phantomeye installation complete! ---${NC}"
echo -e "${GREEN}You can now run Phantomeye from any directory using the command: ${YELLOW}${COMMAND_NAME}${NC}"
echo "Try running: ${YELLOW}${COMMAND_NAME} -h${NC} for help."