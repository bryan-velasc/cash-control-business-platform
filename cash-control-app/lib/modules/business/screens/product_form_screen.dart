import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductFormScreen extends StatefulWidget {
  final ProductModel? product;

  const ProductFormScreen({
    super.key,
    this.product,
  });

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nombreController;
  late final TextEditingController _categoriaController;
  late final TextEditingController _precioController;
  late final TextEditingController _precioCompraController;
  late final TextEditingController _stockController;
  late final TextEditingController _stockMinimoController;
  late final TextEditingController _proveedorController;
  late final TextEditingController _imagenController;

  bool _activo = true;
  bool _isSaving = false;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();

    final product = widget.product;

    _nombreController = TextEditingController(
      text: product?.nombre ?? '',
    );
    _categoriaController = TextEditingController(
      text: product?.categoria ?? '',
    );
    _precioController = TextEditingController(
      text: product == null ? '' : product.precio.toStringAsFixed(2),
    );
    _precioCompraController = TextEditingController(
      text: product?.precioCompra == null
          ? ''
          : product!.precioCompra!.toStringAsFixed(2),
    );
    _stockController = TextEditingController(
      text: product == null ? '' : product.stock.toString(),
    );
    _stockMinimoController = TextEditingController(
      text: product?.stockMinimo == null
          ? ''
          : product!.stockMinimo.toString(),
    );
    _proveedorController = TextEditingController(
      text: product?.proveedor ?? '',
    );
    _imagenController = TextEditingController(
      text: product?.imagen ?? '',
    );

    _activo = product?.activo ?? true;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _categoriaController.dispose();
    _precioController.dispose();
    _precioCompraController.dispose();
    _stockController.dispose();
    _stockMinimoController.dispose();
    _proveedorController.dispose();
    _imagenController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      if (_isEditing) {
        await ProductService.updateProduct(
          id: widget.product!.id,
          nombre: _nombreController.text.trim(),
          categoria: _categoriaController.text.trim(),
          precio: double.parse(
            _precioController.text.trim().replaceAll(',', '.'),
          ),
          imagen: _imagenController.text.trim(),
          stock: int.parse(_stockController.text.trim()),
          activo: _activo,
          precioCompra: _precioCompraController.text.trim().isEmpty
              ? null
              : double.parse(
                  _precioCompraController.text.trim().replaceAll(',', '.'),
                ),
          proveedor: _proveedorController.text.trim().isEmpty
              ? null
              : _proveedorController.text.trim(),
          stockMinimo: _stockMinimoController.text.trim().isEmpty
              ? 0
              : int.parse(_stockMinimoController.text.trim()),
        );
      } else {
        await ProductService.createProduct(
          nombre: _nombreController.text.trim(),
          categoria: _categoriaController.text.trim(),
          precio: double.parse(
            _precioController.text.trim().replaceAll(',', '.'),
          ),
          imagen: _imagenController.text.trim(),
          stock: int.parse(_stockController.text.trim()),
          activo: _activo,
          precioCompra: _precioCompraController.text.trim().isEmpty
              ? null
              : double.parse(
                  _precioCompraController.text.trim().replaceAll(',', '.'),
                ),
          proveedor: _proveedorController.text.trim().isEmpty
              ? null
              : _proveedorController.text.trim(),
          stockMinimo: _stockMinimoController.text.trim().isEmpty
              ? 0
              : int.parse(_stockMinimoController.text.trim()),
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Producto actualizado correctamente'
                : 'Producto creado correctamente',
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar producto: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String? _requiredText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obligatorio';
    }

    return null;
  }

  String? _requiredNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obligatorio';
    }

    final number = double.tryParse(
      value.trim().replaceAll(',', '.'),
    );

    if (number == null) {
      return 'Ingresa un número válido';
    }

    if (number < 0) {
      return 'No puede ser negativo';
    }

    return null;
  }

  String? _optionalNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final number = double.tryParse(
      value.trim().replaceAll(',', '.'),
    );

    if (number == null) {
      return 'Ingresa un número válido';
    }

    if (number < 0) {
      return 'No puede ser negativo';
    }

    return null;
  }

  String? _requiredInteger(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obligatorio';
    }

    final number = int.tryParse(value.trim());

    if (number == null) {
      return 'Ingresa un número entero válido';
    }

    if (number < 0) {
      return 'No puede ser negativo';
    }

    return null;
  }

  String? _optionalInteger(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final number = int.tryParse(value.trim());

    if (number == null) {
      return 'Ingresa un número entero válido';
    }

    if (number < 0) {
      return 'No puede ser negativo';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEditing ? 'Editar producto' : 'Agregar producto';

    return Scaffold(
      backgroundColor: const Color(0xFF101014),
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF181820),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                controller: _nombreController,
                label: 'Nombre del producto',
                icon: Icons.inventory_2_rounded,
                validator: _requiredText,
              ),
              const SizedBox(height: 14),
              _buildTextField(
                controller: _categoriaController,
                label: 'Categoría',
                icon: Icons.category_rounded,
                validator: _requiredText,
              ),
              const SizedBox(height: 14),
              _buildTextField(
                controller: _precioController,
                label: 'Precio de venta',
                icon: Icons.sell_rounded,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: _requiredNumber,
              ),
              const SizedBox(height: 14),
              _buildTextField(
                controller: _precioCompraController,
                label: 'Precio de compra',
                icon: Icons.shopping_cart_rounded,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: _optionalNumber,
              ),
              const SizedBox(height: 14),
              _buildTextField(
                controller: _stockController,
                label: 'Stock actual',
                icon: Icons.warehouse_rounded,
                keyboardType: TextInputType.number,
                validator: _requiredInteger,
              ),
              const SizedBox(height: 14),
              _buildTextField(
                controller: _stockMinimoController,
                label: 'Stock mínimo',
                icon: Icons.warning_rounded,
                keyboardType: TextInputType.number,
                validator: _optionalInteger,
              ),
              const SizedBox(height: 14),
              _buildTextField(
                controller: _proveedorController,
                label: 'Proveedor',
                icon: Icons.local_shipping_rounded,
              ),
              const SizedBox(height: 14),
              _buildTextField(
                controller: _imagenController,
                label: 'URL de imagen',
                icon: Icons.image_rounded,
              ),
              const SizedBox(height: 14),
              SwitchListTile(
                value: _activo,
                onChanged: (value) {
                  setState(() {
                    _activo = value;
                  });
                },
                title: const Text(
                  'Producto activo',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  'Si está activo aparecerá en el catálogo público.',
                  style: TextStyle(color: Colors.white70),
                ),
                activeColor: Colors.amberAccent,
                tileColor: const Color(0xFF181820),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveProduct,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(
                    _isSaving
                        ? 'Guardando...'
                        : _isEditing
                            ? 'Actualizar producto'
                            : 'Guardar producto',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amberAccent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(
          icon,
          color: Colors.amberAccent,
        ),
        filled: true,
        fillColor: const Color(0xFF181820),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Colors.white12,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Colors.amberAccent,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Colors.redAccent,
          ),
        ),
      ),
    );
  }
}
