# =============================================================
# Dockerfile
# Proyecto: DevOps STF — Soluciones Tecnológicas del Futuro
# Descripción: Imagen Docker para aplicación web Flask
# Multi-stage build para optimizar el tamaño de la imagen
# =============================================================

# ── STAGE 1: Builder ─────────────────────────────────────────
# Instala dependencias y prepara el entorno
FROM python:3.11-slim AS builder

# Directorio de trabajo
WORKDIR /app

# Copiar solo el archivo de dependencias primero
# (aprovecha el cache de Docker si no cambian)
COPY app/requirements.txt .

# Instalar dependencias en una carpeta local
RUN pip install --upgrade pip && \
    pip install --prefix=/install --no-cache-dir -r requirements.txt


# ── STAGE 2: Production ──────────────────────────────────────
# Imagen final limpia y optimizada
FROM python:3.11-slim AS production

# Metadatos de la imagen
LABEL maintainer="DevOps STF"
LABEL version="1.0"
LABEL description="Aplicación web Flask - Soluciones Tecnológicas del Futuro"

# Variables de entorno
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    FLASK_ENV=production \
    FLASK_APP=app.py \
    PORT=5000

# Crear usuario no root por seguridad
RUN addgroup --system appgroup && \
    adduser --system --ingroup appgroup appuser

# Directorio de trabajo
WORKDIR /app

# Copiar dependencias instaladas desde el builder
COPY --from=builder /install /usr/local

# Copiar el código de la aplicación
COPY app/ .

# Cambiar propietario de los archivos al usuario no root
RUN chown -R appuser:appgroup /app

# Usar usuario no root
USER appuser

# Exponer el puerto de Flask
EXPOSE 5000

# Comando para iniciar la aplicación
CMD ["python", "-m", "flask", "run", "--host=0.0.0.0", "--port=5000"]