# 🧪 TEST PLAN MVP1 - Módulo Productos Multi-Tienda

## 📋 **Resumen Ejecutivo**

**Proyecto**: Sistema Retail Medias Multi-Tienda  
**Módulo**: Productos Master + Inventario Multi-Tienda  
**Fase**: MVP1 Testing Strategy  
**QA Engineer**: Claude QA Senior  
**Fecha**: 2025-09-11  

## 🎯 **Objetivos de Testing**

### **Funcionales**
- ✅ CRUD productos completo con validaciones
- ✅ Multi-tienda con stock independiente por tienda
- ✅ RLS funcionando correctamente por rol (SUPER_ADMIN, ADMIN_TIENDA, VENDEDOR)
- ✅ Realtime updates instantáneos entre usuarios
- ✅ SKU auto-generation único y consistente
- ✅ Búsquedas y filtros < 500ms
- ✅ Paginación y lazy loading funcional

### **No-Funcionales**
- ✅ Performance web < 2s load inicial
- ✅ Responsive design ≥1200px optimizado
- ✅ Accessibility WCAG-AA compliance
- ✅ Security: RLS + input validation
- ✅ Concurrencia: 50+ usuarios simultáneos
- ✅ Data integrity: transacciones ACID

## 🏗️ **Arquitectura de Testing**

### **Testing Pyramid Structure**

```
    🔺 E2E Tests (10%)
   🔻🔻 Integration Tests (30%) 
  🔻🔻🔻 Unit Tests (60%)
```

### **Test Environment Setup**

```yaml
Environments:
  - Local: Flutter + Supabase local
  - Staging: Supabase Cloud + Flutter Web
  - Production: Testing readonly replica

Tools:
  - Flutter Test Framework
  - Mockito for mocking
  - Flutter Driver for E2E
  - Supabase Test Database
  - GitHub Actions CI/CD
```

## 🧪 **1. UNIT TESTS (60% Coverage Target)**

### **1.1 Model Tests**
**File**: `test/data/models/product_models_test.dart`

```dart
// Tests para modelos de datos
- ProductoMaster.fromJson() / toJson()
- CatalogoCompleto.fromJson() con datos complejos
- ProductFilters.copyWith() y hasFilters
- PaginationParams offset calculations
- Articulo SKU validation
- InventarioTienda calculations
```

### **1.2 Repository Tests**
**File**: `test/data/repositories/products_repository_test.dart`

```dart
// Mock Supabase responses
- getCatalogoCompleto() with filters
- createProductoMaster() success/error
- updateInventarioTienda() stock calculations
- subscribeToProductsChanges() realtime
- Error handling and retries
- Data transformation accuracy
```

### **1.3 BLoC Tests**
**File**: `test/presentation/bloc/products_bloc_test.dart`

```dart
// State management logic
- LoadProducts: initial → loading → loaded
- SearchProducts: query handling + debouncing
- CreateProduct: validation → creating → created
- FilterProducts: multiple filter combinations
- LoadMoreProducts: pagination logic
- RealTime updates: INSERT/UPDATE/DELETE
- Error states handling
```

### **1.4 Utility Functions Tests**
**File**: `test/core/utils/utils_test.dart`

```dart
// Helper functions
- SKU generation uniqueness
- Price formatting (Peruvian Sol)
- Date formatting and parsing
- Validation rules (DNI, RUC, phone)
- Text search utilities
```

## 🔗 **2. INTEGRATION TESTS (30% Coverage Target)**

### **2.1 Database Integration Tests**
**File**: `test/integration/database_test.dart`

```dart
// Real Supabase database tests
- Schema validation and constraints
- RLS policies by role testing
- Triggers funcionando (SKU auto-gen)
- Edge Functions execution
- Transaction rollback scenarios
- Performance queries < 100ms
```

### **2.2 API Integration Tests**  
**File**: `test/integration/api_integration_test.dart`

```dart
// End-to-end API workflows
- Full product creation workflow
- Multi-store inventory management
- User role permission validation
- Realtime subscription functionality
- Error handling and recovery
- Rate limiting and throttling
```

### **2.3 Flutter-Supabase Integration**
**File**: `test/integration/flutter_supabase_test.dart`

```dart
// Flutter + Supabase connectivity
- Authentication flows by role
- Real-time data synchronization
- Offline capability with Hive
- Network error resilience
- Data consistency checks
```

## 🌐 **3. WIDGET TESTS (Flutter Components)**

### **3.1 Core Components Tests**
**File**: `test/presentation/components/`

```dart
// Individual widget testing
- ProductMasterCard display and actions
- ProductFiltersPanel functionality
- CreateProductWizard step navigation
- ProductSearchBar debouncing
- PaginationControls navigation
- LoadingStates animations
```

### **3.2 Page Tests**
**File**: `test/presentation/pages/`

```dart
// Full page widget testing  
- ProductsPage: list, search, filter
- CreateProductPage: wizard flow
- ProductDetailsPage: info display
- Responsive layout adaptations
- Navigation and routing
```

