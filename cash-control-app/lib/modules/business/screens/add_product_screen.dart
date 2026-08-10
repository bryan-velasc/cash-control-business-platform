import 'package:flutter/material.dart';

import '../services/product_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _categoriaController = TextEditingController();
  final _precioController = TextEditingController();
  final _precioCompraController = TextEditingController();
  final _stockController = TextEditingController();
  final _stockMinimoController = TextEditingController();
  final _proveedorController = TextEditingController();
  final _imagenController = TextEditingController();

  bool _activo = true;
  bool _isSaving = false;

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
      await ProductService.createProduct(
        nombre: _nombreController.text.trim(),
        categoria: _categoriaController.text.trim(),
        precio: double.parse(_precioController.text.trim()),
        imagen: _imagenController.text.trim(),
        stock: int.parse(_stockController.text.trim()),
        activo: _activo,
        precioCompra: _precioCompraController.text.trim().isEmpty
            ? null
            : double.parse(_precioCompraController.text.trim()),
        proveedor: _proveedorController.text.trim().isEmpty
            ? null
            : _proveedorController.text.trim(),
        stockMinimo: _stockMinimoController.text.trim().isEmpty
            ? 0
            : int.parse(_stockMinimoController.text.trim()),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto creado correctamente')),
      );

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear producto: $error')),
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

    final number = double.tryParse(value.trim());

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

    final number = double.tryParse(value.trim());

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
    return Scaffold(
      backgroundColor: const Color(0xFF101014),
      appBar: AppBar(
        title: const Text('Agregar producto'),
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
                keyboardType: TextInputType.number,
                validator: _requiredNumber,
              ),
              const SizedBox(height: 14),
              _buildTextField(
                controller: _precioCompraController,
                label: 'Precio de compra',
                icon: Icons.shopping_cart_rounded,
                keyboardType: TextInputType.number,
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
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(_isSaving ? 'Guardando...' : 'Guardar producto'),
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
        prefixIcon: Icon(icon, color: Colors.amberAccent),
        filled: true,
        fillColor: const Color(0xFF181820),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.amberAccent),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }
}
