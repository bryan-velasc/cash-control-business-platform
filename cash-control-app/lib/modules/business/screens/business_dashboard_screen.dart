import 'package:flutter/material.dart';

import 'products_screen.dart';
import 'inventory_screen.dart';
import 'sales_screen.dart';
import 'suppliers_screen.dart';
import 'purchases_screen.dart';
import 'expenses_screen.dart';
import 'customers_screen.dart';
import 'credits_screen.dart';
import 'business_finance_screen.dart';

class BusinessDashboardScreen extends StatelessWidget {
  const BusinessDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Negocio')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _BusinessIntroCard(),

          const SizedBox(height: 16),

          _BusinessMenuCard(
            title: 'Resumen Financiero',
            subtitle:
                'Consulta ventas, utilidad, gastos, reinversión, ROI e inventario.',
            icon: Icons.insights_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BusinessFinanceScreen(),
                ),
              );
            },
          ),

          // ============================================================
          // PRODUCTOS
          // ============================================================
          _BusinessMenuCard(
            title: 'Productos',
            subtitle: 'Administra catálogo, precios y stock.',
            icon: Icons.inventory_2_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProductsScreen()),
              );
            },
          ),

          // ============================================================
          // INVENTARIO
          // ============================================================
          _BusinessMenuCard(
            title: 'Inventario',
            subtitle: 'Registra entradas, salidas y ajustes.',
            icon: Icons.storefront_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InventoryScreen()),
              );
            },
          ),

          // ============================================================
          // VENTAS / CAJA
          // ============================================================
          _BusinessMenuCard(
            title: 'Ventas / Caja',
            subtitle: 'Registra ventas, cobros y consulta utilidades.',
            icon: Icons.point_of_sale_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SalesScreen()),
              );
            },
          ),

          // ============================================================
          // PROVEEDORES
          // ============================================================
          _BusinessMenuCard(
            title: 'Proveedores',
            subtitle: 'Administra contactos y compras por proveedor.',
            icon: Icons.local_shipping_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SuppliersScreen()),
              );
            },
          ),

          // ============================================================
          // COMPRAS / REINVERSIÓN
          // ============================================================
          _BusinessMenuCard(
            title: 'Compras / Reinversión',
            subtitle: 'Registra compras, costos y entradas de inventario.',
            icon: Icons.shopping_cart_checkout_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PurchasesScreen()),
              );
            },
          ),

          // ============================================================
          // GASTOS
          // ============================================================
          _BusinessMenuCard(
            title: 'Gastos',
            subtitle: 'Registra gastos operativos y consulta su impacto.',
            icon: Icons.money_off_csred_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ExpensesScreen()),
              );
            },
          ),

          // ============================================================
          // CLIENTES
          // ============================================================
          _BusinessMenuCard(
            title: 'Clientes',
            subtitle: 'Controla clientes y datos de contacto.',
            icon: Icons.people_alt_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CustomersScreen()),
              );
            },
          ),

          // ============================================================
          // FIADOS
          // ============================================================
          _BusinessMenuCard(
            title: 'Fiados',
            subtitle: 'Consulta deudas, abonos y saldos pendientes.',
            icon: Icons.receipt_long_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreditsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ======================================================================
// TARJETA PRINCIPAL
// ======================================================================

class _BusinessIntroCard extends StatelessWidget {
  const _BusinessIntroCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.business_center_outlined, size: 42),
            SizedBox(height: 12),
            Text(
              'Panel Mi Negocio',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Administra productos, inventario, ventas, caja, '
              'proveedores, compras, reinversión, gastos, clientes, '
              'fiados y abonos desde un solo lugar.',
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================================
// TARJETA DEL MENÚ
// ======================================================================

class _BusinessMenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _BusinessMenuCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, size: 28),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