## 🎭 **4. END-TO-END TESTS (10% Coverage Target)**

### **4.1 Critical User Flows**
**File**: `test/e2e/critical_flows_test.dart`

#### **Flow 1: Crear Producto (SUPER_ADMIN)**
```gherkin
Scenario: Super Admin crea producto nuevo
  Given que soy SUPER_ADMIN autenticado
  When navego a /products
  And hago clic en "Crear Producto"
  And completo el wizard en 3 pasos:
    | Paso 1: Información básica |
    | Paso 2: Colores y variantes |
    | Paso 3: Inventario inicial |
  And envío el formulario
  Then el producto se crea exitosamente
  And aparece en la lista con SKU auto-generado
  And el realtime notifica a otros usuarios
  And el inventario se configura en todas las tiendas
```

#### **Flow 2: Gestión Inventario (ADMIN_TIENDA)**
```gherkin
Scenario: Admin tienda gestiona inventario local
  Given que soy ADMIN_TIENDA de "Gamarra"
  When accedo a /products
  Then veo solo productos de mi tienda
  When actualizo stock de "Media Arley 9-12 Azul"
  And cambio precio local
  Then los cambios se guardan inmediatamente
  And otros usuarios ven updates en tiempo real
  And el historial de movimientos se registra
```

#### **Flow 3: Búsqueda POS (VENDEDOR)**
```gherkin
Scenario: Vendedor busca producto para venta
  Given que soy VENDEDOR en tienda "Mesa Redonda"
  When accedo a /products  
  And busco "Arley 9-12"
  Then veo resultados en < 500ms
  And solo veo stock de mi tienda
  And puedo ver precios locales actualizados
  When selecciono un producto
  Then veo stock actual disponible
```

### **4.2 Cross-Browser Testing**
**File**: `test/e2e/cross_browser_test.dart`

```dart
// Multi-browser compatibility
- Chrome (primary target)
- Firefox compatibility
- Edge compatibility  
- Safari basic testing
- Mobile browser responsiveness
```

### **4.3 Performance E2E Tests**
**File**: `test/e2e/performance_test.dart`

```dart
// Load and performance testing
- Initial page load < 2s
- Search response < 500ms
- Infinite scroll smoothness
- Memory usage monitoring
- Network request optimization
```

## 🔒 **5. SECURITY TESTS**

### **5.1 RLS Security Tests**
**File**: `test/security/rls_security_test.dart`

```dart
// Row Level Security validation
- SUPER_ADMIN: acceso total confirmado
- ADMIN_TIENDA: solo su tienda
- VENDEDOR: solo lectura su tienda
- Cross-tenant data isolation
- SQL injection prevention
- Authentication bypass attempts
```

### **5.2 Input Validation Tests**
**File**: `test/security/input_validation_test.dart`

```dart
// Frontend + Backend validation
- XSS prevention in text inputs
- SQL injection in search queries
- File upload restrictions
- Price manipulation attempts
- SKU uniqueness enforcement
- JSON payload validation
```

## 📊 **6. PERFORMANCE TESTS**

### **6.1 Load Testing**
**File**: `test/performance/load_test.dart`

```dart
// Concurrent user simulation
- 50 usuarios simultáneos
- 100 productos creados por minuto
- 1000 búsquedas por segundo
- Realtime updates a 100 usuarios
- Database connection pooling
- Memory leak detection
```

### **6.2 Database Performance**
**File**: `test/performance/db_performance_test.dart`

```sql
-- Query performance validation
- vw_catalogo_completo < 100ms
- Búsqueda con filtros < 200ms
- Inserción producto < 50ms
- Update inventario < 30ms
- Bulk operations < 1s
- Index usage verification
```

## 🌍 **7. ACCESSIBILITY TESTS**

### **7.1 WCAG Compliance Tests**
**File**: `test/accessibility/wcag_test.dart`

```dart
// WCAG 2.1 AA compliance
- Keyboard navigation complete
- Screen reader compatibility
- Color contrast ratios ≥4.5:1
- Focus management
- ARIA labels correctos
- Alt text for images
- Form label associations
```

### **7.2 Responsive Design Tests**
**File**: `test/accessibility/responsive_test.dart`

```dart
// Multi-device compatibility
- Desktop: 1920x1080, 1366x768
- Tablet: 768x1024, 1024x768
- Mobile: 375x667, 414x896
- Ultra-wide: 2560x1440
- Sidebar collapse/expand
- Touch target sizes ≥44px
```

## 📱 **8. REALTIME FUNCTIONALITY TESTS**

### **8.1 Realtime Sync Tests**
**File**: `test/realtime/sync_test.dart`

```dart
// Supabase Realtime testing
- Multiple clients simultaneously
- Product creation propagation
- Inventory update synchronization
- Connection loss recovery
- Offline queue management
- Conflict resolution
```

### **8.2 Multi-User Scenarios**
**File**: `test/realtime/multi_user_test.dart`

