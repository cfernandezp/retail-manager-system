# Prompts-Maintainer Agent - Sistema de Mantenimiento Automatizado

> **🤖 Agente IA Especializado en Mantenimiento de Documentación de Prompts**
>
> Mantiene la documentación de prompts sincronizada automáticamente con el código, optimizando tokens y garantizando consistencia.

## 🎯 Propósito

El `prompts-maintainer` es un agente IA especializado diseñado para:

- **Mantener sincronización** automática entre código y documentación de prompts
- **Optimizar consumo de tokens** mediante actualizaciones incrementales
- **Garantizar consistencia** entre todos los documentos de especificaciones
- **Detectar y resolver** inconsistencias proactivamente
- **Automatizar workflows** de mantenimiento de documentación

## 📋 Capacidades Principales

### 🔄 Actualización Automática
- Detecta cambios en código que requieren actualización de prompts
- Aplica updates incrementales preservando estructura existente
- Procesa múltiples tipos de cambios simultáneamente
- Optimiza uso de tokens en cada operación

### 🔍 Validación Cruzada
- Verifica consistencia entre documentos relacionados
- Valida enlaces y referencias cruzadas
- Comprueba sintaxis de ejemplos de código
- Detecta información desactualizada o incorrecta

### ⚡ Triggers Automáticos
- Git hooks para detección de cambios
- File watchers para monitoreo en tiempo real
- Schedulers para tareas de mantenimiento programadas
- Alertas proactivas para problemas críticos

### 📊 Reportes y Métricas
- Dashboard de métricas de performance
- Reportes diarios, semanales y mensuales
- Alertas automáticas para anomalías
- Tracking de ahorro de tokens y eficiencia

## 📁 Estructura del Agente

```
prompts/maintainer/
├── README.md                          # Este archivo
├── prompts-maintainer-agent.md        # Definición completa del agente
├── update-templates.md                # Templates de actualización optimizados
├── triggers-system.md                 # Sistema de detección automática
├── workflows.md                       # Flujos de trabajo automatizados
├── git-hooks/                         # Git hooks para triggers
│   ├── post-commit                    # Detecta cambios post-commit
│   └── pre-push                       # Validación pre-push
├── config/
│   ├── triggers.config.yaml           # Configuración de triggers
│   └── schedule.yaml                  # Tareas programadas
├── scripts/
│   ├── file-watcher.js                # File watcher Node.js
│   ├── health-check.sh                # Health check del sistema
│   └── setup.sh                       # Setup automático
└── logs/
    ├── triggers.log                   # Log de actividad de triggers
    ├── updates.log                    # Log de actualizaciones
    └── errors.log                     # Log de errores
```

## 🚀 Quick Start

### Instalación Rápida
```bash
# 1. Ir al directorio del proyecto
cd retail-manager-system

# 2. Ejecutar setup automático
./prompts/maintainer/scripts/setup.sh

# 3. Iniciar file watcher
npm run watch-prompts

# 4. Verificar instalación
./prompts/maintainer/scripts/health-check.sh
```

### Activación Manual
```bash
# Trigger específico
claude-dev invoke prompts-maintainer \
    --trigger "database_schema_updated" \
    --context "supabase/migrations/20250913_new_table.sql"

# Validación completa
claude-dev invoke prompts-maintainer \
    --action "full_validation"

# Optimización de tokens
claude-dev invoke prompts-maintainer \
    --optimize "all_modules" \
    --target-reduction "40%"
```

## 🔧 Configuración

### Triggers Automáticos
```yaml
# config/triggers.config.yaml
triggers:
  database_schema:
    enabled: true
    priority: CRITICAL
    auto_execute: true
    patterns: ["supabase/migrations/*.sql"]

  error_resolution:
    enabled: true
    priority: CRITICAL
    auto_execute: true
    keywords: ["fix.*error", "resolved.*bug"]
```

### Tareas Programadas
```yaml
# config/schedule.yaml
batch_updates:
  daily:
    time: "02:00"
    tasks: ["validate_consistency", "process_pending_updates"]

  weekly:
    time: "Sunday 03:00"
    tasks: ["full_validation", "optimize_documentation"]
```

## 📊 Métricas de Performance

### KPIs Objetivo
- **Token Savings**: >60% vs regeneración completa
- **Update Time**: <5 min por documento
- **Accuracy**: >95% información correcta
- **Automation**: >80% changes detectados automáticamente

### Métricas Actuales
```
📈 Performance Dashboard
─────────────────────
🔄 Updates Today: 12
💾 Tokens Saved: 847 (73%)
⏱️  Avg Update Time: 3.2 min
✅ Consistency Score: 98%
🚨 Pending Critical: 0
```

## 🎮 Comandos Principales

### Detección y Updates
```bash
# Detectar cambios manualmente
claude-dev invoke prompts-maintainer --detect-changes

# Procesar update específico
claude-dev invoke prompts-maintainer --update "schemas/database-schema.md" --incremental

# Batch update múltiples documentos
claude-dev invoke prompts-maintainer --batch-update "modules/" --priority "HIGH"
```

### Validación y Consistencia
```bash
# Validación completa
claude-dev invoke prompts-maintainer --full-validation

# Check enlaces rotos
claude-dev invoke prompts-maintainer --validate-links

# Verificar ejemplos de código
claude-dev invoke prompts-maintainer --validate-code-examples
```

