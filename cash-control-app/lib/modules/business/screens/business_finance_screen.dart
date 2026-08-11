import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/business_finance_model.dart';
import '../services/business_finance_service.dart';

class BusinessFinanceScreen extends StatefulWidget {
  const BusinessFinanceScreen({super.key});

  @override
  State<BusinessFinanceScreen> createState() => _BusinessFinanceScreenState();
}

class _BusinessFinanceScreenState extends State<BusinessFinanceScreen> {
  bool _loading = true;
  String? _error;

  BusinessFinanceModel? _summary;
  BusinessFinanceTimelineModel? _timeline;
  BusinessTopProductsModel? _topProducts;

  String _period = 'all';

  DateTime? _dateFrom;
  DateTime? _dateTo;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final groupBy = _getGroupBy();

      final results = await Future.wait([
        BusinessFinanceService.getSummary(
          period: _period,
          dateFrom: _dateFrom,
          dateTo: _dateTo,
        ),
        BusinessFinanceService.getTimeline(
          period: _period,
          groupBy: groupBy,
          dateFrom: _dateFrom,
          dateTo: _dateTo,
        ),
        BusinessFinanceService.getTopProducts(
          period: _period,
          limit: 5,
          dateFrom: _dateFrom,
          dateTo: _dateTo,
        ),
      ]);

      if (!mounted) return;

