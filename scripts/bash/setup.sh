#!/bin/bash
# =============================================================
# setup.sh
# Proyecto: DevOps STF — Soluciones Tecnológicas del Futuro
# Descripción: Instalación automática de dependencias en Ubuntu
# Uso: chmod +x setup.sh && ./setup.sh
# =============================================================

set -e  # Detener el script si ocurre algún error

# ── Colores para output ───────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # Sin color

# ── Funciones de utilidad ─────────────────────────────────────
log_info()    { echo -e "${GREEN}[INFO]${NC}  $1"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC}  $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1"; }

# ── Verificar que se ejecuta como root o con sudo ─────────────
if [[ $EUID -ne 0 ]]; then
  log_error "Este script debe ejecutarse con sudo."
  echo "  Uso: sudo ./setup.sh"
  exit 1
fi

echo "=============================================="
echo "  DevOps STF — Configuración del Entorno"
echo "=============================================="
echo ""

# ── PASO 1: Actualizar el sistema ─────────────────────────────
log_info "Actualizando lista de paquetes..."
apt-get update -y
apt-get upgrade -y
log_info "Sistema actualizado."

# ── PASO 2: Instalar herramientas esenciales ──────────────────
log_info "Instalando herramientas esenciales..."
apt-get install -y \
  git \
  vim \
  curl \
  wget \
  unzip \
  build-essential \
  software-properties-common \
  apt-transport-https \
  ca-certificates \
  gnupg \
  lsb-release
log_info "Herramientas esenciales instaladas."

# ── PASO 3: Instalar Python 3 y pip ──────────────────────────
log_info "Instalando Python 3 y pip..."
apt-get install -y python3 python3-pip python3-venv
pip3 install --upgrade pip

# Instalar Boto3 para interacción con AWS
pip3 install boto3 awscli
log_info "Python 3 y Boto3 instalados."

# ── PASO 4: Instalar Docker ───────────────────────────────────
log_info "Instalando Docker..."

# Eliminar versiones antiguas si existen
apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true

# Agregar repositorio oficial de Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
  | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Habilitar Docker al inicio
systemctl enable docker
systemctl start docker

# Agregar usuario actual al grupo docker (para usar sin sudo)
if [ -n "$SUDO_USER" ]; then
  usermod -aG docker "$SUDO_USER"
  log_info "Usuario $SUDO_USER agregado al grupo docker."
fi

log_info "Docker instalado correctamente."

# ── PASO 5: Instalar AWS CLI ──────────────────────────────────
log_info "Instalando AWS CLI v2..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
unzip -o /tmp/awscliv2.zip -d /tmp/
/tmp/aws/install --update
rm -rf /tmp/awscliv2.zip /tmp/aws
log_info "AWS CLI instalada."

# ── PASO 6: Crear estructura de directorios de logs ───────────
log_info "Creando directorios de logs..."
mkdir -p /var/log/devops-stf
chmod 755 /var/log/devops-stf
log_info "Directorio de logs creado en /var/log/devops-stf"

# ── PASO 7: Verificar instalaciones ──────────────────────────
echo ""
echo "=============================================="
echo "  Verificación de instalaciones"
echo "=============================================="
echo ""

check_version() {
  if command -v "$1" &>/dev/null; then
    log_info "$1: $($1 --version 2>&1 | head -n1)"
  else
    log_warn "$1: No encontrado"
  fi
}

check_version git
check_version python3
check_version pip3
check_version docker
check_version aws

echo ""
log_info "✅ Configuración del entorno completada exitosamente."
log_warn "⚠️  Cierra y vuelve a abrir la terminal para aplicar cambios de grupo Docker."
echo ""