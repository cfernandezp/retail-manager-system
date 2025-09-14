# 🛠️ Configuración del Proyecto - Retail Manager System

Este documento explica las instalaciones y herramientas necesarias para levantar el proyecto **Retail Manager System** con Flutter + Supabase.

## 📋 Requisitos del Sistema

### Sistema Operativo
- **Windows 10/11** (MinGW64)
- **macOS** (Intel/Apple Silicon)
- **Linux** (Ubuntu/Debian recomendado)

## 🔧 Herramientas Principales Instaladas

### 1. Flutter SDK
```bash
# Verificar instalación
flutter --version
flutter doctor
```

**Configuración requerida:**
- Flutter SDK en PATH del sistema
- Android Studio o VS Code con extensiones Flutter/Dart
- Chrome para desarrollo web
- Emulador Android o dispositivo físico para móvil

**Instalación:**
- [Flutter Official Guide](https://docs.flutter.dev/get-started/install)
- Verificar con `flutter doctor` que todo esté configurado

### 2. Supabase CLI
```bash
# Versión instalada: 2.40.7
supabase --version
```

**Instalación:**
```bash
# Windows (con npm)
npm install -g supabase

# macOS/Linux
brew install supabase/tap/supabase
```

**Configuración:**
```bash
# Login a Supabase (requerido)
supabase login

# Inicializar proyecto local
supabase init

# Vincular con proyecto remoto
supabase link --project-ref YOUR_PROJECT_ID
```

### 3. Docker Desktop
```bash
# Versión instalada: 28.4.0
docker --version
```

**Necesario para:**
- Contenedores de PostgreSQL local (Supabase)
- Servicios de desarrollo local
- Edge Functions testing

**Instalación:**
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- Verificar que Docker esté corriendo antes de usar Supabase

### 4. Node.js & NPM
```bash
# Versión instalada: v22.19.0
node --version
npm --version
```

**Necesario para:**
- Supabase CLI
- Herramientas de desarrollo
- Scripts de automatización

### 5. Git
```bash
# Versión instalada: 2.51.0.windows.1
git --version
```

**Configuración:**
```bash
git config --global user.name "Tu Nombre"
git config --global user.email "tu_email@gmail.com"
```

## 🚀 Comandos de Inicialización

### Levantar el Proyecto por Primera Vez

1. **Clonar el repositorio:**
```bash
git clone https://github.com/cfernandezp/retail-manager-system.git
cd retail-manager-system
```

2. **Instalar dependencias Flutter:**
```bash
flutter pub get
```

3. **Iniciar Supabase local:**
```bash
supabase start
```
*Nota: Requiere Docker corriendo*

4. **Ejecutar aplicación Flutter:**
```bash
# Para web
flutter run -d chrome

# Para móvil (con emulador)
flutter run
```

### Comandos de Desarrollo Diario

```bash
# Iniciar servicios Supabase
supabase start

# Ejecutar app en modo desarrollo
flutter run -d chrome --web-port=5000

# Ver logs de Supabase
supabase logs

# Aplicar migraciones de BD
supabase db push

# Parar servicios (preserva datos)
supabase stop
```

## 🔐 Variables de Entorno

Crear archivo `.env` en la raíz del proyecto:
```env
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

## 📱 Configuración Multiplataforma

### Web Development
- **Chrome** - Navegador principal para desarrollo
- **Puerto por defecto:** 5000
- **Hot reload:** Habilitado

### Mobile Development
- **Android Studio** - Para emuladores Android
- **Xcode** - Para simuladores iOS (solo macOS)
- **Dispositivos físicos** - Habilitar modo desarrollador

## 🗄️ Base de Datos

### PostgreSQL (via Supabase)
- **Versión:** 15.x (administrada por Supabase)
- **Acceso local:** puerto 54322
- **Dashboard:** http://localhost:54323

### Esquemas Principales
- `public` - Tablas de la aplicación
- `auth` - Sistema de autenticación
- `storage` - Gestión de archivos

## 🧪 Testing y Desarrollo

### Comandos de Testing
```bash
# Tests unitarios
flutter test

# Tests de integración
flutter test integration_test/

# Análisis de código
flutter analyze
```

### Herramientas de Debug
- **Flutter Inspector** - Para debug de widgets
- **Supabase Dashboard** - Para debug de BD y APIs
- **Chrome DevTools** - Para debug web

## 📚 Documentación Adicional

- [Flutter Documentation](https://docs.flutter.dev/)
- [Supabase Documentation](https://supabase.io/docs)
- [Material Design 3](https://m3.material.io/)
- [CLAUDE.md](./CLAUDE.md) - Guías específicas del proyecto

## 🆘 Solución de Problemas Comunes

### Flutter no encontrado
```bash
# Verificar PATH
echo $PATH  # Unix
echo %PATH% # Windows

# Reinstalar Flutter
flutter doctor
```

### Docker no está corriendo
```bash
# Iniciar Docker Desktop
# Verificar
docker ps
```

### Supabase no conecta
```bash
# Verificar servicios
supabase status

# Reiniciar servicios
supabase stop
supabase start
```

### Problemas de dependencias
```bash
# Limpiar cache
flutter clean
flutter pub get

# Reinstalar dependencias
rm -rf node_modules
npm install
```

## 👨‍💻 Equipo de Desarrollo

Este proyecto utiliza agentes especializados de Claude Code para desarrollo eficiente:
- **flutter-expert** - Desarrollo UI/UX multiplataforma
- **supabase-expert** - Backend y base de datos
- **ux-ui-expert** - Coordinación y diseño de experiencias

---

*Última actualización: Septiembre 2025*
*Proyecto: Sistema de gestión retail especializado en ropa y medias*