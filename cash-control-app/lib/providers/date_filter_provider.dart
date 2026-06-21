import 'package:flutter/material.dart';

enum DateFilterType {
  all,
  day,
  month,
  year,
}

class DateFilterProvider extends ChangeNotifier {
  DateFilterType filterType = DateFilterType.all;

  DateTime selectedDate = DateTime.now();

  String get filterTitle {
    switch (filterType) {
      case DateFilterType.all:
        return "Todo el historial";

      case DateFilterType.day:
        return "Día seleccionado";

      case DateFilterType.month:
        return "Mes seleccionado";

      case DateFilterType.year:
        return "Año seleccionado";
    }
  }

  String get filterDescription {
    switch (filterType) {
      case DateFilterType.all:
        return "Mostrando todos los movimientos";

      case DateFilterType.day:
        return "Mostrando movimientos del ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";

      case DateFilterType.month:
        return "Mostrando movimientos de ${selectedDate.month}/${selectedDate.year}";

      case DateFilterType.year:
        return "Mostrando movimientos del año ${selectedDate.year}";
    }
  }

  void setAll() {
    filterType = DateFilterType.all;
    notifyListeners();
  }

  void setDay(
    DateTime date,
  ) {
    selectedDate = date;
    filterType = DateFilterType.day;
    notifyListeners();
  }

  void setMonth(
    DateTime date,
  ) {
    selectedDate = date;
    filterType = DateFilterType.month;
    notifyListeners();
  }

  void setYear(
    DateTime date,
  ) {
    selectedDate = date;
    filterType = DateFilterType.year;
    notifyListeners();
  }

  DateTime get startDate {
    switch (filterType) {
      case DateFilterType.all:
        return DateTime(2000, 1, 1);

      case DateFilterType.day:
        return DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
        );

      case DateFilterType.month:
        return DateTime(
          selectedDate.year,
          selectedDate.month,
          1,
        );

      case DateFilterType.year:
        return DateTime(
          selectedDate.year,
          1,
          1,
        );
    }
  }

  DateTime get endDate {
    switch (filterType) {
      case DateFilterType.all:
        return DateTime(2100, 12, 31, 23, 59, 59);

      case DateFilterType.day:
        return DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          23,
          59,
          59,
        );

      case DateFilterType.month:
        return DateTime(
          selectedDate.year,
          selectedDate.month + 1,
          0,
          23,
          59,
          59,
        );

      case DateFilterType.year:
        return DateTime(
          selectedDate.year,
          12,
          31,
          23,
          59,
          59,
        );
    }
  }

  DateTime getTransactionDate(
    dynamic tx,
  ) {
    final rawDate =
        tx["created_at"] ??
        tx["date"] ??
        tx["createdAt"];

    if (rawDate == null) {
      return DateTime.now();
    }

    return DateTime.tryParse(
          rawDate.toString(),
        ) ??
        DateTime.now();
  }

  bool isTransactionInsideFilter(
    dynamic tx,
  ) {
    final date = getTransactionDate(
      tx,
    );

    return date.isAfter(
          startDate.subtract(
            const Duration(seconds: 1),
          ),
        ) &&
        date.isBefore(
          endDate.add(
            const Duration(seconds: 1),
          ),
        );
  }

  List<dynamic> filterTransactions(
    List<dynamic> transactions,
  ) {
    if (filterType == DateFilterType.all) {
      return transactions;
    }

    return transactions.where(
      (tx) {
        return isTransactionInsideFilter(
          tx,
        );
      },
    ).toList();
  }

  double getIncome(
    List<dynamic> transactions,
  ) {
    double total = 0;

    for (final tx in transactions) {
      if (tx["type"] == "income") {
        total += (tx["amount"] as num).toDouble();
      }
    }

    return total;
  }

  double getExpenses(
    List<dynamic> transactions,
  ) {
    double total = 0;

    for (final tx in transactions) {
      if (tx["type"] != "income") {
        total += (tx["amount"] as num).toDouble();
      }
    }

    return total;
  }

  double getBalance(
    List<dynamic> transactions,
  ) {
    return getIncome(transactions) -
        getExpenses(transactions);
  }
}