```dart
// Concurrent user interactions
- Admin crea producto → Vendedores lo ven
- Inventario actualizado → POS se actualiza
- Producto eliminado → Desaparece en tiempo real
- Role changes → Permisos actualizados
- Store assignment changes
```

## 🔧 **9. TEST AUTOMATION & CI/CD**

### **9.1 GitHub Actions Workflow**
**File**: `.github/workflows/testing.yml`

```yaml
name: MVP1 Testing Pipeline

on: [push, pull_request]

jobs:
  unit-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter test --coverage
      - uses: codecov/codecov-action@v3

  integration-tests:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: postgres
    steps:
      - name: Setup Supabase
      - name: Run integration tests
      - name: Performance benchmarks

  e2e-tests:
    runs-on: ubuntu-latest
    steps:
      - name: Setup Chrome
      - name: Run E2E tests
      - name: Upload test artifacts
```

### **9.2 Test Data Management**
**File**: `test/fixtures/test_data.dart`

```dart
// Consistent test data
class TestData {
  static const superAdminUser = {...};
  static const adminTiendaUser = {...};
  static const vendedorUser = {...};
  
  static const sampleProducts = [...];
  static const sampleInventory = [...];
  static const testStores = [...];
}
```

## 📈 **10. TEST METRICS & REPORTING**

### **10.1 Coverage Requirements**
```yaml
Coverage Targets:
  - Unit Tests: ≥90%
  - Integration Tests: ≥80%
  - Critical Paths: 100%
  - RLS Policies: 100%
  - Error Handling: ≥85%
```

### **10.2 Performance Benchmarks**
```yaml
Performance SLAs:
  - Page Load: <2s (95th percentile)
  - Search Response: <500ms (99th percentile)
  - Database Queries: <100ms (average)
  - Realtime Updates: <200ms (delivery)
  - Memory Usage: <100MB (Flutter web)
```

### **10.3 Test Reporting**
```yaml
Reports Generated:
  - JUnit XML for CI/CD
  - Coverage reports (lcov)
  - Performance metrics (JSON)
  - Security scan results
  - Accessibility audit reports
  - Manual test execution logs
```

## 🚨 **11. RISK MATRIX & MITIGATION**

### **High Risk Areas**
| Risk | Impact | Probability | Mitigation |
|------|---------|-------------|------------|
| RLS Policy Bypass | HIGH | LOW | Comprehensive RLS testing + pentesting |
| Data Loss in Multi-Tienda | HIGH | MEDIUM | Transaction testing + backup validation |
| Performance Degradation | MEDIUM | HIGH | Load testing + monitoring setup |
| Realtime Sync Failure | HIGH | MEDIUM | Offline capability + sync recovery tests |
| SKU Collision | MEDIUM | LOW | Uniqueness testing + generation algorithm review |

### **Medium Risk Areas**
| Risk | Impact | Probability | Mitigation |
|------|---------|-------------|------------|
| Browser Compatibility | MEDIUM | MEDIUM | Cross-browser testing suite |
| Mobile Responsiveness | LOW | HIGH | Responsive design testing |
| Search Performance | MEDIUM | MEDIUM | Query optimization + indexing tests |
| User Role Confusion | MEDIUM | LOW | Role-based testing scenarios |

## 📅 **12. TEST EXECUTION SCHEDULE**

### **Phase 1: Foundation (Week 1)**
- ✅ Unit tests implementation
- ✅ Test data setup and fixtures
- ✅ CI/CD pipeline configuration
- ✅ Database integration tests

### **Phase 2: Integration (Week 2)**
- ✅ API integration testing
- ✅ Flutter-Supabase integration
- ✅ RLS security validation
- ✅ Performance baseline establishment

### **Phase 3: End-to-End (Week 3)**
- ✅ Critical user flow testing
- ✅ Cross-browser compatibility
- ✅ Accessibility compliance
- ✅ Realtime functionality validation

### **Phase 4: Optimization (Week 4)**
- ✅ Load testing and optimization
- ✅ Security penetration testing
- ✅ Final regression testing
- ✅ Production readiness review

## ✅ **DEFINITION OF DONE**

### **Functional Criteria**
- [ ] All unit tests passing (≥90% coverage)
- [ ] All integration tests passing
- [ ] Critical E2E flows working
- [ ] RLS policies validated for all roles
- [ ] Performance benchmarks met
- [ ] Cross-browser compatibility confirmed

### **Non-Functional Criteria**
- [ ] Security audit passed
- [ ] Accessibility WCAG-AA compliant
- [ ] Performance under load validated
- [ ] Documentation complete
- [ ] Deployment checklist verified
- [ ] Monitoring and alerting configured

### **Business Criteria**
- [ ] User acceptance testing completed
- [ ] Stakeholder sign-off obtained
- [ ] Production deployment approved
- [ ] Support documentation ready
- [ ] Training materials prepared

---

**Prepared by**: Claude QA Senior  
**Review Date**: 2025-09-11  
**Next Review**: Weekly during execution  
**Approval Required**: Product Owner + Tech Lead