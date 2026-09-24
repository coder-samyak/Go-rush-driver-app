import 'package:flutter/material.dart';
import '../core/app_toast.dart';
import '../core/theme.dart';
import '../services/support_ticket_service.dart';

class SupportTicketsScreen extends StatefulWidget {
  final VoidCallback? onBackTap;
  final VoidCallback? onCreateTicketTap;

  const SupportTicketsScreen({
    super.key,
    this.onBackTap,
    this.onCreateTicketTap,
  });

  @override
  State<SupportTicketsScreen> createState() => _SupportTicketsScreenState();
}

class _SupportTicketsScreenState extends State<SupportTicketsScreen> {
  int _selectedTab = 0;
  List<SupportTicket> _tickets = [];

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    final tickets = await SupportTicketService.instance.load();
    // Keep the empty state clean while the API is unavailable or still loading.
    // A support page must never look permanently stuck because a request timed out.
    if (mounted) setState(() => _tickets = tickets);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QuickServeColors.surfaceLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: QuickServeColors.textDark),
          onPressed: widget.onBackTap ?? () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Support Tickets',
          style: TextStyle(
            color: QuickServeColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: QuickServeColors.borderLight),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: QuickServeColors.borderLight),
                ),
                child: Row(
                  children: [
                    _buildTab(
                        'Active (${_tickets.where((t) => t.status == 'active').length})',
                        0),
                    _buildTab(
                        'Resolved (${_tickets.where((t) => t.status == 'resolved').length})',
                        1),
                  ],
                ),
              ),
            ),

            // Tickets List
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                physics: const BouncingScrollPhysics(),
                children: _filteredTickets().isEmpty
                    // Intentionally blank when there are no tickets.
                    ? const []
                    : [
                        ..._filteredTickets().expand((ticket) => [
                              _buildTicketCard(
                                id: '#${ticket.number}',
                                title: ticket.title,
                                category: ticket.category,
                                status: ticket.status == 'resolved'
                                    ? 'Resolved'
                                    : 'In Review',
                                statusColor: ticket.status == 'resolved'
                                    ? QuickServeColors.statusGreen
                                    : QuickServeColors.primaryOrange,
                                amount: ticket.amount > 0
                                    ? '₹ ${ticket.amount.toStringAsFixed(0)}'
                                    : '—',
                                date:
                                    '${ticket.createdAt.day}/${ticket.createdAt.month}/${ticket.createdAt.year}',
                                description: ticket.description,
                              ),
                              const SizedBox(height: 12),
                            ]),
                        /*
                  _buildTicketCard(
                    id: '#QS-9821',
                    title: 'Toll reimbursement for DND flyway',
                    category: 'Toll & Charges',
                    status: 'In Review',
                    statusColor: QuickServeColors.primaryOrange,
                    amount: '₹ 40',
                    date: 'Today, 11:15 AM',
                    description: 'FASTag deducted ₹40 at toll plaza but was not added to passenger invoice.',
                  ),
                  const SizedBox(height: 12),
                  _buildTicketCard(
                    id: '#QS-9750',
                    title: 'Fare difference on Connaught Place trip',
                    category: 'Fare Dispute',
                    status: 'Resolved',
                    statusColor: QuickServeColors.statusGreen,
                    amount: '₹ 60',
                    date: 'Yesterday, 06:40 PM',
                    description: 'Extra distance detour due to VIP security route. Reimbursement credited to bank.',
                  ),
                  */
                      ],
              ),
            ),

            // Bottom CTA: Create Ticket
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: _createTicket,
                style: ElevatedButton.styleFrom(
                  backgroundColor: QuickServeColors.primaryOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, size: 20),
                    SizedBox(width: 8),
                    Text('Create Support Ticket',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<SupportTicket> _filteredTickets() => _tickets
      .where((ticket) => _selectedTab == 0
          ? ticket.status == 'active'
          : ticket.status == 'resolved')
      .toList();

  Future<void> _createTicket() async {
    final title = TextEditingController();
    final details = TextEditingController();
    String category = 'General Support';
    final create = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (_, setDialogState) => AlertDialog(
          title: const Text('Create Support Ticket'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                  controller: title,
                  decoration: const InputDecoration(labelText: 'Issue title')),
              DropdownButtonFormField<String>(
                value: category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: const [
                  'General Support',
                  'Fare & Payment',
                  'Toll & Charges',
                  'Safety Incident',
                  'Account'
                ]
                    .map((item) =>
                        DropdownMenuItem(value: item, child: Text(item)))
                    .toList(),
                onChanged: (value) =>
                    setDialogState(() => category = value ?? category),
              ),
              TextField(
                  controller: details,
                  maxLines: 4,
                  decoration:
                      const InputDecoration(labelText: 'Describe the issue')),
            ]),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel')),
            ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Submit')),
          ],
        ),
      ),
    );
    if (create != true) return;
    if (title.text.trim().isEmpty || details.text.trim().isEmpty) {
      if (mounted) {
        AppToast.error(context, 'Please enter an issue title and description.');
      }
      return;
    }
    final ticket = await SupportTicketService.instance.create(
        title: title.text.trim(),
        category: category,
        description: details.text.trim());
    if (!mounted) return;
    if (ticket == null) {
      AppToast.error(
          context, 'Could not create ticket. Check your connection.');
      return;
    }
    setState(() {
      // Newly submitted tickets always belong in the Active tab.
      _tickets = [
        ticket,
        ..._tickets.where((item) => item.number != ticket.number)
      ];
      _selectedTab = 0;
    });
    AppToast.success(context, 'Ticket ${ticket.number} created.');
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? QuickServeColors.primaryOrange
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color:
                    isSelected ? Colors.white : QuickServeColors.textSecondary,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTicketCard({
    required String id,
    required String title,
    required String category,
    required String status,
    required Color statusColor,
    required String amount,
    required String date,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: QuickServeColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$id • $category',
                style: const TextStyle(
                  color: QuickServeColors.textMuted,
                  fontSize: 11,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: QuickServeColors.textDark,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
              color: QuickServeColors.textSecondary,
              fontSize: 12,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: QuickServeColors.borderLight),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date,
                style: const TextStyle(
                    color: QuickServeColors.textMuted, fontSize: 11),
              ),
              Text(
                'Claim: $amount',
                style: const TextStyle(
                  color: QuickServeColors.textDark,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
