import '../models/credit_model.dart';
import '../models/customer_model.dart';
import '../models/product_model.dart';
import '../models/stock_movement_model.dart';
import 'credit_service.dart';
import 'customer_service.dart';
import 'inventory_service.dart';
import 'product_service.dart';

class BusinessDashboardData {
  final List<ProductModel> products;
  final List<ProductModel> lowStockProducts;
  final List<CustomerModel> customers;
  final List<CreditModel> credits;
  final List<StockMovementModel> recentMovements;

  const BusinessDashboardData({
    required this.products,
    required this.lowStockProducts,
    required this.customers,
    required this.credits,
    required this.recentMovements,
  });

  int get totalProducts => products.length;

  int get activeProducts {
    return products.where((product) => product.activo).length;
  }

  int get totalCustomers => customers.length;

  int get activeCustomers {
    return customers.where((customer) => customer.activo).length;
  }

  int get activeCredits {
    return credits
        .where(
          (credit) =>
              credit.estado == 'pendiente' || credit.estado == 'parcial',
        )
        .length;
  }

  int get paidCredits {
    return credits.where((credit) => credit.estado == 'pagado').length;
  }

  double get totalPendingAmount {
    return credits.fold<double>(
      0,
      (total, credit) => total + credit.saldoPendiente,
    );
  }

  double get totalCreditAmount {
    return credits.fold<double>(
      0,
      (total, credit) => total + credit.montoTotal,
    );
  }

  double get totalPaidAmount {
    return credits.fold<double>(
      0,
      (total, credit) => total + credit.montoPagado,
    );
  }
}

class BusinessDashboardService {
  static Future<BusinessDashboardData> getDashboardData() async {
    final results = await Future.wait([
      ProductService.getAdminProducts(),
      InventoryService.getLowStockProducts(),
      CustomerService.getCustomers(),
      CreditService.getCredits(),
      InventoryService.getHistory(limit: 10),
    ]);

    return BusinessDashboardData(
      products: results[0] as List<ProductModel>,
      lowStockProducts: results[1] as List<ProductModel>,
      customers: results[2] as List<CustomerModel>,
      credits: results[3] as List<CreditModel>,
      recentMovements: results[4] as List<StockMovementModel>,
    );
  }
}