      setState(() {
        _summary = results[0] as BusinessFinanceModel;
        _timeline = results[1] as BusinessFinanceTimelineModel;
        _topProducts = results[2] as BusinessTopProductsModel;
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

  String _getGroupBy() {
    switch (_period) {
      case 'today':
      case 'week':
      case 'month':
        return 'day';

      case 'custom':
        if (_dateFrom != null && _dateTo != null) {
          final difference = _dateTo!.difference(_dateFrom!).inDays;

          if (difference <= 31) {
            return 'day';
          }

          if (difference <= 180) {
            return 'week';
          }

          return 'month';
        }

        return 'day';

      case 'all':
      default:
        return 'month';
    }
  }

  Future<void> _changePeriod(String period) async {
    if (period == 'custom') {
      await _selectCustomPeriod();
      return;
    }

    setState(() {
      _period = period;
      _dateFrom = null;
      _dateTo = null;
    });

    await _loadSummary();
  }

  Future<void> _selectCustomPeriod() async {
    final now = DateTime.now();

    final initialStart = _dateFrom ?? DateTime(now.year, now.month, 1);

    final start = await showDatePicker(
      context: context,
      initialDate: initialStart,
      firstDate: DateTime(2020),
      lastDate: now,
      helpText: 'Fecha inicial',
    );

    if (start == null) return;

    if (!mounted) return;

    final initialEnd = _dateTo ?? now;

    final end = await showDatePicker(
      context: context,
      initialDate: initialEnd.isBefore(start) ? start : initialEnd,
      firstDate: start,
      lastDate: now,
      helpText: 'Fecha final',
    );

    if (end == null) return;

    final endExclusive = DateTime(
      end.year,
      end.month,
      end.day,
    ).add(const Duration(days: 1));

    setState(() {
      _period = 'custom';
      _dateFrom = DateTime(start.year, start.month, start.day);
      _dateTo = endExclusive;
    });

    await _loadSummary();
  }

  String _money(double value) {
    final prefix = value < 0 ? '-\$' : '\$';

    return '$prefix${value.abs().toStringAsFixed(2)}';
  }

  String _percent(double value) {
    return '${value.toStringAsFixed(2)}%';
  }

  String _periodTitle() {
    switch (_period) {
      case 'today':
        return 'Hoy';

      case 'week':
        return 'Esta semana';

      case 'month':
        return 'Este mes';

      case 'custom':
        if (_dateFrom != null && _dateTo != null) {
          final inclusiveEnd = _dateTo!.subtract(const Duration(days: 1));

          return '${_shortDate(_dateFrom!)} - '
              '${_shortDate(inclusiveEnd)}';
        }

        return 'Personalizado';

      default:
        return 'Todo el historial';
    }
  }

  String _shortDate(DateTime date) {
    String two(int value) {
      return value.toString().padLeft(2, '0');
    }

    return '${two(date.day)}/'
        '${two(date.month)}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumen Financiero'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: _loading ? null : _loadSummary,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildPeriodSelector(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Material(
      elevation: 1,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          children: [
            _PeriodChip(
              label: 'Hoy',
              selected: _period == 'today',
              onTap: () {
                _changePeriod('today');
              },
            ),
            const SizedBox(width: 8),
            _PeriodChip(
              label: 'Semana',
              selected: _period == 'week',
              onTap: () {
                _changePeriod('week');
              },
            ),
            const SizedBox(width: 8),
            _PeriodChip(
              label: 'Mes',
              selected: _period == 'month',
              onTap: () {
                _changePeriod('month');
              },
            ),
            const SizedBox(width: 8),
            _PeriodChip(
              label: 'Todo',
              selected: _period == 'all',
              onTap: () {
                _changePeriod('all');
              },
            ),
            const SizedBox(width: 8),
            _PeriodChip(
              label: 'Personalizado',
              selected: _period == 'custom',
              icon: Icons.date_range_outlined,
              onTap: _selectCustomPeriod,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 56),
              const SizedBox(height: 16),
              const Text(
                'No se pudo cargar el resumen financiero.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: _loadSummary,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    final summary = _summary;

    if (summary == null) {
      return const Center(
        child: Text('No hay información financiera disponible.'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSummary,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Text(
            _periodTitle(),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          _buildHeader(summary),

          const SizedBox(height: 20),

          const _SectionTitle(
            title: 'Resultados del negocio',
            icon: Icons.account_balance_wallet_outlined,
          ),

          const SizedBox(height: 10),

          _buildFinancialGrid(summary),

          const SizedBox(height: 24),

          const _SectionTitle(
            title: 'Evolución financiera',
            icon: Icons.show_chart,
          ),

          const SizedBox(height: 10),

          _buildFinancialChart(),

          const SizedBox(height: 24),

          const _SectionTitle(
            title: 'Productos más vendidos',
            icon: Icons.emoji_events_outlined,
          ),

          const SizedBox(height: 10),

          _buildTopProducts(),

          const SizedBox(height: 24),

          const _SectionTitle(title: 'Rentabilidad', icon: Icons.trending_up),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'ROI',
                  value: _percent(summary.roi),
                  icon: Icons.show_chart,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricCard(
                  title: 'Margen bruto',
                  value: _percent(summary.margenBruto),
                  icon: Icons.percent,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          _MetricCard(
            title: 'Margen neto',
            value: _percent(summary.margenNeto),
            icon: Icons.analytics_outlined,
          ),

          const SizedBox(height: 24),

          const _SectionTitle(
            title: 'Capital y flujo',
            icon: Icons.payments_outlined,
          ),

          const SizedBox(height: 10),

          _InformationCard(
            icon: Icons.shopping_cart_checkout_outlined,
            title: 'Compras / Reinversión',
            value: _money(summary.totalReinversion),
            subtitle: '${summary.numeroCompras} compras en el período',
          ),

          _InformationCard(
            icon: Icons.receipt_long_outlined,
            title: 'Cuentas por cobrar',
            value: _money(summary.cuentasPorCobrar),
            subtitle: 'Saldo pendiente actual',
          ),

          const SizedBox(height: 24),

          const _SectionTitle(
            title: 'Inventario actual',
            icon: Icons.inventory_2_outlined,
          ),

          const SizedBox(height: 10),

          _InformationCard(
            icon: Icons.attach_money,
            title: 'Valor a costo',
            value: _money(summary.valorInventarioCosto),
            subtitle: 'Capital actual en mercancía',
          ),

          _InformationCard(
            icon: Icons.sell_outlined,
            title: 'Valor potencial de venta',
            value: _money(summary.valorInventarioVenta),
            subtitle: 'Valor del stock a precio de venta',
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _CounterCard(
                  title: 'Productos',
                  value: summary.productosActivos.toString(),
                  subtitle: 'activos',
                  icon: Icons.category_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CounterCard(
                  title: 'Unidades',
                  value: summary.unidadesInventario.toString(),
                  subtitle: 'en inventario',
                  icon: Icons.inventory_outlined,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          const _SectionTitle(title: 'Actividad', icon: Icons.query_stats),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _CounterCard(
                  title: 'Ventas',
                  value: summary.numeroVentas.toString(),
                  subtitle: 'en el período',
                  icon: Icons.point_of_sale,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CounterCard(
                  title: 'Gastos',
                  value: summary.numeroGastos.toString(),
                  subtitle: 'en el período',
                  icon: Icons.money_off_csred_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BusinessFinanceModel summary) {
    final profitable = summary.utilidadNeta >= 0;

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.insights_outlined, size: 32),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Estado financiero',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text('Utilidad neta'),
            const SizedBox(height: 4),
            Text(
              _money(summary.utilidadNeta),
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: profitable ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  profitable ? Icons.trending_up : Icons.trending_down,
                  size: 20,
                  color: profitable ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    profitable
                        ? 'El resultado neto del período es positivo.'
                        : 'Los costos y gastos del período superan la utilidad generada.',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialGrid(BusinessFinanceModel summary) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'Ventas',
                value: _money(summary.totalVentas),
                icon: Icons.point_of_sale_outlined,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricCard(
                title: 'Costo vendido',
                value: _money(summary.costoMercanciaVendida),
                icon: Icons.inventory_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'Utilidad bruta',
                value: _money(summary.utilidadBruta),
                icon: Icons.trending_up,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricCard(
                title: 'Gastos',
                value: _money(summary.totalGastos),
                icon: Icons.money_off_csred_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFinancialChart() {
    final timeline = _timeline;

    if (timeline == null || timeline.puntos.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Text(
              'Todavía no hay movimientos suficientes '
              'para generar la gráfica.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final points = timeline.puntos;

    double maxValue = 0;

    for (final point in points) {
      final values = [point.ventas, point.gastos, point.utilidadNeta.abs()];

      for (final value in values) {
        if (value > maxValue) {
          maxValue = value;
        }
      }
    }

    if (maxValue <= 0) {
      maxValue = 100;
    }

    maxValue *= 1.20;

    final ventasSpots = <FlSpot>[];
    final gastosSpots = <FlSpot>[];
    final utilidadSpots = <FlSpot>[];

    for (var i = 0; i < points.length; i++) {
      final point = points[i];

      ventasSpots.add(FlSpot(i.toDouble(), point.ventas));

      gastosSpots.add(FlSpot(i.toDouble(), point.gastos));

      utilidadSpots.add(FlSpot(i.toDouble(), point.utilidadNeta));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 18, 18, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _ChartLegend(),

            const SizedBox(height: 20),

            SizedBox(
              height: 280,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: (points.length - 1).toDouble(),
                  minY: _minimumChartValue(points),
                  maxY: maxValue,

                  gridData: const FlGridData(show: true),

                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),

                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 55,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            _compactMoney(value),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        interval: _bottomInterval(points.length),
                        getTitlesWidget: (value, meta) {
                          final index = value.round();

                          if (index < 0 || index >= points.length) {
                            return const SizedBox.shrink();
                          }

                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              _chartLabel(points[index].periodo),
                              style: const TextStyle(fontSize: 9),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          String label;

                          switch (spot.barIndex) {
                            case 0:
                              label = 'Ventas';
                              break;

                            case 1:
                              label = 'Gastos';
                              break;

                            default:
                              label = 'Utilidad';
                          }

                          return LineTooltipItem(
                            '$label\n'
                            '${_money(spot.y)}',
                            const TextStyle(fontWeight: FontWeight.bold),
                          );
                        }).toList();
                      },
                    ),
                  ),

                  lineBarsData: [
                    LineChartBarData(
                      spots: ventasSpots,
                      isCurved: true,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: gastosSpots,
                      isCurved: true,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: utilidadSpots,
                      isCurved: true,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _minimumChartValue(List<BusinessFinanceTimelinePoint> points) {
    double minValue = 0;

    for (final point in points) {
      if (point.utilidadNeta < minValue) {
        minValue = point.utilidadNeta;
      }
    }

    if (minValue < 0) {
      return minValue * 1.20;
    }

    return 0;
  }

  double _bottomInterval(int count) {
    if (count <= 7) {
      return 1;
    }

    if (count <= 15) {
      return 2;
    }

    if (count <= 31) {
      return 5;
    }

    return (count / 6).ceilToDouble();
  }

  String _compactMoney(double value) {
    final absolute = value.abs();

    String formatted;

    if (absolute >= 1000000) {
      formatted = '${(absolute / 1000000).toStringAsFixed(1)}M';
    } else if (absolute >= 1000) {
      formatted = '${(absolute / 1000).toStringAsFixed(1)}k';
    } else {
      formatted = absolute.toStringAsFixed(0);
    }

    return value < 0 ? '-\$$formatted' : '\$$formatted';
  }

  String _chartLabel(String value) {
    if (value.length >= 10 && value.contains('-')) {
      final parts = value.split('-');

      if (parts.length >= 3) {
        return '${parts[2]}/${parts[1]}';
      }
    }

    if (value.length == 7 && value.contains('-')) {
      final parts = value.split('-');

      return '${parts[1]}/'
          '${parts[0].substring(2)}';
    }

    return value;
  }

  Widget _buildTopProducts() {
    final topProducts = _topProducts;

    if (topProducts == null || topProducts.productos.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Text(
              'Todavía no hay ventas suficientes '
              'para generar el ranking.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Card(
      child: Column(
        children: [
          for (var i = 0; i < topProducts.productos.length; i++)
            _TopProductTile(
              position: i + 1,
              product: topProducts.productos[i],
              moneyFormatter: _money,
            ),
        ],
      ),
    );
  }
}

class _ChartLegend extends StatelessWidget {
  const _ChartLegend();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _LegendItem(icon: Icons.point_of_sale_outlined, label: 'Ventas'),
        _LegendItem(icon: Icons.money_off_csred_outlined, label: 'Gastos'),
        _LegendItem(icon: Icons.trending_up, label: 'Utilidad neta'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _LegendItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [Icon(icon, size: 17), const SizedBox(width: 5), Text(label)],
    );
  }
}

class _TopProductTile extends StatelessWidget {
  final int position;
  final BusinessTopProductModel product;
  final String Function(double) moneyFormatter;

  const _TopProductTile({
    required this.position,
    required this.product,
    required this.moneyFormatter,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(
          position.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(
        product.nombre,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        '${product.unidadesVendidas} unidades vendidas\n'
        'Ventas: ${moneyFormatter(product.ventas)}',
      ),
      isThreeLine: true,
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text('Utilidad', style: TextStyle(fontSize: 11)),
          const SizedBox(height: 2),
          Text(
            moneyFormatter(product.utilidadBruta),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: product.utilidadBruta >= 0 ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  const _PeriodChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      selected: selected,
      onSelected: (_) {
        onTap();
      },
      avatar: icon == null ? null : Icon(icon, size: 18),
      label: Text(label),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 3),
            Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class _InformationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;

  const _InformationCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _CounterCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  const _CounterCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Icon(icon, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
