import 'package:flutter/material.dart';

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
        children: const [
          _BusinessIntroCard(),
          SizedBox(height: 16),
          _BusinessMenuCard(
            title: 'Productos',
            subtitle: 'Administra catálogo, precios y stock.',
            icon: Icons.inventory_2_outlined,
          ),
          _BusinessMenuCard(
            title: 'Inventario',
            subtitle: 'Registra entradas, salidas y ajustes.',
            icon: Icons.storefront_outlined,
          ),
          _BusinessMenuCard(
            title: 'Clientes',
            subtitle: 'Controla clientes y datos de contacto.',
            icon: Icons.people_alt_outlined,
          ),
          _BusinessMenuCard(
            title: 'Fiados',
            subtitle: 'Consulta deudas, abonos y saldos pendientes.',
            icon: Icons.receipt_long_outlined,
          ),
        ],
      ),
    );
  }
}

class _BusinessIntroCard extends StatelessWidget {
  const _BusinessIntroCard();

  @override
  Widget build(BuildContext context) {
    return Card(
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

  const _BusinessMenuCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.chevron_right),
      ),
    );
  }
}