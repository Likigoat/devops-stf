# DevOps Pipeline — Soluciones Tecnológicas del Futuro

> Plataforma automatizada de despliegue y monitoreo en AWS usando prácticas DevOps modernas para el sector financiero.

---

## Descripción del Proyecto

Este repositorio contiene la implementación completa de un flujo de trabajo DevOps en Amazon Web Services (AWS) para **Soluciones Tecnológicas del Futuro**, una empresa de desarrollo de aplicaciones web en el sector financiero.

El proyecto automatiza el ciclo de vida del software mediante:
- Control de versiones con **GitHub**
- Infraestructura como código con **AWS CloudFormation**
- Contenedores con **Docker**
- Pipeline de CI/CD con **AWS CodePipeline** y **GitHub Actions**
- Monitoreo con **AWS CloudWatch**
- Automatización con **Python (Boto3)** y **Bash**

---

## Arquitectura General

```
┌─────────────────────────────────────────────────────────────────┐
│                        PIPELINE CI/CD                          │
│                                                                 │
│  GitHub ──► GitHub Actions ──► AWS CodeBuild ──► EC2/S3       │
│     │                                                   │       │
│     └──── CodePipeline (Source ► Build ► Deploy) ──────┘       │
└─────────────────────────────────────────────────────────────────┘
         │                                          │
         ▼                                          ▼
   CloudFormation                            CloudWatch
   (IaC: EC2, S3,                        (Métricas, Alarmas,
    IAM via LabRole)                          Logs)
```

---

## Estructura del Repositorio

```
devops-stf/
│
├── README.md                    # Este archivo
├── .gitignore                   # Exclusiones de Git
│
├── docs/                        # Documentación técnica
│   ├── arquitectura.md
│   ├── pipeline-cicd.md
│   └── decisiones-tecnicas.md
│
├── infra/                       # Infraestructura como código
│   └── cloudformation/
│       ├── ec2-stack.yaml       # Stack EC2
│       └── s3-stack.yaml        # Stack S3
│
├── docker/                      # Contenedores
│   ├── Dockerfile
│   └── docker-compose.yml
│
├── scripts/                     # Automatización
│   ├── bash/
│   │   ├── setup.sh             # Instalación de dependencias
│   │   └── cleanup-logs.sh      # Limpieza programada de logs
│   └── python/
│       ├── aws_resources.py     # Gestión de recursos AWS con Boto3
│       └── resource_report.py   # Reporte de uso de recursos
│
├── app/                         # Aplicación web (nginx/flask)
│   ├── index.html
│   └── requirements.txt
│
└── .github/
    └── workflows/
        └── ci-cd.yml            # Pipeline GitHub Actions
```

---

## Ramas (Git Flow)

| Rama       | Propósito                                              |
|------------|--------------------------------------------------------|
| `main`     | Código en producción. Protegida, solo merge via PR.    |
| `develop`  | Integración de nuevas funcionalidades.                 |
| `feature/*`| Desarrollo de nuevas características.                  |


### Convención de Commits

```
feat:   Nueva funcionalidad
fix:    Corrección de error
docs:   Cambio en documentación
chore:  Mantenimiento o configuración
test:   Pruebas automatizadas
```

**Ejemplos:**
```bash
git commit -m "feat: agregar script de aprovisionamiento EC2"
git commit -m "fix: corregir permisos en CloudFormation stack"
git commit -m "docs: actualizar README con arquitectura"
```

---

## ⚙️ Tecnologías Utilizadas

| Categoría            | Herramienta                  |
|----------------------|------------------------------|
| Control de versiones | GitHub                       |
| Cloud                | Amazon Web Services (AWS)    |
| IaC                  | AWS CloudFormation           |
| CI/CD                | GitHub Actions, AWS CodePipeline |
| Contenedores         | Docker, Docker Compose       |
| Automatización       | Python 3, Boto3, Bash        |
| Monitoreo            | AWS CloudWatch               |
| Servidor web         | Nginx / Flask                |
| OS                   | Ubuntu 22.04 LTS             |

---

## 🚀 Inicio Rápido

### 1. Clonar el repositorio

```bash
git clone https://github.com/<tu-usuario>/devops-stf.git
cd devops-stf
```

### 2. Configurar entorno local (Linux/Ubuntu)

```bash
chmod +x scripts/bash/setup.sh
./scripts/bash/setup.sh
```

### 3. Configurar credenciales AWS

```bash
aws configure
# Ingresa: Access Key, Secret Key, Region (us-east-1), Output (json)
```

### 4. Desplegar infraestructura con CloudFormation

```bash
aws cloudformation deploy \
  --template-file infra/cloudformation/ec2-stack.yaml \
  --stack-name stf-ec2-stack \
  --capabilities CAPABILITY_NAMED_IAM
```

### 5. Construir y levantar contenedores

```bash
cd docker/
docker-compose up --build -d
```

---

## 📊 Monitoreo con CloudWatch

El proyecto incluye:
- **Métricas de EC2**: CPU, memoria, red.
- **Alarmas**: Notificación cuando CPU > 80%.
- **Logs**: Centralización de logs de aplicación.
- **Dashboards**: Panel de control en tiempo real.

---

## 🔐 Seguridad

- Acceso a AWS mediante rol **LabRole** exclusivamente.
- Ramas `main` y `develop` protegidas (requieren PR aprobado).
- Variables sensibles gestionadas como **GitHub Secrets**.
- Principio de mínimo privilegio en políticas IAM.

---

## 👥 Flujo de Trabajo del Equipo


1. Crear rama feature/fix desde develop
2. Desarrollar y hacer commits con convención
3. Abrir Pull Request hacia develop
4. Revisión de código (code review)
5. Merge a develop → dispara pipeline de CI
6. Merge a main → dispara pipeline de CD (producción)
