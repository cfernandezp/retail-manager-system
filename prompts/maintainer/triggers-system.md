# Sistema de Triggers Automáticos - Prompts Maintainer

## Arquitectura de Detección Automática

> **🎯 Objetivo**: Detectar cambios en código que requieren actualización de prompts sin intervención manual.

## 🔍 Detectores de Cambios

### D1: Database Schema Changes
```yaml
detector_name: "schema_watcher"
priority: "CRITICAL"

monitored_paths:
  - "supabase/migrations/*.sql"
  - "supabase/seed.sql"
  - "supabase/config.toml"

triggers:
  new_migration:
    pattern: "supabase/migrations/[0-9]*_*.sql"
    action: "analyze_schema_changes"
    target_docs:
      - "schemas/database-schema.md"
      - "modules/*-module.md"

  seed_changes:
    pattern: "supabase/seed.sql"
    action: "update_sample_data"
    target_docs:
      - "schemas/database-schema.md"

detection_logic: |
  1. Monitor file system changes in supabase/migrations/
  2. Parse SQL to extract table/field changes
  3. Compare with documented schema
  4. Generate update task if differences found

automation_level: "FULL" # Auto-trigger sin confirmación
```

### D2: Flutter Model Changes
```yaml
detector_name: "model_watcher"
priority: "HIGH"

monitored_paths:
  - "retail_manager/lib/models/*.dart"
  - "retail_manager/lib/repositories/*.dart"

triggers:
  new_model:
    pattern: "retail_manager/lib/models/*.dart"
    action: "document_new_model"
    target_docs:
      - "modules/*-module.md"

  repository_changes:
    pattern: "retail_manager/lib/repositories/*.dart"
    action: "update_api_documentation"
    target_docs:
      - "modules/*-module.md"
      - "schemas/api-contracts.md"

detection_logic: |
  1. Parse Dart AST for class definitions
  2. Extract model properties and methods
  3. Compare with documented models
  4. Identify new fields, methods, validations

automation_level: "SEMI" # Require confirmation for major changes
```

### D3: UI Component Changes
```yaml
detector_name: "component_watcher"
priority: "MEDIUM"

monitored_paths:
  - "retail_manager/lib/widgets/*.dart"
  - "retail_manager/lib/pages/*.dart"
  - "retail_manager/lib/components/*.dart"

triggers:
  new_widget:
    pattern: "retail_manager/lib/widgets/*/*.dart"
    action: "document_ui_component"
    target_docs:
      - "modules/*-module.md"
      - "patterns/ui-patterns.md"

  responsive_changes:
    pattern: "retail_manager/lib/**/responsive_*.dart"
    action: "update_responsive_patterns"
    target_docs:
      - "patterns/ui-patterns.md"

detection_logic: |
  1. Parse Dart files for StatelessWidget/StatefulWidget
  2. Extract component properties and usage patterns
  3. Identify responsive breakpoint usage
  4. Document reusable patterns

automation_level: "MANUAL" # Only suggest, require manual review
```

### D4: Error Pattern Detection
```yaml
detector_name: "error_watcher"
priority: "CRITICAL"

monitored_sources:
  - "git commit messages with 'fix:' 'error:' 'bug:'"
  - "exception handling code changes"
  - "validation error messages"

triggers:
  new_error_resolved:
    pattern: "commit message contains 'fix: error' or 'resolved: bug'"
    action: "extract_error_solution"
    target_docs:
      - "patterns/error-patterns.md"

  validation_added:
    pattern: "new validator functions or error messages"
    action: "document_validation_pattern"
    target_docs:
      - "patterns/error-patterns.md"
      - "modules/*-module.md"

detection_logic: |
  1. Parse git commit messages for error-related keywords
  2. Analyze code diff for try-catch blocks, validators
  3. Extract error messages and solutions
  4. Categorize by error type (DB, UI, Auth, etc.)

automation_level: "SEMI" # Auto-detect, manual review for accuracy
```

## ⚡ Implementación de Triggers

### Git Hooks Integration

