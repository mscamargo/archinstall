readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

log() {
	echo -e "${GREEN}[LOG]${NC} $*"
}

error() {
	echo -e "${RED}[ERROR]${NC} $*" >&2
	exit 1
}

warn() {
	echo -e "${YELLOW}[WARN]${NC} $*"
}

info() {
	echo -e "${BLUE}[INFO]${NC} $*"
}
