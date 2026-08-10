import 'package:flutter/material.dart';

import '../models/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onStock;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onEdit,
    this.onStock,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final bool isLowStock =
        product.stockMinimo != null && product.stock <= product.stockMinimo!;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProductImage(imagePath: product.imagen),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.nombre,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.categoria,
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _InfoChip(
                          icon: Icons.attach_money,
                          label: '\$${product.precio.toStringAsFixed(2)}',
                        ),
                        _InfoChip(
                          icon: Icons.inventory_2_outlined,
                          label: 'Stock: ${product.stock}',
                          isWarning: isLowStock,
                        ),
                        _InfoChip(
                          icon: product.activo
                              ? Icons.check_circle_outline
                              : Icons.cancel_outlined,
                          label: product.activo ? 'Activo' : 'Inactivo',
                          isDisabled: !product.activo,
                        ),
                      ],
                    ),
                    if (product.proveedor != null &&
                        product.proveedor!.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Proveedor: ${product.proveedor}',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit?.call();
                  }

                  if (value == 'stock') {
                    onStock?.call();
                  }
                },
                itemBuilder: (context) {
                  return const [
                    PopupMenuItem(value: 'edit', child: Text('Editar')),
                    PopupMenuItem(value: 'stock', child: Text('Ajustar stock')),
                  ];
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  final String imagePath;

  const _ProductImage({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (imagePath.trim().isEmpty) {
      return _PlaceholderImage(colorScheme: colorScheme);
    }

    if (imagePath.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imagePath,
          width: 72,
          height: 72,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return _PlaceholderImage(colorScheme: colorScheme);
          },
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        imagePath,
        width: 72,
        height: 72,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return _PlaceholderImage(colorScheme: colorScheme);
        },
      ),
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  final ColorScheme colorScheme;

  const _PlaceholderImage({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.shopping_bag_outlined,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isWarning;
  final bool isDisabled;

  const _InfoChip({
    required this.icon,
    required this.label,
    this.isWarning = false,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Theme.of(
      context,
    ).colorScheme.surfaceContainerHighest;
    Color foregroundColor = Theme.of(context).colorScheme.onSurfaceVariant;

    if (isWarning) {
      backgroundColor = Colors.orange.shade100;
      foregroundColor = Colors.orange.shade900;
    }

    if (isDisabled) {
      backgroundColor = Colors.red.shade100;
      foregroundColor = Colors.red.shade900;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: foregroundColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: foregroundColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