#### post-commit Hook
```bash
#!/bin/sh
# .git/hooks/post-commit
# Trigger automático después de cada commit

CHANGED_FILES=$(git diff-tree --no-commit-id --name-only -r HEAD)
COMMIT_MESSAGE=$(git log -1 --pretty=%B)

# Configurar Claude Code environment
export CLAUDE_PROJECT_ROOT="$(git rev-parse --show-toplevel)"
export PROMPTS_DIR="$CLAUDE_PROJECT_ROOT/prompts"

echo "🔍 Analyzing changes for prompt updates..."

# D1: Database Schema Changes
if echo "$CHANGED_FILES" | grep -q "supabase/migrations/"; then
    echo "📊 Database schema changes detected"

    MIGRATION_FILES=$(echo "$CHANGED_FILES" | grep "supabase/migrations/")

    claude-dev invoke prompts-maintainer \
        --trigger "database_schema_updated" \
        --context "files:$MIGRATION_FILES" \
        --priority "CRITICAL"
fi

# D2: Model Changes
if echo "$CHANGED_FILES" | grep -q "retail_manager/lib/models/"; then
    echo "🏗️  Model changes detected"

    MODEL_FILES=$(echo "$CHANGED_FILES" | grep "retail_manager/lib/models/")

    claude-dev invoke prompts-maintainer \
        --trigger "model_updated" \
        --context "files:$MODEL_FILES" \
        --priority "HIGH"
fi

# D3: Repository Changes
if echo "$CHANGED_FILES" | grep -q "retail_manager/lib/repositories/"; then
    echo "🔄 Repository changes detected"

    REPO_FILES=$(echo "$CHANGED_FILES" | grep "retail_manager/lib/repositories/")

    claude-dev invoke prompts-maintainer \
        --trigger "repository_updated" \
        --context "files:$REPO_FILES" \
        --priority "HIGH"
fi

# D4: Error Resolution Detection
if echo "$COMMIT_MESSAGE" | grep -iE "(fix|solved|resolved).*(error|bug|issue)"; then
    echo "🐛 Error resolution detected in commit message"

    claude-dev invoke prompts-maintainer \
        --trigger "error_resolved" \
        --context "commit:$(git rev-parse HEAD)" \
        --context "message:$COMMIT_MESSAGE" \
        --priority "CRITICAL"
fi

# UI Component Changes
if echo "$CHANGED_FILES" | grep -qE "retail_manager/lib/(widgets|pages|components)/"; then
    echo "🎨 UI component changes detected"

    UI_FILES=$(echo "$CHANGED_FILES" | grep -E "retail_manager/lib/(widgets|pages|components)/")

    claude-dev invoke prompts-maintainer \
        --trigger "ui_component_updated" \
        --context "files:$UI_FILES" \
        --priority "MEDIUM"
fi

echo "✅ Prompt update analysis completed"
```

#### pre-push Hook
```bash
#!/bin/sh
# .git/hooks/pre-push
# Validación antes de push para asegurar consistencia

echo "🔍 Running prompt consistency validation..."

# Validar que no hay referencias rotas
claude-dev invoke prompts-maintainer \
    --action "validate_consistency" \
    --blocking

VALIDATION_RESULT=$?

if [ $VALIDATION_RESULT -ne 0 ]; then
    echo "❌ Prompt validation failed. Fix issues before pushing."
    echo "Run: claude-dev invoke prompts-maintainer --action full_validation"
    exit 1
fi

echo "✅ Prompt validation passed"
```

### File Watcher (Alternative to Git Hooks)