### Optimización
```bash
# Optimizar todos los módulos
claude-dev invoke prompts-maintainer --optimize-all --target "40%"

# Eliminar redundancias
claude-dev invoke prompts-maintainer --eliminate-redundancy

# Consolidar templates
claude-dev invoke prompts-maintainer --consolidate-templates
```

### Reporting
```bash
# Generar reporte diario
claude-dev invoke prompts-maintainer --daily-report

# Dashboard de métricas
claude-dev invoke prompts-maintainer --metrics-dashboard

# Health check completo
claude-dev invoke prompts-maintainer --health-check
```

## 🔄 Workflows Típicos

### Workflow 1: Cambio en Schema BD
```
1. Developer aplica migración SQL
2. Git post-commit hook detecta cambio
3. Trigger "database_schema_updated"
4. Update automático de schemas/database-schema.md
5. Validación de consistencia
6. Commit de cambios en documentación
7. Notificación a UX/UI Expert
```

### Workflow 2: Error Resuelto
```
1. Developer hace commit con mensaje "fix: error XYZ"
2. Trigger "error_resolved" activado
3. Análisis de cambios en código
4. Update incremental de patterns/error-patterns.md
5. Cross-reference con módulos afectados
6. Validación de solución documentada
```

### Workflow 3: Nuevo Componente UI
```
1. Developer crea nuevo widget Flutter
2. File watcher detecta archivo nuevo
3. Trigger "ui_component_updated"
4. Análisis de component patterns
5. Update de modules/{module}-module.md
6. Extracción de pattern reutilizable si aplica
```

## 🚨 Alertas y Monitoreo

### Alertas Críticas
- **Error Rate >10%**: Pausa auto-updates
- **Pending Critical >3**: Escala a UX/UI Expert
- **Consistency <95%**: Programa validación completa
- **Token Usage Spike >200%**: Revisa optimizaciones

### Health Check
```bash
./scripts/health-check.sh
```

Output:
```
🔍 Prompts Maintainer Health Check
✅ File watcher: RUNNING
✅ Git post-commit hook: INSTALLED
✅ Documentation: CONSISTENT
✅ Documentation freshness: RECENT (2h ago)

📊 Recent Activity:
[2025-09-13 14:30] UPDATE DONE: schemas/database-schema.md - 68% saved
[2025-09-13 14:25] TRIGGER CRITICAL: database_schema_updated
[2025-09-13 12:15] VALIDATION PASSED: full_consistency_check
```

## 🔧 Troubleshooting

### Problema: Updates No Se Ejecutan
```bash
# 1. Verificar file watcher
ps aux | grep file-watcher

# 2. Check git hooks
ls -la .git/hooks/

# 3. Revisar logs
tail -f prompts/maintainer/logs/triggers.log

# 4. Test manual trigger
claude-dev invoke prompts-maintainer --trigger "test"
```

### Problema: Inconsistencias Detectadas
```bash
# 1. Ejecutar validación detallada
claude-dev invoke prompts-maintainer --full-validation --verbose

# 2. Fix automático si es posible
claude-dev invoke prompts-maintainer --auto-fix-inconsistencies

# 3. Reporte de issues
claude-dev invoke prompts-maintainer --inconsistency-report
```

### Problema: Alto Uso de Tokens
```bash
# 1. Analizar uso actual
claude-dev invoke prompts-maintainer --token-analysis

# 2. Ejecutar optimización agresiva
claude-dev invoke prompts-maintainer --optimize-aggressive

# 3. Review de templates
claude-dev invoke prompts-maintainer --review-templates
```

## 📈 Roadmap

### v1.1 (Próximo Release)
- [ ] Machine learning para mejores predicciones de updates
- [ ] Integration con CI/CD pipelines
- [ ] API REST para integration con herramientas externas
- [ ] Templates de prompts más granulares

### v1.2 (Future)
- [ ] Multi-repository support
- [ ] Visual dashboard web interface
- [ ] Advanced analytics y predicciones
- [ ] Integration con sistemas de documentación existentes

## 🤝 Coordinación con Otros Agentes

### Con UX/UI Expert
- **Notificaciones**: Cambios críticos en documentación
- **Escalamiento**: Issues que requieren coordinación multi-agente
- **Reportes**: Status de consistencia de prompts

### Con Agentes Especializados
- **Flutter Expert**: Prompts actualizados con nuevos patterns UI
- **Supabase Expert**: Schemas y APIs sincronizadas
- **Database Expert**: Queries y schemas optimizados

### Integration Points
- Todos los updates críticos notifican a UX/UI Expert
- Issues complejos se escalan para coordinación multi-agente
- Cambios arquitecturales requieren aprobación de UX/UI Expert

---

**El prompts-maintainer está diseñado para operación autónoma con supervisión mínima, maximizando eficiencia y manteniendo la más alta calidad en documentación de prompts.**

## 📞 Support

Para issues, sugerencias o mejoras:
1. Check health-check.sh results
2. Review logs en prompts/maintainer/logs/
3. Ejecutar full-validation para diagnosticar
4. Escalar a UX/UI Expert para coordinación si es necesario

**Status**: ✅ Production Ready
**Version**: 1.0.0
**Last Update**: 2025-09-13