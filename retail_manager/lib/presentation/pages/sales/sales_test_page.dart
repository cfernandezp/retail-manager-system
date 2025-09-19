import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/sales/sales_bloc.dart';
import '../../../data/repositories/sales_repository.dart';
import '../../../data/models/product_models.dart';
import '../../../core/utils/sales_calculations.dart';

/// Página de prueba para el módulo de ventas
/// Permite probar las funcionalidades básicas sin una UI completa
class SalesTestPage extends StatefulWidget {
  const SalesTestPage({Key? key}) : super(key: key);

  @override
  State<SalesTestPage> createState() => _SalesTestPageState();
}

class _SalesTestPageState extends State<SalesTestPage> {
  late SalesBloc _salesBloc;

  @override
  void initState() {
    super.initState();
    _salesBloc = SalesBloc(repository: SalesRepository());
    _loadInitialData();
  }

  void _loadInitialData() {
    // Cargar estrategias de descuento
    _salesBloc.add(const LoadEstrategiasDescuento());

    // Cargar todos los permisos
    _salesBloc.add(const LoadAllPermisosDescuento());

    // Cargar permiso para vendedor junior (ejemplo)
    _salesBloc.add(const LoadPermisoDescuento(rolUsuario: 'vendedor_junior'));
  }

  @override
  void dispose() {
    _salesBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prueba Módulo de Ventas'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: BlocProvider(
        create: (context) => _salesBloc,
        child: BlocConsumer<SalesBloc, SalesState>(
          listener: (context, state) {
            if (state is SalesError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${state.message}'),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is SalesCreated) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Éxito: ${state.message}'),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is SalesUpdated) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Actualizado: ${state.message}'),
                  backgroundColor: Colors.blue,
                ),
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(),
                  const SizedBox(height: 16),
                  _buildTestActions(context),
                  const SizedBox(height: 16),
                  if (state is SalesLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (state is SalesLoaded)
                    _buildSalesData(state)
                  else if (state is SalesError)
                    _buildErrorCard(state)
                  else
                    _buildInitialCard(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Módulo de Ventas - Testing',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Esta página permite probar las funcionalidades básicas del módulo de ventas:'
              '\n• Estrategias de descuento'
              '\n• Permisos de usuario'
              '\n• Cálculos de descuentos'
              '\n• Verificaciones de permisos',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestActions(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Acciones de Prueba',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => _salesBloc.add(const LoadEstrategiasDescuento()),
                  child: const Text('Cargar Estrategias'),
                ),
                ElevatedButton(
                  onPressed: () => _salesBloc.add(const LoadAllPermisosDescuento()),
                  child: const Text('Cargar Permisos'),
                ),
                ElevatedButton(
                  onPressed: () => _testCalculoDescuento(context),
                  child: const Text('Test Cálculo Descuento'),
                ),
                ElevatedButton(
                  onPressed: () => _testVerificacionPermiso(context),
                  child: const Text('Test Verificar Permiso'),
                ),
                ElevatedButton(
                  onPressed: () => _testCarrito(context),
                  child: const Text('Test Carrito'),
                ),
                ElevatedButton(
                  onPressed: () => _salesBloc.add(const ResetSalesState()),
                  child: const Text('Reset Estado'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _testCalculoDescuento(BuildContext context) {
    // Test con categoría "Medias" y cantidad 6 (media docena)
    // Debería aplicar descuento del 10% según los datos semilla
    _salesBloc.add(const CalcularDescuentoPorCantidad(
      categoriaId: 'categoria-medias-id', // Esto necesitaría ser un ID real
      cantidad: 6,
    ));
  }

  void _testVerificacionPermiso(BuildContext context) {
    // Test verificar si vendedor junior (5% máximo) puede aplicar 3%
    _salesBloc.add(const VerificarPermisoDescuento(
      rolUsuario: 'vendedor_junior',
      descuentoPorcentaje: 3.0,
    ));
  }

  void _testCarrito(BuildContext context) {
    // Crear un artículo de prueba para agregar al carrito
    final articuloPrueba = Articulo(
      id: 'articulo-test-001',
      productoId: 'producto-test',
      colorId: 'color-test',
      skuAuto: 'TEST-SKU-001',
      precioSugerido: 15.00,
      activo: true,
      createdAt: DateTime.now(),
    );

    _salesBloc.add(AddArticuloToCarrito(
      articulo: articuloPrueba,
      cantidad: 3,
    ));
  }

  Widget _buildSalesData(SalesLoaded state) {
    return Column(
      children: [
        _buildEstrategiasCard(state.estrategias),
        const SizedBox(height: 16),
        _buildPermisosCard(state.permisos),
        const SizedBox(height: 16),
        if (state.permisoActual != null)
          _buildPermisoActualCard(state.permisoActual!),
        const SizedBox(height: 16),
        if (state.carrito.isNotEmpty)
          _buildCarritoCard(state.carrito),
        const SizedBox(height: 16),
        if (state.descuentoCalculado != null)
          _buildDescuentoCalculadoCard(state.descuentoCalculado!),
        const SizedBox(height: 16),
        if (state.permisoVerificado != null)
          _buildPermisoVerificadoCard(state.permisoVerificado!),
      ],
    );
  }

  Widget _buildEstrategiasCard(List<EstrategiaDescuento> estrategias) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estrategias de Descuento (${estrategias.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (estrategias.isEmpty)
              const Text('No hay estrategias cargadas')
            else
              ...estrategias.map((estrategia) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            estrategia.nombre,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          if (estrategia.descripcion != null)
                            Text(
                              estrategia.descripcion!,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          Text(
                            'Rangos: ${estrategia.rangosDescuento.length}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: estrategia.activa ? Colors.green[100] : Colors.red[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        estrategia.activa ? 'Activa' : 'Inactiva',
                        style: TextStyle(
                          color: estrategia.activa ? Colors.green[800] : Colors.red[800],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildPermisosCard(List<PermisoDescuento> permisos) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Permisos de Descuento (${permisos.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (permisos.isEmpty)
              const Text('No hay permisos cargados')
            else
              ...permisos.map((permiso) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            permiso.rolUsuario,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            'Máximo: ${SalesCalculations.formatearPorcentaje(permiso.descuentoMaximoPorcentaje)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        if (permiso.requiereAprobacion)
                          const Icon(Icons.approval, size: 16, color: Colors.orange),
                        if (permiso.puedeAprobarDescuentos)
                          const Icon(Icons.verified, size: 16, color: Colors.green),
                      ],
                    ),
                  ],
                ),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildPermisoActualCard(PermisoDescuento permiso) {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Permiso Actual',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            const SizedBox(height: 8),
            Text('Rol: ${permiso.rolUsuario}'),
            Text('Descuento máximo: ${SalesCalculations.formatearPorcentaje(permiso.descuentoMaximoPorcentaje)}'),
            Text('Requiere aprobación: ${permiso.requiereAprobacion ? "Sí" : "No"}'),
            Text('Puede aprobar: ${permiso.puedeAprobarDescuentos ? "Sí" : "No"}'),
          ],
        ),
      ),
    );
  }

  Widget _buildCarritoCard(CarritoState carrito) {
    return Card(
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Carrito de Compras',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            const SizedBox(height: 8),
            Text('Artículos: ${carrito.totalCantidad}'),
            Text('Subtotal: ${SalesCalculations.formatearMoneda(carrito.subtotal)}'),
            Text('Descuento: ${SalesCalculations.formatearMoneda(carrito.descuentoTotal)}'),
            Text('Impuestos: ${SalesCalculations.formatearMoneda(carrito.impuestos)}'),
            Text(
              'Total: ${SalesCalculations.formatearMoneda(carrito.montoTotal)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (carrito.tieneDescuentosEspeciales)
              const Text(
                'Tiene descuentos especiales',
                style: TextStyle(color: Colors.orange),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescuentoCalculadoCard(double descuento) {
    return Card(
      color: Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Descuento Calculado',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.orange[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              SalesCalculations.formatearPorcentaje(descuento),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.orange[800],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermisoVerificadoCard(bool verificado) {
    return Card(
      color: verificado ? Colors.green[50] : Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Verificación de Permiso',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: verificado ? Colors.green[800] : Colors.red[800],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  verificado ? Icons.check_circle : Icons.cancel,
                  color: verificado ? Colors.green[800] : Colors.red[800],
                ),
                const SizedBox(width: 8),
                Text(
                  verificado ? 'Permiso autorizado' : 'Permiso denegado',
                  style: TextStyle(
                    color: verificado ? Colors.green[800] : Colors.red[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(SalesError error) {
    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Error',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.red[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(error.message),
            if (error.errorCode != null)
              Text(
                'Código: ${error.errorCode}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialCard() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Text('Estado inicial - Usar botones de prueba arriba'),
        ),
      ),
    );
  }
}