#### Node.js File Watcher
```javascript
// prompts/maintainer/file-watcher.js
const chokidar = require('chokidar');
const { execSync } = require('child_process');

const watchers = {
  // Database Schema Watcher
  'supabase/migrations/**/*.sql': {
    priority: 'CRITICAL',
    trigger: 'database_schema_updated',
    debounce: 2000 // 2 seconds delay to avoid multiple triggers
  },

  // Models Watcher
  'retail_manager/lib/models/**/*.dart': {
    priority: 'HIGH',
    trigger: 'model_updated',
    debounce: 1000
  },

  // Repository Watcher
  'retail_manager/lib/repositories/**/*.dart': {
    priority: 'HIGH',
    trigger: 'repository_updated',
    debounce: 1000
  },

  // UI Components Watcher
  'retail_manager/lib/{widgets,pages,components}/**/*.dart': {
    priority: 'MEDIUM',
    trigger: 'ui_component_updated',
    debounce: 3000
  }
};

// Setup watchers
Object.entries(watchers).forEach(([pattern, config]) => {
  const watcher = chokidar.watch(pattern, {
    ignored: /node_modules/,
    persistent: true
  });

  let debounceTimer = null;

  watcher.on('change', (path) => {
    console.log(`📝 File changed: ${path}`);

    // Debounce multiple rapid changes
    clearTimeout(debounceTimer);
    debounceTimer = setTimeout(() => {
      console.log(`🔄 Triggering ${config.trigger} for ${path}`);

      try {
        execSync(`claude-dev invoke prompts-maintainer --trigger "${config.trigger}" --context "file:${path}" --priority "${config.priority}"`, {
          stdio: 'inherit'
        });
      } catch (error) {
        console.error(`❌ Failed to trigger prompts-maintainer: ${error.message}`);
      }
    }, config.debounce);
  });

  watcher.on('add', (path) => {
    console.log(`➕ New file: ${path}`);
    // Handle new files similarly to changes
  });

  console.log(`👀 Watching ${pattern} with ${config.priority} priority`);
});

console.log('🎯 Prompts Maintainer file watcher started');
console.log('Press Ctrl+C to stop');

// Graceful shutdown
process.on('SIGINT', () => {
  console.log('\n👋 Shutting down file watcher...');
  process.exit(0);
});
```

#### Package.json Script
```json
{
  "scripts": {
    "watch-prompts": "node prompts/maintainer/file-watcher.js",
    "start-dev": "concurrently \"npm run watch-prompts\" \"flutter run -d chrome --web-port=8000\""
  },
  "devDependencies": {
    "chokidar": "^3.5.3",
    "concurrently": "^8.2.0"
  }
}
```

## 🎯 Configuración de Triggers

### Configuration File
```yaml
# prompts/maintainer/triggers.config.yaml
system:
  enabled: true
  log_level: "INFO"
  max_concurrent_updates: 3
  cooldown_period: 300 # 5 minutes between batch updates

triggers:
  database_schema:
    enabled: true
    priority: "CRITICAL"
    auto_execute: true
    patterns:
      - "supabase/migrations/*.sql"
      - "supabase/seed.sql"
    target_documents:
      - "schemas/database-schema.md"
      - "modules/*-module.md"

  model_changes:
    enabled: true
    priority: "HIGH"
    auto_execute: false # Require manual confirmation
    patterns:
      - "retail_manager/lib/models/*.dart"
    target_documents:
      - "modules/*-module.md"

  repository_changes:
    enabled: true
    priority: "HIGH"
    auto_execute: false
    patterns:
      - "retail_manager/lib/repositories/*.dart"
    target_documents:
      - "modules/*-module.md"
      - "schemas/api-contracts.md"

  error_resolution:
    enabled: true
    priority: "CRITICAL"
    auto_execute: true
    patterns:
      - "git_commit_message"
    keywords:
      - "fix.*error"
      - "resolved.*bug"
      - "solved.*issue"
    target_documents:
      - "patterns/error-patterns.md"

  ui_components:
    enabled: true
    priority: "MEDIUM"
    auto_execute: false
    patterns:
      - "retail_manager/lib/widgets/*.dart"
      - "retail_manager/lib/pages/*.dart"
      - "retail_manager/lib/components/*.dart"
    target_documents:
      - "modules/*-module.md"
      - "patterns/ui-patterns.md"

blacklist:
  files:
    - "**/*.g.dart" # Generated files
    - "**/*.freezed.dart" # Generated files
    - "**/test/**" # Test files
    - "**/.dart_tool/**" # Build artifacts
```

