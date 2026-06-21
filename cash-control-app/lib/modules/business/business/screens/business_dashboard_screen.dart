import 'package:flutter/material.dart';

import 'products_screen.dart';

class BusinessDashboardScreen extends StatelessWidget {
  const BusinessDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Negocio'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _BusinessIntroCard(),
          const SizedBox(height: 16),
          _BusinessMenuCard(
            title: 'Productos',
            subtitle: 'Administra catálogo, precios y stock.',
            icon: Icons.inventory_2_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProductsScreen(),
                ),
              );
            },
          ),
          _BusinessMenuCard(
            title: 'Inventario',
            subtitle: 'Registra entradas, salidas y ajustes.',
            icon: Icons.storefront_outlined,
            onTap: () => _showPending(context, 'Inventario'),
          ),
          _BusinessMenuCard(
            title: 'Clientes',
            subtitle: 'Controla clientes y datos de contacto.',
            icon: Icons.people_alt_outlined,
            onTap: () => _showPending(context, 'Clientes'),
          ),
          _BusinessMenuCard(
            title: 'Fiados',
            subtitle: 'Consulta deudas, abonos y saldos pendientes.',
            icon: Icons.receipt_long_outlined,
            onTap: () => _showPending(context, 'Fiados'),
          ),
        ],
      ),
    );
  }

  void _showPending(BuildContext context, String module) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$module se implementará en la siguiente fase.'),
      ),
    );
  }
}

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
            Icon(
              Icons.business_center_outlined,
              size: 42,
            ),
            SizedBox(height: 12),
            Text(
              'Panel Mi Negocio',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Este módulo conectará Cash Control con productos, inventario, clientes, fiados y abonos.',
            ),
          ],
        ),
      ),
    );
  }
}

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
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}