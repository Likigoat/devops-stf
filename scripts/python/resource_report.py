#!/usr/bin/env python3
# =============================================================
# aws_resources.py
# Proyecto: DevOps STF — Soluciones Tecnológicas del Futuro
# Descripción: Gestión y listado de recursos AWS con Boto3
# Uso: python3 aws_resources.py
# =============================================================

import boto3
import json
from datetime import datetime
from botocore.exceptions import ClientError, NoCredentialsError

# ── Configuración ─────────────────────────────────────────────
REGION = "us-east-1"

# ── Colores para output en terminal ──────────────────────────
GREEN  = "\033[0;32m"
YELLOW = "\033[1;33m"
RED    = "\033[0;31m"
BLUE   = "\033[0;34m"
NC     = "\033[0m"

def log_info(msg):  print(f"{GREEN}[INFO]{NC}  {msg}")
def log_warn(msg):  print(f"{YELLOW}[WARN]{NC}  {msg}")
def log_error(msg): print(f"{RED}[ERROR]{NC} {msg}")
def log_title(msg): print(f"\n{BLUE}{'='*50}{NC}\n  {msg}\n{BLUE}{'='*50}{NC}")


# ── FUNCIÓN 1: Listar todos los buckets S3 ───────────────────
def listar_buckets(s3_client):
    log_title("Buckets S3 disponibles")

    try:
        response = s3_client.list_buckets()
        buckets = response.get("Buckets", [])

        if not buckets:
            log_warn("No se encontraron buckets S3.")
            return []

        log_info(f"Total de buckets encontrados: {len(buckets)}")
        print("")

        for bucket in buckets:
            nombre = bucket["Name"]
            fecha  = bucket["CreationDate"].strftime("%Y-%m-%d %H:%M:%S")
            print(f"  🪣  {nombre}  (creado: {fecha})")

        return [b["Name"] for b in buckets]

    except ClientError as e:
        log_error(f"Error al listar buckets: {e}")
        return []


# ── FUNCIÓN 2: Listar objetos dentro de un bucket ────────────
def listar_objetos_bucket(s3_client, bucket_name):
    log_title(f"Objetos en bucket: {bucket_name}")

    try:
        response = s3_client.list_objects_v2(Bucket=bucket_name)
        objetos  = response.get("Contents", [])

        if not objetos:
            log_warn(f"El bucket '{bucket_name}' está vacío.")
            return

        log_info(f"Total de objetos: {len(objetos)}")
        print("")

        for obj in objetos:
            nombre = obj["Key"]
            tamano = obj["Size"]
            fecha  = obj["LastModified"].strftime("%Y-%m-%d %H:%M:%S")
            tamano_kb = round(tamano / 1024, 2)
            print(f"  📄  {nombre}  ({tamano_kb} KB)  — Modificado: {fecha}")

    except ClientError as e:
        log_error(f"Error al listar objetos de '{bucket_name}': {e}")


# ── FUNCIÓN 3: Listar instancias EC2 ─────────────────────────
def listar_instancias_ec2(ec2_client):
    log_title("Instancias EC2")

    try:
        response   = ec2_client.describe_instances()
        reservas   = response.get("Reservations", [])
        instancias = [i for r in reservas for i in r.get("Instances", [])]

        if not instancias:
            log_warn("No se encontraron instancias EC2.")
            return

        log_info(f"Total de instancias encontradas: {len(instancias)}")
        print("")

        for inst in instancias:
            inst_id = inst.get("InstanceId", "N/A")
            tipo    = inst.get("InstanceType", "N/A")
            estado  = inst.get("State", {}).get("Name", "N/A")
            az      = inst.get("Placement", {}).get("AvailabilityZone", "N/A")

            # Obtener nombre del tag si existe
            tags   = inst.get("Tags", [])
            nombre = next((t["Value"] for t in tags if t["Key"] == "Name"), "Sin nombre")

            estado_icon = "🟢" if estado == "running" else "🔴" if estado == "stopped" else "🟡"
            print(f"  {estado_icon}  {inst_id}  |  {nombre}  |  {tipo}  |  {estado}  |  {az}")

    except ClientError as e:
        log_error(f"Error al listar instancias EC2: {e}")


# ── FUNCIÓN 4: Verificar conexión con AWS ────────────────────
def verificar_conexion():
    try:
        sts = boto3.client("sts", region_name=REGION)
        identidad = sts.get_caller_identity()
        log_info(f"Conectado como: {identidad.get('Arn')}")
        log_info(f"Cuenta AWS:     {identidad.get('Account')}")
        return True
    except NoCredentialsError:
        log_error("No se encontraron credenciales AWS.")
        log_error("Ejecuta: aws configure")
        return False
    except ClientError as e:
        log_error(f"Error de conexión: {e}")
        return False


# ── MAIN ──────────────────────────────────────────────────────
def main():
    print("")
    print("=" * 50)
    print("  DevOps STF — Gestión de Recursos AWS")
    print(f"  Fecha: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 50)

    # Verificar conexión
    log_title("Verificando conexión con AWS")
    if not verificar_conexion():
        return

    # Crear clientes AWS
    s3_client  = boto3.client("s3",  region_name=REGION)
    ec2_client = boto3.client("ec2", region_name=REGION)

    # Listar buckets S3
    buckets = listar_buckets(s3_client)

    # Listar objetos del primer bucket encontrado (si existe)
    if buckets:
        listar_objetos_bucket(s3_client, buckets[0])

    # Listar instancias EC2
    listar_instancias_ec2(ec2_client)

    print("")
    log_info("✅ Consulta de recursos completada.")
    print("")


if __name__ == "__main__":
    main()