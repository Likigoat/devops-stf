#!/bin/bash
# =============================================================
# cleanup-logs.sh
# Proyecto: DevOps STF — Soluciones Tecnológicas del Futuro
# Descripción: Limpieza automática de logs antiguos
# Uso: chmod +x cleanup-logs.sh && ./cleanup-logs.sh
# Cron: 0 2 * * 0 /path/to/cleanup-logs.sh  (cada domingo 2am)
# =============================================================

set -e

# ── Configuración ─────────────────────────────────────────────
LOG_DIR="/var/log/devops-stf"        # Directorio de logs del proyecto
SYSTEM_LOG_DIR="/var/log"            # Logs del sistema
MAX_DAYS=7                           # Eliminar logs más antiguos de 7 días
MAX_SIZE_MB=100                      # Alerta si un log supera este tamaño
REPORT_FILE="/var/log/devops-stf/cleanup-report-$(date +%Y%m%d).log"

# ── Colores ───────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[INFO]${NC}  $1" | tee -a "$REPORT_FILE"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $1" | tee -a "$REPORT_FILE"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1" | tee -a "$REPORT_FILE"; }

# ── Crear directorio de logs si no existe ─────────────────────
mkdir -p "$LOG_DIR"

echo "=============================================="  | tee -a "$REPORT_FILE"
echo "  Limpieza de Logs — $(date '+%Y-%m-%d %H:%M:%S')" | tee -a "$REPORT_FILE"
echo "=============================================="  | tee -a "$REPORT_FILE"

# ── PASO 1: Limpiar logs del proyecto más antiguos de N días ──
log_info "Buscando logs antiguos en $LOG_DIR..."

DELETED_COUNT=0
while IFS= read -r -d '' file; do
  log_info "Eliminando: $file"
  rm -f "$file"
  ((DELETED_COUNT++))
done < <(find "$LOG_DIR" -name "*.log" -mtime +$MAX_DAYS -print0 2>/dev/null)

log_info "Logs eliminados: $DELETED_COUNT archivo(s)."

# ── PASO 2: Comprimir logs de más de 1 día ────────────────────
log_info "Comprimiendo logs de más de 1 día..."

COMPRESSED_COUNT=0
while IFS= read -r -d '' file; do
  gzip -f "$file"
  log_info "Comprimido: $file"
  ((COMPRESSED_COUNT++))
done < <(find "$LOG_DIR" -name "*.log" -mtime +1 -not -name "*.gz" -print0 2>/dev/null)

log_info "Archivos comprimidos: $COMPRESSED_COUNT archivo(s)."

# ── PASO 3: Limpiar archivos .gz de más de 30 días ───────────
log_info "Eliminando archivos comprimidos mayores a 30 días..."

find "$LOG_DIR" -name "*.gz" -mtime +30 -exec rm -f {} \;
log_info "Archivos .gz antiguos eliminados."

# ── PASO 4: Rotar logs del sistema ───────────────────────────
log_info "Ejecutando logrotate del sistema..."
if command -v logrotate &>/dev/null; then
  logrotate /etc/logrotate.conf --force 2>/dev/null || log_warn "logrotate encontró advertencias menores."
  log_info "logrotate ejecutado."
else
  log_warn "logrotate no está instalado."
fi

# ── PASO 5: Verificar logs de gran tamaño ────────────────────
log_info "Verificando logs de gran tamaño (>${MAX_SIZE_MB}MB)..."

while IFS= read -r -d '' file; do
  SIZE_MB=$(du -m "$file" | cut -f1)
  log_warn "Archivo grande detectado: $file (${SIZE_MB}MB)"
done < <(find "$LOG_DIR" "$SYSTEM_LOG_DIR" -name "*.log" -size +${MAX_SIZE_MB}M -print0 2>/dev/null)

# ── PASO 6: Mostrar espacio liberado ─────────────────────────
DISK_USAGE=$(df -h / | awk 'NR==2 {print $4}')
log_info "Espacio disponible en disco: $DISK_USAGE"

# ── Resumen final ─────────────────────────────────────────────
echo "" | tee -a "$REPORT_FILE"
echo "=============================================="  | tee -a "$REPORT_FILE"
log_info "✅ Limpieza completada. Reporte guardado en:"
log_info "   $REPORT_FILE"
echo "=============================================="  | tee -a "$REPORT_FILE"

# ── Instrucciones para programar con cron ────────────────────
# Para ejecutar automáticamente cada domingo a las 2:00 AM:
#
#   sudo crontab -e
#
# Agrega esta línea:
#   0 2 * * 0 /home/ubuntu/devops-stf/scripts/bash/cleanup-logs.sh
#
# Verificar tareas cron activas:
#   sudo crontab -l