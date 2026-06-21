import 'package:flutter/material.dart';

import '../services/copilot_service.dart';

class CopilotScreen extends StatefulWidget {
  final String email;

  const CopilotScreen({
    super.key,
    required this.email,
  });

  @override
  State<CopilotScreen> createState() => _CopilotScreenState();
}

class _CopilotScreenState extends State<CopilotScreen> {
  final TextEditingController messageController =
      TextEditingController();

  bool isSending = false;

  List<Map<String, String>> messages = [
    {
      "role": "bot",
      "text":
          "Hola, soy Cash-Control AI Copilot. Pregúntame sobre tus gastos, metas, presupuestos o balance.",
    },
  ];

  Future<void> sendMessage() async {
    final text = messageController.text.trim();

    if (text.isEmpty || isSending) return;

    setState(() {
      messages.add({
        "role": "user",
        "text": text,
      });

      isSending = true;
    });

    messageController.clear();

    try {
      final response = await CopilotService.sendMessage(
        email: widget.email,
        message: text,
      );

      final reply =
          response["reply"]?.toString() ??
              "No pude generar una respuesta.";

      setState(() {
        messages.add({
          "role": "bot",
          "text": reply,
        });

        isSending = false;
      });
    } catch (e) {
      setState(() {
        messages.add({
          "role": "bot",
          "text": "Error al conectar con Copilot: $e",
        });

        isSending = false;
      });
    }
  }

  Widget buildMessageBubble(
    Map<String, String> message,
  ) {
    final isUser = message["role"] == "user";

    return Align(
      alignment:
          isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 14,
        ),
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(
          maxWidth: 310,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? Colors.greenAccent
              : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(
              isUser ? 20 : 4,
            ),
            bottomRight: Radius.circular(
              isUser ? 4 : 20,
            ),
          ),
          border: Border.all(
            color: isUser
                ? Colors.greenAccent
                : Colors.white.withOpacity(0.08),
          ),
        ),
        child: Text(
          message["text"] ?? "",
          style: TextStyle(
            color: isUser ? Colors.black : Colors.white,
            fontSize: 15,
            height: 1.35,
            fontWeight:
                isUser ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget buildSuggestionButton(String text) {
    return ActionChip(
      label: Text(text),
      backgroundColor: const Color(0xFF151515),
      side: BorderSide(
        color: Colors.greenAccent.withOpacity(0.4),
      ),
      labelStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      onPressed: () {
        messageController.text = text;
        sendMessage();
      },
    );
  }

  Widget buildSuggestions() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      child: Row(
        children: [
          buildSuggestionButton("¿En qué gasto más?"),
          const SizedBox(width: 8),
          buildSuggestionButton("¿Cómo puedo ahorrar?"),
          const SizedBox(width: 8),
          buildSuggestionButton("¿Qué presupuesto está en riesgo?"),
          const SizedBox(width: 8),
          buildSuggestionButton("¿Cuánto puedo gastar hoy?"),
        ],
      ),
    );
  }

  Widget buildInputBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          12,
          8,
          12,
          12,
        ),
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border(
            top: BorderSide(
              color: Colors.white.withOpacity(0.08),
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: messageController,
                style: const TextStyle(
                  color: Colors.white,
                ),
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Pregunta algo financiero...",
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.45),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF151515),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                ),
                onSubmitted: (_) => sendMessage(),
              ),
            ),
            const SizedBox(width: 10),
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.greenAccent,
              child: IconButton(
                onPressed: isSending ? null : sendMessage,
                icon: isSending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Icon(
                        Icons.send,
                        color: Colors.black,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("AI Copilot"),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          buildSuggestions(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(
                top: 10,
                bottom: 10,
              ),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return buildMessageBubble(
                  messages[index],
                );
              },
            ),
          ),
          buildInputBar(),
        ],
      ),
    );
  }
}