### Trigger Priority Matrix
```yaml
priority_matrix:
  CRITICAL:
    - database_schema_changes
    - error_resolutions
    - security_updates
    execute: "IMMEDIATE"
    notification: "REAL_TIME"

  HIGH:
    - model_updates
    - repository_changes
    - api_contract_changes
    execute: "WITHIN_1_HOUR"
    notification: "HOURLY_BATCH"

  MEDIUM:
    - ui_component_updates
    - pattern_changes
    execute: "DAILY_BATCH"
    notification: "DAILY_SUMMARY"

  LOW:
    - comment_updates
    - example_improvements
    execute: "WEEKLY_BATCH"
    notification: "WEEKLY_SUMMARY"
```

## 📊 Monitoring y Alertas

### Log System
```yaml
logging:
  level: "INFO"
  output: "prompts/maintainer/logs/triggers.log"
  rotation: "daily"
  retention: "30 days"

  formats:
    trigger_detected: "[{timestamp}] TRIGGER {priority}: {trigger_type} - {context}"
    update_started: "[{timestamp}] UPDATE START: {document} - {change_type}"
    update_completed: "[{timestamp}] UPDATE DONE: {document} - {token_savings}% saved"
    error_occurred: "[{timestamp}] ERROR: {error_type} - {message}"
```

### Dashboard Metrics
```yaml
metrics:
  triggers_today: "count"
  documents_updated_today: "count"
  token_savings_today: "percentage"
  error_rate: "percentage"
  avg_update_time: "seconds"
  pending_updates: "list"

alerts:
  high_error_rate:
    threshold: ">10% errors in 1 hour"
    action: "notify_admin"

  pending_critical:
    threshold: ">3 critical updates pending >1 hour"
    action: "escalate_to_ux_ui"

  token_usage_spike:
    threshold: ">200% normal token usage"
    action: "pause_auto_updates"
```

### Health Checks
```bash
#!/bin/bash
# prompts/maintainer/health-check.sh

echo "🔍 Prompts Maintainer Health Check"

# Check if file watcher is running
if pgrep -f "file-watcher.js" > /dev/null; then
    echo "✅ File watcher: RUNNING"
else
    echo "❌ File watcher: STOPPED"
fi

# Check git hooks
if [ -x ".git/hooks/post-commit" ]; then
    echo "✅ Git post-commit hook: INSTALLED"
else
    echo "❌ Git post-commit hook: MISSING"
fi

# Check documentation consistency
BROKEN_LINKS=$(find prompts/ -name "*.md" -exec grep -l "BROKEN\|TODO\|FIXME" {} \;)
if [ -z "$BROKEN_LINKS" ]; then
    echo "✅ Documentation: CONSISTENT"
else
    echo "⚠️  Documentation: HAS ISSUES"
    echo "   Files with issues: $BROKEN_LINKS"
fi

# Check last update times
LAST_UPDATE=$(find prompts/ -name "*.md" -printf "%T@ %p\n" | sort -n | tail -1 | awk '{print $2}')
LAST_UPDATE_AGE=$(echo "$(date +%s) - $(stat -c %Y "$LAST_UPDATE")" | bc)

if [ $LAST_UPDATE_AGE -lt 86400 ]; then # 24 hours
    echo "✅ Documentation freshness: RECENT ($(($LAST_UPDATE_AGE/3600))h ago)"
else
    echo "⚠️  Documentation freshness: STALE ($(($LAST_UPDATE_AGE/86400)) days ago)"
fi

echo ""
echo "📊 Recent Activity:"
tail -5 prompts/maintainer/logs/triggers.log 2>/dev/null || echo "   No recent activity logs found"
```

## 🚀 Activación del Sistema

### Manual Setup
```bash
# 1. Install dependencies
cd prompts/maintainer
npm install chokidar concurrently

# 2. Setup git hooks
cp git-hooks/post-commit .git/hooks/
cp git-hooks/pre-push .git/hooks/
chmod +x .git/hooks/post-commit .git/hooks/pre-push

# 3. Start file watcher
npm run watch-prompts

# 4. Verify setup
./health-check.sh
```

### Integration with Development Workflow
```bash
# Start development with prompt watching
npm run start-dev

# Manual trigger for testing
claude-dev invoke prompts-maintainer --trigger "test" --context "manual_test"

# Full validation before important commits
claude-dev invoke prompts-maintainer --action "full_validation"
```

---

**El sistema de triggers está listo para detección automática de cambios y actualización proactiva de prompts.**