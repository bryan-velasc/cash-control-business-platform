import 'package:flutter/material.dart';

import '../models/customer_model.dart';
import '../models/product_model.dart';

import '../services/customer_service.dart';
import '../services/product_service.dart';
import '../services/sale_service.dart';

class NewSaleScreen extends StatefulWidget {
  const NewSaleScreen({super.key});

  @override
  State<NewSaleScreen> createState() => _NewSaleScreenState();
}

class _NewSaleScreenState extends State<NewSaleScreen> {
  bool _loading = true;
  bool _saving = false;

  String? _error;

  List<ProductModel> _products = [];
  List<CustomerModel> _customers = [];

  final Map<int, int> _cart = {};

  String _search = '';
  String _paymentMethod = 'efectivo';

  CustomerModel? _selectedCustomer;

  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        ProductService.getAdminProducts(),
        CustomerService.getCustomers(),
      ]);

      if (!mounted) return;

      setState(() {
        _products = (results[0] as List<ProductModel>)
            .where((product) => product.activo)
            .toList();

        _customers = (results[1] as List<CustomerModel>)
            .where((customer) => customer.activo)
            .toList();

        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  List<ProductModel> get _filteredProducts {
    final query = _search.trim().toLowerCase();

    if (query.isEmpty) {
      return _products;
    }

    return _products.where((product) {
      return product.nombre.toLowerCase().contains(query) ||
          product.categoria.toLowerCase().contains(query);
    }).toList();
  }

  ProductModel? _findProduct(int id) {
    for (final product in _products) {
      if (product.id == id) {
        return product;
      }
    }

    return null;
  }

  int _quantity(ProductModel product) {
    return _cart[product.id] ?? 0;
  }

  void _addProduct(ProductModel product) {
    final current = _quantity(product);

    if (current >= product.stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No hay más stock disponible de ${product.nombre}.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _cart[product.id] = current + 1;
    });
  }

  void _removeProduct(ProductModel product) {
    final current = _quantity(product);

    if (current <= 1) {
      setState(() {
        _cart.remove(product.id);
      });

      return;
    }

    setState(() {
      _cart[product.id] = current - 1;
    });
  }

  int get _units {
    return _cart.values.fold(
      0,
      (total, quantity) => total + quantity,
    );
  }

  double get _total {
    double total = 0;

    for (final entry in _cart.entries) {
      final product = _findProduct(entry.key);

      if (product != null) {
        total += product.precio * entry.value;
      }
    }

    return total;
  }

  Future<void> _selectCustomer() async {
    if (_customers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay clientes activos.'),
        ),
      );

      return;
    }

    final customer = await showModalBottomSheet<CustomerModel>(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.65,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(18),
                  child: Text(
                    'Seleccionar cliente',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _customers.length,
                    itemBuilder: (context, index) {
                      final customer = _customers[index];

                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            customer.nombre.isEmpty
                                ? '?'
                                : customer.nombre[0].toUpperCase(),
                          ),
                        ),
                        title: Text(customer.nombre),
                        subtitle: customer.telefono == null
                            ? null
                            : Text(customer.telefono!),
                        onTap: () {
                          Navigator.pop(
                            context,
                            customer,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (customer != null) {
      setState(() {
        _selectedCustomer = customer;
      });
    }
  }

  Future<void> _checkout() async {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agrega productos a la venta.'),
        ),
      );

      return;
    }

    if (_paymentMethod == 'fiado' &&
        _selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Selecciona un cliente para realizar una venta fiada.',
          ),
        ),
      );

      return;
    }

    final confirmed = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Confirmar venta'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ConfirmRow(
                  label: 'Productos',
                  value: '$_units',
                ),
                _ConfirmRow(
                  label: 'Total',
                  value: '\$${_total.toStringAsFixed(2)}',
                ),
                _ConfirmRow(
                  label: 'Pago',
                  value: _paymentLabel(_paymentMethod),
                ),
                if (_selectedCustomer != null)
                  _ConfirmRow(
                    label: 'Cliente',
                    value: _selectedCustomer!.nombre,
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(
                  context,
                  false,
                ),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(
                  context,
                  true,
                ),
                child: const Text('Registrar'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;

    setState(() {
      _saving = true;
    });

    try {
      final items = _cart.entries
          .map(
            (entry) => {
              'product_id': entry.key,
              'cantidad': entry.value,
            },
          )
          .toList();

      final sale = await SaleService.createSale(
        items: items,
        metodoPago: _paymentMethod,
        customerId: _selectedCustomer?.customerId,
        notas: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Venta registrada'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                '\$${sale.total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(sale.folio),
              if (sale.creditId != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Fiado #${sale.creditId}',
                ),
              ],
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo registrar la venta: $error',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  String _paymentLabel(String value) {
    switch (value) {
      case 'efectivo':
        return 'Efectivo';
      case 'transferencia':
        return 'Transferencia';
      case 'tarjeta':
        return 'Tarjeta';
      case 'fiado':
        return 'Fiado';
      default:
        return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva venta'),
      ),
      body: _buildBody(),
      bottomNavigationBar:
          _loading || _error != null ? null : _buildCheckout(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: FilledButton(
          onPressed: _loadData,
          child: Text('Reintentar\n$_error'),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          onChanged: (value) {
            setState(() {
              _search = value;
            });
          },
          decoration: const InputDecoration(
            labelText: 'Buscar producto',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),

        ..._filteredProducts.map(_productCard),

        const SizedBox(height: 20),

        const Text(
          'Método de pago',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        DropdownButtonFormField<String>(
          initialValue: _paymentMethod,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(
              value: 'efectivo',
              child: Text('Efectivo'),
            ),
            DropdownMenuItem(
              value: 'transferencia',
              child: Text('Transferencia'),
            ),
            DropdownMenuItem(
              value: 'tarjeta',
              child: Text('Tarjeta'),
            ),
            DropdownMenuItem(
              value: 'fiado',
              child: Text('Fiado'),
            ),
          ],
          onChanged: (value) {
            if (value == null) return;

            setState(() {
              _paymentMethod = value;
            });
          },
        ),

        const SizedBox(height: 16),

        Card(
          child: ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(
              _selectedCustomer?.nombre ??
                  'Cliente opcional',
            ),
            subtitle: Text(
              _paymentMethod == 'fiado'
                  ? 'Obligatorio para fiado'
                  : 'Puedes asociar la venta a un cliente',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: _selectCustomer,
          ),
        ),

        if (_selectedCustomer != null)
          TextButton(
            onPressed: () {
              setState(() {
                _selectedCustomer = null;
              });
            },
            child: const Text('Quitar cliente'),
          ),

        const SizedBox(height: 12),

        TextField(
          controller: _notesController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Notas',
            border: OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 100),
      ],
    );
  }

  Widget _productCard(ProductModel product) {
    final quantity = _quantity(product);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.nombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(product.categoria),
                  Text(
                    '\$${product.precio.toStringAsFixed(2)}',
                  ),
                  Text(
                    'Stock: ${product.stock}',
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: quantity == 0
                  ? null
                  : () => _removeProduct(product),
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Text(
              '$quantity',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              onPressed: product.stock <= quantity
                  ? null
                  : () => _addProduct(product),
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckout() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: const [
            BoxShadow(
              blurRadius: 8,
              offset: Offset(0, -2),
              color: Colors.black26,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$_units unidades'),
                  Text(
                    '\$${_total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            FilledButton.icon(
              onPressed: _saving ? null : _checkout,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.point_of_sale),
              label: Text(
                _saving ? 'Guardando...' : 'Cobrar',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfirmRow extends StatelessWidget {
  final String label;
  final String value;

  const _ConfirmRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}