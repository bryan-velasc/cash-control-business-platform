import 'package:flutter/material.dart';

import '../services/global_market_service.dart';

class GlobalMarketScreen extends StatefulWidget {
  const GlobalMarketScreen({
    super.key,
  });

  @override
  State<GlobalMarketScreen> createState() =>
      _GlobalMarketScreenState();
}

class _GlobalMarketScreenState
    extends State<GlobalMarketScreen> {
  bool loading = true;

  Map<String, dynamic> crypto = {};
  Map<String, dynamic> exchange = {};
  List<Map<String, dynamic>> stocks = [];

  @override
  void initState() {
    super.initState();
    loadMarketData();
  }

  Future<void> loadMarketData() async {
    if (!mounted) return;

    setState(() {
      loading = true;
    });

    try {
      final cryptoData =
          await GlobalMarketService.getCryptoPrices();

      final exchangeData =
          await GlobalMarketService.getExchangeRates();

      final stockData =
          await GlobalMarketService.getPopularStocks();

      if (!mounted) return;

      setState(() {
        crypto = cryptoData;
        exchange = exchangeData;
        stocks = stockData;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error al cargar mercado: $e",
          ),
        ),
      );
    }
  }

  double parseDouble(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value.toString().replaceAll("%", ""),
        ) ??
        0;
  }

  String formatMoney(
    double value, {
    String symbol = "\$",
  }) {
    return "$symbol${value.toStringAsFixed(2)}";
  }

  Color getChangeColor(
    double value,
  ) {
    if (value > 0) {
      return Colors.greenAccent;
    }

    if (value < 0) {
      return Colors.redAccent;
    }

    return Colors.white54;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Mercado Global"),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: "Actualizar",
            onPressed: loading ? null : loadMarketData,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
        ],
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.greenAccent,
              ),
            )
          : RefreshIndicator(
              onRefresh: loadMarketData,
              child: SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    buildHeader(),

                    const SizedBox(height: 22),

                    buildCryptoSection(),

                    const SizedBox(height: 22),

                    buildExchangeSection(),

                    const SizedBox(height: 22),

                    buildStocksSection(),

                    const SizedBox(height: 22),

                    buildWarningCard(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [
            Colors.greenAccent,
            Colors.tealAccent,
          ],
        ),
      ),
      child: const Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.public_rounded,
            color: Colors.black,
            size: 48,
          ),
          SizedBox(height: 14),
          Text(
            "Mercado Global",
            style: TextStyle(
              color: Colors.black,
              fontSize: 27,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Consulta criptomonedas, divisas y acciones populares en una sola pantalla.",
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCryptoSection() {
    final items = [
      {
        "id": "bitcoin",
        "name": "Bitcoin",
        "symbol": "BTC",
      },
      {
        "id": "ethereum",
        "name": "Ethereum",
        "symbol": "ETH",
      },
      {
        "id": "solana",
        "name": "Solana",
        "symbol": "SOL",
      },
      {
        "id": "dogecoin",
        "name": "Dogecoin",
        "symbol": "DOGE",
      },
    ];

    return buildSectionCard(
      title: "Criptomonedas",
      icon: Icons.currency_bitcoin_rounded,
      color: Colors.orangeAccent,
      child: Column(
        children: items.map(
          (item) {
            final id = item["id"].toString();

            final data = crypto[id] ?? {};

            final usd = parseDouble(
              data["usd"],
            );

            final mxn = parseDouble(
              data["mxn"],
            );

            final change = parseDouble(
              data["usd_24h_change"],
            );

            return buildMarketRow(
              title: item["name"].toString(),
              subtitle:
                  "${item["symbol"]} • 24h ${change.toStringAsFixed(2)}%",
              value: formatMoney(
                usd,
                symbol: "\$",
              ),
              secondary:
                  "≈ ${formatMoney(mxn, symbol: "\$")} MXN",
              icon: Icons.currency_bitcoin_rounded,
              color: getChangeColor(
                change,
              ),
            );
          },
        ).toList(),
      ),
    );
  }

  Widget buildExchangeSection() {
    final rates =
        Map<String, dynamic>.from(
      exchange["rates"] ?? {},
    );

    final items = [
      "MXN",
      "EUR",
      "GBP",
      "JPY",
      "CAD",
    ];

    return buildSectionCard(
      title: "Divisas",
      icon: Icons.currency_exchange_rounded,
      color: Colors.cyanAccent,
      child: Column(
        children: items.map(
          (currency) {
            final value = parseDouble(
              rates[currency],
            );

            return buildMarketRow(
              title: "USD / $currency",
              subtitle:
                  "Tipo de cambio referencia",
              value: value.toStringAsFixed(4),
              secondary:
                  "1 USD = ${value.toStringAsFixed(4)} $currency",
              icon: Icons.attach_money_rounded,
              color: Colors.cyanAccent,
            );
          },
        ).toList(),
      ),
    );
  }

  Widget buildStocksSection() {
    return buildSectionCard(
      title: "Acciones populares",
      icon: Icons.show_chart_rounded,
      color: Colors.greenAccent,
      child: Column(
        children: stocks.map(
          (stock) {
            final symbol =
                stock["symbol"]?.toString() ?? "";

            final price = parseDouble(
              stock["price"],
            );

            final change = parseDouble(
              stock["change_percent"],
            );

            final hasError =
                stock["error"] != null;

            return buildMarketRow(
              title: symbol,
              subtitle: hasError
                  ? stock["error"].toString()
                  : "Cambio ${change.toStringAsFixed(2)}%",
              value: formatMoney(
                price,
                symbol: "\$",
              ),
              secondary:
                  "Mercado USA",
              icon: Icons.trending_up_rounded,
              color: hasError
                  ? Colors.white54
                  : getChangeColor(
                      change,
                    ),
            );
          },
        ).toList(),
      ),
    );
  }

  Widget buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: color.withOpacity(0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 32,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget buildMarketRow({
    required String title,
    required String subtitle,
    required String value,
    required String secondary,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withOpacity(0.22),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 28,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                secondary,
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildWarningCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.amberAccent.withOpacity(0.25),
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.amberAccent,
            size: 42,
          ),
          SizedBox(height: 10),
          Text(
            "Aviso importante",
            style: TextStyle(
              color: Colors.amberAccent,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Esta sección es informativa. No representa asesoría financiera profesional ni recomendación directa de compra o venta.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}