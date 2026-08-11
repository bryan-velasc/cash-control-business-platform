import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../models/supplier_model.dart';

import '../services/product_service.dart';
import '../services/purchase_service.dart';
import '../services/supplier_service.dart';

class NewPurchaseScreen extends StatefulWidget {
  const NewPurchaseScreen({super.key});

  @override
  State<NewPurchaseScreen> createState() =>
      _NewPurchaseScreenState();
}

class _NewPurchaseScreenState
    extends State<NewPurchaseScreen> {
  bool _loading = true;
  bool _saving = false;

  String? _error;

  List<ProductModel> _products = [];
  List<SupplierModel> _suppliers = [];

  SupplierModel? _selectedSupplier;

  final Map<int, _PurchaseCartItem> _cart = {};

  final TextEditingController _searchController =
      TextEditingController();

  final TextEditingController _referenceController =
      TextEditingController();

  final TextEditingController _notesController =
      TextEditingController();

  String _search = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _referenceController.dispose();
    _notesController.dispose();

    for (final item in _cart.values) {
      item.dispose();
    }

    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final productResult =
          await ProductService.getAdminProducts();

      final supplierResult =
          await SupplierService.getSuppliers();

      if (!mounted) return;

      final products = productResult
          .whereType<ProductModel>()
          .where(
            (product) => product.activo,
          )
          .toList();

      final suppliers = supplierResult
          .where(
            (supplier) => supplier.activo,
          )
          .toList();

      setState(() {
        _products = products;
        _suppliers = suppliers;
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

    return _products.where(
      (product) {
        return product.nombre
                .toLowerCase()
                .contains(query) ||
            product.categoria
                .toLowerCase()
                .contains(query) ||
            (product.proveedor ?? '')
                .toLowerCase()
                .contains(query);
      },
    ).toList();
  }

  int get _totalUnits {
    return _cart.values.fold(
      0,
      (total, item) =>
          total + item.quantity,
    );
  }

  double get _totalPurchase {
    return _cart.values.fold(
      0,
      (total, item) =>
          total + item.subtotal,
    );
  }

  void _addProduct(
    ProductModel product,
  ) {
    if (_cart.containsKey(product.id)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            '${product.nombre} ya está en la compra.',
          ),
        ),
      );

      return;
    }

    final cost = product.precioCompra ?? 0;

    final item = _PurchaseCartItem(
      product: product,
      quantity: 1,
      cost: cost,
      onChanged: () {
        if (mounted) {
          setState(() {});
        }
      },
    );

    setState(() {
      _cart[product.id] = item;
    });
  }

  void _removeProduct(
    int productId,
  ) {
    final item = _cart.remove(
      productId,
    );

    item?.dispose();

    setState(() {});
  }

  Future<void> _selectSupplier() async {
    if (_suppliers.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'No hay proveedores activos. '
            'Primero registra un proveedor.',
          ),
        ),
      );

      return;
    }

    final selected =
        await showModalBottomSheet<
            SupplierModel>(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return _SupplierSelector(
          suppliers: _suppliers,
        );
      },
    );

    if (selected == null) {
      return;
    }

    setState(() {
      _selectedSupplier = selected;
    });
  }

  Future<void> _savePurchase() async {
    if (_selectedSupplier == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Selecciona un proveedor.',
          ),
        ),
      );

      return;
    }

    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Agrega al menos un producto.',
          ),
        ),
      );

      return;
    }

    for (final item in _cart.values) {
      if (item.quantity <= 0) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          TextSnackBar(
            'Cantidad inválida para '
            '${item.product.nombre}.',
          ),
        );

        return;
      }

      if (item.cost <= 0) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          TextSnackBar(
            'Ingresa el costo de '
            '${item.product.nombre}.',
          ),
        );

        return;
      }
    }

    final confirmed =
        await showDialog<bool>(
              context: context,
              builder: (_) =>
                  AlertDialog(
                title: const Text(
                  'Confirmar compra',
                ),
                content: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    _ConfirmationRow(
                      label: 'Proveedor',
                      value:
                          _selectedSupplier!
                              .nombre,
                    ),
                    _ConfirmationRow(
                      label: 'Productos',
                      value:
                          '${_cart.length}',
                    ),
                    _ConfirmationRow(
                      label: 'Unidades',
                      value:
                          '$_totalUnits',
                    ),
                    _ConfirmationRow(
                      label:
                          'Total reinvertido',
                      value:
                          '\$${_totalPurchase.toStringAsFixed(2)}',
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                        false,
                      );
                    },
                    child: const Text(
                      'Cancelar',
                    ),
                  ),
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                        true,
                      );
                    },
                    child: const Text(
                      'Registrar compra',
                    ),
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
      final items = _cart.values
          .map(
            (item) => {
              'product_id':
                  item.product.id,
              'cantidad':
                  item.quantity,
              'costo_unitario':
                  item.cost,
            },
          )
          .toList();

      final purchase =
          await PurchaseService
              .createPurchase(
        supplierId:
            _selectedSupplier!
                .supplierId,
        items: items,
        referencia:
            _clean(
          _referenceController.text,
        ),
        notas: _clean(
          _notesController.text,
        ),
      );

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        builder: (_) =>
            AlertDialog(
          title: const Text(
            'Compra registrada',
          ),
          content: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              const Icon(
                Icons
                    .check_circle_outline,
                size: 60,
              ),
              const SizedBox(
                height: 16,
              ),
              Text(
                '\$${purchase.total.toStringAsFixed(2)}',
                style:
                    const TextStyle(
                  fontSize: 26,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                purchase.folio,
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                purchase
                    .supplierNombre,
              ),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  context,
                );
              },
              child: const Text(
                'Aceptar',
              ),
            ),
          ],
        ),
      );

      if (!mounted) return;

      Navigator.pop(
        context,
        true,
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo registrar la compra: '
            '$error',
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

  String? _clean(
    String value,
  ) {
    final result = value.trim();

    if (result.isEmpty) {
      return null;
    }

    return result;
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nueva compra',
        ),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed:
                _loading
                    ? null
                    : _loadData,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar:
          _loading ||
                  _error != null
              ? null
              : _buildBottomBar(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child:
            CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding:
              const EdgeInsets.all(
            24,
          ),
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
              ),
              const SizedBox(
                height: 12,
              ),
              Text(
                _error!,
                textAlign:
                    TextAlign.center,
              ),
              const SizedBox(
                height: 16,
              ),
              FilledButton.icon(
                onPressed:
                    _loadData,
                icon: const Icon(
                  Icons.refresh,
                ),
                label:
                    const Text(
                  'Reintentar',
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding:
          const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        130,
      ),
      children: [
        Card(
          child: ListTile(
            leading: const Icon(
              Icons
                  .local_shipping_outlined,
            ),
            title: Text(
              _selectedSupplier
                      ?.nombre ??
                  'Seleccionar proveedor',
            ),
            subtitle:
                _selectedSupplier ==
                        null
                    ? const Text(
                        'Obligatorio',
                      )
                    : Text(
                        _supplierDetails(
                          _selectedSupplier!,
                        ),
                      ),
            trailing: const Icon(
              Icons.chevron_right,
            ),
            onTap: _selectSupplier,
          ),
        ),

        const SizedBox(
          height: 16,
        ),

        TextField(
          controller:
              _searchController,
          onChanged: (value) {
            setState(() {
              _search = value;
            });
          },
          decoration:
              const InputDecoration(
            labelText:
                'Buscar producto',
            hintText:
                'Nombre, categoría o proveedor',
            prefixIcon:
                Icon(Icons.search),
            border:
                OutlineInputBorder(),
          ),
        ),

        const SizedBox(
          height: 16,
        ),

        const Text(
          'Productos disponibles',
          style: TextStyle(
            fontSize: 18,
            fontWeight:
                FontWeight.bold,
          ),
        ),

        const SizedBox(
          height: 8,
        ),

        if (_filteredProducts
            .isEmpty)
          const Card(
            child: Padding(
              padding:
                  EdgeInsets.all(
                20,
              ),
              child: Text(
                'No se encontraron productos.',
              ),
            ),
          )
        else
          ..._filteredProducts
              .map(
            (product) =>
                _buildProductCard(
              product,
            ),
          ),

        const SizedBox(
          height: 22,
        ),

        Row(
          children: [
            const Expanded(
              child: Text(
                'Productos en la compra',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
            Text(
              '${_cart.length}',
              style:
                  const TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 8,
        ),

        if (_cart.isEmpty)
          const Card(
            child: Padding(
              padding:
                  EdgeInsets.all(
                20,
              ),
              child: Text(
                'Agrega productos para registrar la compra.',
              ),
            ),
          )
        else
          ..._cart.values.map(
            _buildCartItem,
          ),

        const SizedBox(
          height: 20,
        ),

        TextField(
          controller:
              _referenceController,
          decoration:
              const InputDecoration(
            labelText:
                'Referencia',
            hintText:
                'Factura, ticket, pedido...',
            prefixIcon: Icon(
              Icons.tag,
            ),
            border:
                OutlineInputBorder(),
          ),
        ),

        const SizedBox(
          height: 16,
        ),

        TextField(
          controller:
              _notesController,
          maxLines: 3,
          decoration:
              const InputDecoration(
            labelText: 'Notas',
            prefixIcon:
                Icon(Icons.notes),
            alignLabelWithHint:
                true,
            border:
                OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(
    ProductModel product,
  ) {
    final added =
        _cart.containsKey(
      product.id,
    );

    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 8,
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            product.nombre.isEmpty
                ? '?'
                : product.nombre[0]
                    .toUpperCase(),
          ),
        ),
        title: Text(
          product.nombre,
          style:
              const TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              product.categoria,
            ),
            Text(
              'Stock actual: ${product.stock}',
            ),
            Text(
              'Costo actual: '
              '\$${(product.precioCompra ?? 0).toStringAsFixed(2)}',
            ),
          ],
        ),
        trailing: added
            ? const Icon(
                Icons.check_circle,
              )
            : IconButton(
                tooltip:
                    'Agregar',
                onPressed: () {
                  _addProduct(
                    product,
                  );
                },
                icon:
                    const Icon(
                  Icons
                      .add_circle_outline,
                ),
              ),
        onTap: added
            ? null
            : () {
                _addProduct(
                  product,
                );
              },
      ),
    );
  }

  Widget _buildCartItem(
    _PurchaseCartItem item,
  ) {
    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(
          14,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.product
                        .nombre,
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  tooltip:
                      'Quitar',
                  onPressed: () {
                    _removeProduct(
                      item.product.id,
                    );
                  },
                  icon:
                      const Icon(
                    Icons
                        .delete_outline,
                  ),
                ),
              ],
            ),

            Text(
              'Stock actual: '
              '${item.product.stock}',
            ),

            const SizedBox(
              height: 12,
            ),

            Row(
              children: [
                Expanded(
                  child:
                      TextFormField(
                    controller: item
                        .quantityController,
                    keyboardType:
                        TextInputType
                            .number,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Cantidad',
                      border:
                          OutlineInputBorder(),
                    ),
                    onChanged: (_) {
                      item
                          .notifyChanged();
                    },
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child:
                      TextFormField(
                    controller: item
                        .costController,
                    keyboardType:
                        const TextInputType
                            .numberWithOptions(
                      decimal: true,
                    ),
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Costo unitario',
                      prefixText:
                          '\$ ',
                      border:
                          OutlineInputBorder(),
                    ),
                    onChanged: (_) {
                      item
                          .notifyChanged();
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 12,
            ),

            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Subtotal',
                  ),
                ),
                Text(
                  '\$${item.subtotal.toStringAsFixed(2)}',
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 4,
            ),

            Text(
              'Stock después de compra: '
              '${item.product.stock + item.quantity}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return SafeArea(
      child: Container(
        padding:
            const EdgeInsets.all(
          14,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .surface,
          boxShadow: const [
            BoxShadow(
              blurRadius: 8,
              offset:
                  Offset(0, -2),
              color:
                  Colors.black26,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    '$_totalUnits unidades',
                  ),
                  Text(
                    '\$${_totalPurchase.toStringAsFixed(2)}',
                    style:
                        const TextStyle(
                      fontSize: 21,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Total reinvertido',
                  ),
                ],
              ),
            ),
            FilledButton.icon(
              onPressed:
                  _saving
                      ? null
                      : _savePurchase,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child:
                          CircularProgressIndicator(
                        strokeWidth:
                            2,
                      ),
                    )
                  : const Icon(
                      Icons
                          .shopping_cart_checkout,
                    ),
              label: Text(
                _saving
                    ? 'Registrando...'
                    : 'Registrar',
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _supplierDetails(
    SupplierModel supplier,
  ) {
    final parts = <String>[];

    if (supplier.contacto != null &&
        supplier.contacto!
            .isNotEmpty) {
      parts.add(
        supplier.contacto!,
      );
    }

    if (supplier.telefono != null &&
        supplier.telefono!
            .isNotEmpty) {
      parts.add(
        supplier.telefono!,
      );
    }

    if (parts.isEmpty) {
      return 'Proveedor #${supplier.supplierId}';
    }

    return parts.join(' • ');
  }
}

class _PurchaseCartItem {
  final ProductModel product;

  final TextEditingController
      quantityController;

  final TextEditingController
      costController;

  final VoidCallback onChanged;

  _PurchaseCartItem({
    required this.product,
    required int quantity,
    required double cost,
    required this.onChanged,
  })  : quantityController =
            TextEditingController(
          text: quantity.toString(),
        ),
        costController =
            TextEditingController(
          text: cost <= 0
              ? ''
              : cost
                  .toStringAsFixed(
                    2,
                  ),
        );

  int get quantity {
    return int.tryParse(
          quantityController.text
              .trim(),
        ) ??
        0;
  }

  double get cost {
    return double.tryParse(
          costController.text
              .replaceAll(',', '')
              .trim(),
        ) ??
        0;
  }

  double get subtotal {
    return quantity * cost;
  }

  void notifyChanged() {
    onChanged();
  }

  void dispose() {
    quantityController.dispose();
    costController.dispose();
  }
}

class _SupplierSelector
    extends StatefulWidget {
  final List<SupplierModel> suppliers;

  const _SupplierSelector({
    required this.suppliers,
  });

  @override
  State<_SupplierSelector>
      createState() =>
          _SupplierSelectorState();
}

class _SupplierSelectorState
    extends State<_SupplierSelector> {
  String _search = '';

  List<SupplierModel>
      get _filtered {
    final query =
        _search.trim().toLowerCase();

    if (query.isEmpty) {
      return widget.suppliers;
    }

    return widget.suppliers.where(
      (supplier) {
        return supplier.nombre
                .toLowerCase()
                .contains(query) ||
            (supplier.contacto ??
                    '')
                .toLowerCase()
                .contains(query) ||
            (supplier.telefono ??
                    '')
                .toLowerCase()
                .contains(query);
      },
    ).toList();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return SafeArea(
      child: SizedBox(
        height:
            MediaQuery.of(context)
                    .size
                    .height *
                0.70,
        child: Padding(
          padding:
              const EdgeInsets.all(
            16,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              const Text(
                'Seleccionar proveedor',
                style:
                    TextStyle(
                  fontSize: 21,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 14,
              ),
              TextField(
                autofocus: true,
                onChanged: (value) {
                  setState(() {
                    _search =
                        value;
                  });
                },
                decoration:
                    const InputDecoration(
                  labelText:
                      'Buscar proveedor',
                  prefixIcon:
                      Icon(
                    Icons.search,
                  ),
                  border:
                      OutlineInputBorder(),
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              Expanded(
                child:
                    _filtered.isEmpty
                        ? const Center(
                            child:
                                Text(
                              'No se encontraron proveedores.',
                            ),
                          )
                        : ListView
                            .builder(
                            itemCount:
                                _filtered
                                    .length,
                            itemBuilder:
                                (
                              context,
                              index,
                            ) {
                              final supplier =
                                  _filtered[
                                      index];

                              return ListTile(
                                leading:
                                    const CircleAvatar(
                                  child:
                                      Icon(
                                    Icons
                                        .business,
                                  ),
                                ),
                                title:
                                    Text(
                                  supplier
                                      .nombre,
                                ),
                                subtitle:
                                    supplier.telefono ==
                                            null
                                        ? null
                                        : Text(
                                            supplier.telefono!,
                                          ),
                                trailing:
                                    const Icon(
                                  Icons
                                      .chevron_right,
                                ),
                                onTap:
                                    () {
                                  Navigator
                                      .pop(
                                    context,
                                    supplier,
                                  );
                                },
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfirmationRow
    extends StatelessWidget {
  final String label;
  final String value;

  const _ConfirmationRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 5,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign:
                  TextAlign.right,
              style:
                  const TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper pequeño para mostrar un SnackBar desde texto.
class TextSnackBar extends SnackBar {
  TextSnackBar(
    String text, {
    super.key,
  }) : super(
          content: Text(text),
        );
}