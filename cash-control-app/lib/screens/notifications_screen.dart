import 'package:flutter/material.dart';

import '../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  final String email;

  const NotificationsScreen({
    super.key,
    required this.email,
  });

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState
    extends State<NotificationsScreen> {
  List notifications = [];

  bool isLoading = true;

  String selectedFilter = "Todas";

  final List<String> filters = [
    "Todas",
    "No leídas",
    "Gastos",
    "Presupuestos",
    "Balance",
    "IA",
  ];

  @override
  void initState() {
    super.initState();

    loadNotifications();
  }

  Future<void> loadNotifications() async {
    setState(() {
      isLoading = true;
    });

    try {
      final data =
          await NotificationService.getNotifications(
        widget.email,
      );

      setState(() {
        notifications = data;
        isLoading = false;
      });
    } catch (e) {
      print("ERROR LOAD NOTIFICATIONS:");
      print(e);

      setState(() {
        isLoading = false;
      });

      showMessage(
        e.toString(),
      );
    }
  }

  List getFilteredNotifications() {
    if (selectedFilter == "Todas") {
      return notifications;
    }

    if (selectedFilter == "No leídas") {
      return notifications.where((notification) {
        return notification["read"] == false;
      }).toList();
    }

    if (selectedFilter == "Gastos") {
      return notifications.where((notification) {
        return notification["type"] == "expense_alert";
      }).toList();
    }

    if (selectedFilter == "Presupuestos") {
      return notifications.where((notification) {
        final type = notification["type"]?.toString() ?? "";

        return type == "budget_warning" ||
            type == "budget_exceeded";
      }).toList();
    }

    if (selectedFilter == "Balance") {
      return notifications.where((notification) {
        return notification["type"] == "negative_balance";
      }).toList();
    }

    if (selectedFilter == "IA") {
      return notifications.where((notification) {
        final type = notification["type"]?.toString() ?? "";

        return type.contains("ai") ||
            type.contains("ia");
      }).toList();
    }

    return notifications;
  }

  void showMessage(
    String message,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Future<void> markAsRead(
    String notificationId,
  ) async {
    try {
      await NotificationService.markAsRead(
        notificationId,
      );

      await loadNotifications();
    } catch (e) {
      showMessage(
        e.toString(),
      );
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await NotificationService.markAllAsRead(
        widget.email,
      );

      await loadNotifications();

      showMessage(
        "Todas las notificaciones fueron marcadas como leídas",
      );
    } catch (e) {
      showMessage(
        e.toString(),
      );
    }
  }

  Future<void> deleteNotification(
    String notificationId,
  ) async {
    try {
      await NotificationService.deleteNotification(
        notificationId,
      );

      await loadNotifications();

      showMessage(
        "Notificación eliminada",
      );
    } catch (e) {
      showMessage(
        e.toString(),
      );
    }
  }

  IconData getNotificationIcon(
    String type,
  ) {
    if (type == "expense_alert") {
      return Icons.warning_amber_rounded;
    }

    if (type == "negative_balance") {
      return Icons.trending_down;
    }

    if (type == "budget_warning") {
      return Icons.account_balance_wallet;
    }

    if (type == "budget_exceeded") {
      return Icons.error;
    }

    if (type.contains("ocr")) {
      return Icons.receipt_long;
    }

    if (type.contains("ai") || type.contains("ia")) {
      return Icons.smart_toy;
    }

    return Icons.notifications;
  }

  Color getNotificationColor(
    String type,
  ) {
    if (type == "expense_alert") {
      return Colors.orange;
    }

    if (type == "negative_balance") {
      return Colors.red;
    }

    if (type == "budget_warning") {
      return Colors.amber;
    }

    if (type == "budget_exceeded") {
      return Colors.redAccent;
    }

    if (type.contains("ocr")) {
      return Colors.greenAccent;
    }

    if (type.contains("ai") || type.contains("ia")) {
      return Colors.purpleAccent;
    }

    return Colors.blueAccent;
  }

  String getPriorityText(
    String type,
  ) {
    if (type == "negative_balance" ||
        type == "budget_exceeded") {
      return "ALTA";
    }

    if (type == "expense_alert" ||
        type == "budget_warning") {
      return "MEDIA";
    }

    return "NORMAL";
  }

  Widget buildFilterChips() {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(
          width: 8,
        ),
        itemBuilder: (context, index) {
          final filter = filters[index];

          final selected =
              selectedFilter == filter;

          return ChoiceChip(
            label: Text(
              filter,
            ),
            selected: selected,
            onSelected: (_) {
              setState(() {
                selectedFilter = filter;
              });
            },
            selectedColor: Colors.greenAccent,
            labelStyle: TextStyle(
              color: selected
                  ? Colors.black
                  : Colors.white,
              fontWeight: FontWeight.bold,
            ),
            backgroundColor: const Color(0xFF151515),
            side: BorderSide(
              color: selected
                  ? Colors.greenAccent
                  : Colors.white.withOpacity(0.15),
            ),
          );
        },
      ),
    );
  }

  Widget buildNotificationCard(
    dynamic notification,
  ) {
    final String notificationId =
        notification["id"]?.toString() ??
            notification["_id"]?.toString() ??
            "";

    final String title =
        notification["title"]?.toString() ??
            "Notificación";

    final String message =
        notification["message"]?.toString() ??
            "";

    final String type =
        notification["type"]?.toString() ??
            "general";

    final String createdAt =
        notification["created_at"]?.toString() ??
            "";

    final bool read =
        notification["read"] == true;

    final Color color =
        getNotificationColor(type);

    return Dismissible(
      key: ValueKey(
        notificationId,
      ),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(
          right: 24,
        ),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(
            22,
          ),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 32,
        ),
      ),
      onDismissed: (_) {
        if (notificationId.isNotEmpty) {
          deleteNotification(
            notificationId,
          );
        }
      },
      child: GestureDetector(
        onTap: () {
          if (!read &&
              notificationId.isNotEmpty) {
            markAsRead(
              notificationId,
            );
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 9,
          ),
          padding: const EdgeInsets.all(
            18,
          ),
          decoration: BoxDecoration(
            color: read
                ? const Color(0xFF151515)
                : const Color(0xFF1D1D1D),
            borderRadius: BorderRadius.circular(
              22,
            ),
            border: Border.all(
              color: read
                  ? Colors.white.withOpacity(0.08)
                  : color.withOpacity(0.7),
            ),
            boxShadow: [
              BoxShadow(
                color: read
                    ? Colors.black.withOpacity(0.12)
                    : color.withOpacity(0.15),
                blurRadius: 14,
                offset: const Offset(
                  0,
                  6,
                ),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(
                  13,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(
                    0.18,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),
                ),
                child: Icon(
                  getNotificationIcon(type),
                  color: color,
                  size: 30,
                ),
              ),

              const SizedBox(
                width: 14,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: read
                                  ? FontWeight.w600
                                  : FontWeight.bold,
                            ),
                          ),
                        ),

                        if (!read)
                          Container(
                            width: 9,
                            height: 9,
                            decoration:
                                const BoxDecoration(
                              color: Colors.greenAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Text(
                      message,
                      style: TextStyle(
                        color: Colors.white
                            .withOpacity(0.75),
                        fontSize: 14,
                        height: 1.35,
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    Row(
                      children: [
                        Container(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration:
                              BoxDecoration(
                            color:
                                color.withOpacity(
                              0.16,
                            ),
                            borderRadius:
                                BorderRadius
                                    .circular(
                              20,
                            ),
                          ),
                          child: Text(
                            getPriorityText(type),
                            style: TextStyle(
                              color: color,
                              fontSize: 11,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(
                          width: 10,
                        ),

                        Expanded(
                          child: Text(
                            createdAt,
                            overflow:
                                TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white
                                  .withOpacity(0.45),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(
          28,
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 92,
              color: Colors.greenAccent
                  .withOpacity(0.7),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "Sin notificaciones",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              "Cuando CASH-CONTROL detecte movimientos importantes, aparecerán aquí.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(
                  0.65,
                ),
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHeader(
    int total,
  ) {
    final unread = notifications.where(
      (notification) {
        return notification["read"] == false;
      },
    ).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        18,
        20,
        16,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(
          24,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            28,
          ),
          gradient: LinearGradient(
            colors: [
              Colors.greenAccent.withOpacity(
                0.95,
              ),
              Colors.tealAccent.withOpacity(
                0.85,
              ),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.greenAccent
                  .withOpacity(0.22),
              blurRadius: 18,
              offset: const Offset(
                0,
                8,
              ),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(
                15,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(
                  0.12,
                ),
                borderRadius: BorderRadius.circular(
                  20,
                ),
              ),
              child: const Icon(
                Icons.notifications_active,
                color: Colors.black,
                size: 36,
              ),
            ),

            const SizedBox(
              width: 16,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Centro inteligente",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 25,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    "$total notificaciones • $unread sin leer",
                    style: TextStyle(
                      color: Colors.black.withOpacity(
                        0.75,
                      ),
                      fontSize: 15,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final filteredNotifications =
        getFilteredNotifications();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Notificaciones",
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            tooltip:
                "Marcar todas como leídas",
            onPressed:
                notifications.isEmpty
                    ? null
                    : markAllAsRead,
            icon: const Icon(
              Icons.done_all,
            ),
          ),
          IconButton(
            tooltip: "Actualizar",
            onPressed: loadNotifications,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : Column(
              children: [
                buildHeader(
                  filteredNotifications.length,
                ),

                buildFilterChips(),

                const SizedBox(
                  height: 8,
                ),

                Expanded(
                  child: filteredNotifications
                          .isEmpty
                      ? buildEmptyState()
                      : RefreshIndicator(
                          onRefresh:
                              loadNotifications,
                          child: ListView.builder(
                            padding:
                                const EdgeInsets.only(
                              bottom: 24,
                            ),
                            itemCount:
                                filteredNotifications
                                    .length,
                            itemBuilder: (
                              context,
                              index,
                            ) {
                              return buildNotificationCard(
                                filteredNotifications[
                                    index],
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}