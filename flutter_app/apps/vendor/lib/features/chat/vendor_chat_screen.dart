import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';
import 'package:gomandap_common/presentation/widgets/gomandap_screen.dart';

class VendorChatScreen extends ConsumerStatefulWidget {
  const VendorChatScreen({super.key});

  @override
  ConsumerState<VendorChatScreen> createState() => _VendorChatScreenState();
}

class _VendorChatScreenState extends ConsumerState<VendorChatScreen> {
  final _messageCtrl = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {'text': 'Hello! How can I help you with your booking?', 'isMe': false, 'isQuote': false},
  ];

  void _sendMessage() {
    if (_messageCtrl.text.trim().isNotEmpty) {
      setState(() {
        _messages.add({'text': _messageCtrl.text.trim(), 'isMe': true, 'isQuote': false});
        _messageCtrl.clear();
      });
    }
  }

  void _sendQuote(String title, String price, String terms) {
    setState(() {
      _messages.add({
        'text': '',
        'isMe': true,
        'isQuote': true,
        'quoteTitle': title,
        'quotePrice': price,
        'quoteTerms': terms,
      });
    });
  }

  void _showSmartQuoteModal() {
    final titleCtrl = TextEditingController(text: 'Standard Wedding Package');
    final priceCtrl = TextEditingController(text: '150000');
    final termsCtrl = TextEditingController(text: 'Includes venue, standard decor, and 2 changing rooms. 20% advance required.');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Generate Smart Quote 📝', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: GomandapTokens.royalNavy)),
              const SizedBox(height: 8),
              const Text('Instantly send a professional quote and escrow request to the client.', style: TextStyle(fontSize: 12, color: GomandapTokens.slateGray)),
              const SizedBox(height: 24),
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Package Title', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Total Price (₹)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: termsCtrl,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Terms / Inclusions', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GomandapTokens.royalNavy,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _sendQuote(titleCtrl.text, priceCtrl.text, termsCtrl.text);
                  },
                  child: const Text('Send Quote & Request Escrow', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GomandapScreen(
      backgroundColor: GomandapTokens.pearlWhite,
      useHorizontalPadding: false,
      useSafeAreaTop: false,
      useSafeAreaBottom: false,
      appBar: AppBar(
        title: const Text('Chat with Client', style: TextStyle(color: GomandapTokens.royalNavy, fontWeight: FontWeight.w800)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: GomandapTokens.royalNavy),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(GomandapTokens.spacingMd),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg['isMe'] as bool;
                final isQuote = msg['isQuote'] as bool;

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: GomandapTokens.spacingMd),
                    constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.8),
                    child: isQuote
                        ? _buildQuoteCard(msg)
                        : Container(
                            padding: const EdgeInsets.all(GomandapTokens.spacingMd),
                            decoration: BoxDecoration(
                              color: isMe ? GomandapTokens.royalNavy : Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                                bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                              ),
                              boxShadow: GomandapTokens.softShadow,
                            ),
                            child: Text(msg['text'], style: GomandapTokens.interBody.copyWith(color: isMe ? Colors.white : GomandapTokens.royalNavy)),
                          ),
                  ),
                );
              },
            ),
          ),
          
          // Smart Actions Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: GomandapTokens.softMist,
            child: Row(
              children: [
                ActionChip(
                  label: const Text('📝 Smart Quote'),
                  backgroundColor: GomandapTokens.champagneGoldStart.withValues(alpha: 0.2),
                  labelStyle: const TextStyle(color: GomandapTokens.champagneGoldEnd, fontWeight: FontWeight.w800, fontSize: 12),
                  onPressed: _showSmartQuoteModal,
                  side: BorderSide.none,
                ),
                const SizedBox(width: 8),
                ActionChip(
                  label: const Text('📅 Share Calendar'),
                  backgroundColor: Colors.white,
                  labelStyle: const TextStyle(color: GomandapTokens.slateGray, fontWeight: FontWeight.w700, fontSize: 12),
                  onPressed: () {},
                  side: const BorderSide(color: GomandapTokens.lightSlate),
                ),
              ],
            ),
          ),

          // Chat Input Bar
          Container(
            padding: const EdgeInsets.all(GomandapTokens.spacingMd),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: GomandapTokens.cardShadow,
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageCtrl,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        hintStyle: const TextStyle(color: Colors.black38),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: GomandapTokens.softMist,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: GomandapTokens.spacingMd),
                  CircleAvatar(
                    backgroundColor: GomandapTokens.royalNavy,
                    radius: 24,
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteCard(Map<String, dynamic> msg) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [GomandapTokens.champagneGoldStart, GomandapTokens.champagneGoldEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: GomandapTokens.goldGlowShadow,
      ),
      padding: const EdgeInsets.all(2),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('OFFICIAL QUOTE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: GomandapTokens.slateGray, letterSpacing: 1.2)),
                Icon(Icons.verified, color: GomandapTokens.champagneGoldEnd, size: 16),
              ],
            ),
            const SizedBox(height: 12),
            Text(msg['quoteTitle'] ?? 'Package', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: GomandapTokens.royalNavy)),
            const SizedBox(height: 8),
            Text(msg['quoteTerms'] ?? '', style: const TextStyle(fontSize: 12, color: GomandapTokens.slateGray)),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.w700, color: GomandapTokens.royalNavy)),
                Text('₹${msg['quotePrice']}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: GomandapTokens.champagneGoldStart)),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: GomandapTokens.softMist,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('Waiting for Client to Accept Escrow', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: GomandapTokens.slateGray)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
