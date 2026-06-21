import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_keys.dart';

class GlobalMarketService {
  static Future<Map<String, dynamic>> getCryptoPrices() async {
    final uri = Uri.parse(
      "https://api.coingecko.com/api/v3/simple/price"
      "?ids=bitcoin,ethereum,solana,dogecoin"
      "&vs_currencies=usd,mxn"
      "&include_24hr_change=true",
    );

    final response = await http.get(
      uri,
      headers: {
        "accept": "application/json",
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Error al cargar criptomonedas",
      );
    }

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getExchangeRates() async {
    final uri = Uri.parse(
      "https://api.frankfurter.dev/v1/latest"
      "?base=USD"
      "&symbols=MXN,EUR,GBP,JPY,CAD",
    );

    final response = await http.get(
      uri,
      headers: {
        "accept": "application/json",
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Error al cargar divisas",
      );
    }

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getStockQuote(
    String symbol,
  ) async {
    final uri = Uri.parse(
      "https://www.alphavantage.co/query"
      "?function=GLOBAL_QUOTE"
      "&symbol=$symbol"
      "&apikey=${ApiKeys.alphaVantageKey}",
    );

    final response = await http.get(
      uri,
      headers: {
        "accept": "application/json",
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Error al cargar acción $symbol",
      );
    }

    final data = jsonDecode(response.body);

    if (data["Global Quote"] == null ||
        data["Global Quote"].isEmpty) {
      return {
        "symbol": symbol,
        "price": 0.0,
        "change_percent": "0%",
        "error": "Sin datos o límite de API alcanzado",
      };
    }

    final quote = data["Global Quote"];

    return {
      "symbol": symbol,
      "price": double.tryParse(
            quote["05. price"]?.toString() ?? "0",
          ) ??
          0.0,
      "change_percent":
          quote["10. change percent"]?.toString() ??
              "0%",
      "raw": quote,
    };
  }

  static Future<List<Map<String, dynamic>>> getPopularStocks() async {
    final symbols = [
      "AAPL",
      "MSFT",
      "GOOGL",
      "TSLA",
    ];

    final List<Map<String, dynamic>> result = [];

    for (final symbol in symbols) {
      try {
        final quote = await getStockQuote(
          symbol,
        );

        result.add(
          quote,
        );
      } catch (_) {
        result.add({
          "symbol": symbol,
          "price": 0.0,
          "change_percent": "0%",
          "error": "No disponible",
        });
      }
    }

    return result;
  }
}