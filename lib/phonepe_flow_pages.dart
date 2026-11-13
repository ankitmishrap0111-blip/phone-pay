import 'package:flutter/material.dart';
import 'package:phonepe_replicte/phonepe_theme.dart';

class SendMoneyOptionsPage extends StatelessWidget {
  const SendMoneyOptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey('send-money-options-screen'),
      backgroundColor: PhonePeColors.background,
      appBar: _flowAppBar(context, 'Send Money'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          Container(
            height: 236,
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF00210F), Color(0xFF001108)],
              ),
            ),
            child: Stack(
              children: [
                const Positioned(
                  top: 15,
                  left: 10,
                  right: 10,
                  child: Text(
                    'Zero wait time • Zero fee',
                    style: TextStyle(
                      color: PhonePeColors.success,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Positioned(
                  top: 48,
                  left: 10,
                  right: 10,
                  child: Text(
                    'Add a recipient to preview a transfer.',
                    style: TextStyle(
                      color: PhonePeColors.muted,
                      fontSize: 14,
                    ),
                  ),
                ),
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: Icon(
                    Icons.account_balance,
                    size: 108,
                    color: PhonePeColors.success.withValues(alpha: 0.26),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SendOptionCard(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'To Self Bank Account',
                  onTap: () => _push(context, const SelfAccountPage()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SendOptionCard(
                  icon: Icons.account_balance_outlined,
                  title: 'To Account Number & IFSC',
                  onTap: () => _push(
                    context,
                    const BankSelectionPage(title: 'Select receiver Bank'),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Divider(),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 6),
            leading: const CircleAvatar(
              backgroundColor: PhonePeColors.surfaceLight,
              child: Icon(Icons.alternate_email, color: PhonePeColors.text),
            ),
            title: const Text('To UPI ID or Number'),
            subtitle: const Text(
              'Transfer to any UPI app',
              style: TextStyle(color: PhonePeColors.muted),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _push(context, const UpiRecipientPage()),
          ),
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            'Demo mode: no bank is contacted and no money is moved.',
            textAlign: TextAlign.center,
            style: TextStyle(color: PhonePeColors.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class BankSelectionPage extends StatefulWidget {
  const BankSelectionPage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State<BankSelectionPage> createState() => _BankSelectionPageState();
}

class _BankSelectionPageState extends State<BankSelectionPage> {
  static const _banks = [
    'State Bank of India',
    'Bank of Baroda',
    'Punjab National Bank',
    'Airtel Payments Bank',
    'HDFC Bank',
    'India Post Payments Bank',
    'Rajasthan Gramin Bank',
    'UCO Bank',
    'Kotak Mahindra Bank',
  ];

  final _searchController = TextEditingController();
  String _query = '';

  List<String> get _filteredBanks => _banks
      .where((bank) => bank.toLowerCase().contains(_query.toLowerCase()))
      .toList();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectBank(String bank) {
    _push(
      context,
      BankAccountDetailsPage(
        bankName: bank,
        isAddingAccount: widget.title == 'Add new bank account',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleBanks = _filteredBanks;
    return Scaffold(
      key: const ValueKey('bank-selection-screen'),
      backgroundColor: PhonePeColors.background,
      appBar: _flowAppBar(context, widget.title),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value.trim()),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Search by bank name',
              filled: true,
              fillColor: PhonePeColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 26),
          const _Overline('POPULAR BANKS'),
          const SizedBox(height: 14),
          if (_query.isEmpty)
            GridView.builder(
              itemCount: _banks.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisExtent: 118,
                crossAxisSpacing: 8,
              ),
              itemBuilder: (context, index) => _BankCircle(
                bankName: _banks[index],
                onTap: () => _selectBank(_banks[index]),
              ),
            ),
          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: 14),
          const _Overline('ALL BANKS'),
          const SizedBox(height: 8),
          if (visibleBanks.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 22),
              child: Text(
                'No banks found',
                textAlign: TextAlign.center,
                style: TextStyle(color: PhonePeColors.muted),
              ),
            )
          else
            ...visibleBanks.map(
              (bank) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: PhonePeColors.surface,
                  child: Text(
                    bank[0],
                    style: const TextStyle(
                      color: PhonePeColors.accentLight,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                title: Text(bank),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _selectBank(bank),
              ),
            ),
        ],
      ),
    );
  }
}

class SelfAccountPage extends StatelessWidget {
  const SelfAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey('self-account-screen'),
      backgroundColor: PhonePeColors.background,
      appBar: _flowAppBar(context, 'To Self Account'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const _Overline('BANK ACCOUNTS'),
          const SizedBox(height: 22),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const CircleAvatar(
              backgroundColor: PhonePeColors.surface,
              child: Icon(Icons.account_balance, color: PhonePeColors.accent),
            ),
            title: const Text('Demo Bank ••0000'),
            subtitle: const Text(
              'Demo account for preview',
              style: TextStyle(color: PhonePeColors.muted),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _push(
              context,
              const AmountEntryPage(recipient: 'Demo Bank account'),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton.icon(
          onPressed: () => _push(
            context,
            const BankSelectionPage(title: 'Add new bank account'),
          ),
          icon: const Icon(Icons.add),
          label: const Text('Self Account'),
          style: FilledButton.styleFrom(
            backgroundColor: PhonePeColors.accent,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }
}

class CheckBalancePage extends StatelessWidget {
  const CheckBalancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey('check-balance-screen'),
      backgroundColor: PhonePeColors.background,
      appBar: _flowAppBar(context, 'Check Balance'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF111C76),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Build ₹1,200 in 1 month',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text('Save ₹40/day in Gold'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const CircleAvatar(
              backgroundColor: PhonePeColors.surface,
              child: Icon(Icons.account_balance, color: PhonePeColors.accent),
            ),
            title: const Text('Demo Bank ••0000'),
            subtitle: const Text(
              'Bank account (preview)',
              style: TextStyle(color: PhonePeColors.muted),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showDemoNotice(
              context,
              'Demo only. No account balance was requested.',
            ),
          ),
          const SizedBox(height: 10),
          _BalanceAction(
            icon: Icons.fingerprint,
            title: 'Use fingerprint to check balance',
            action: 'Try now',
            onTap: () => _showDemoNotice(
              context,
              'Fingerprint and bank balance services are not connected.',
            ),
          ),
          _BalanceAction(
            icon: Icons.account_balance_wallet_outlined,
            title: 'PhonePe Wallet',
            subtitle: 'Wallet activation is a demo flow',
            action: 'Activate',
            onTap: () => _push(context, const WalletActivationPage()),
          ),
          _BalanceAction(
            icon: Icons.credit_card_outlined,
            title: 'RuPay Credit Card',
            action: 'Link now',
            onTap: () => _showDemoNotice(
              context,
              'Card linking is not available in this demo.',
            ),
          ),
          _BalanceAction(
            icon: Icons.add_circle_outline,
            title: 'Add new payment method',
            subtitle: 'Bank account, UPI Lite & more',
            action: '',
            onTap: () => _push(
              context,
              const BankSelectionPage(title: 'Add new bank account'),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Preview only. No real balance or bank details are accessed.',
            textAlign: TextAlign.center,
            style: TextStyle(color: PhonePeColors.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class WalletActivationPage extends StatelessWidget {
  const WalletActivationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey('wallet-activation-screen'),
      backgroundColor: PhonePeColors.background,
      appBar: _flowAppBar(context, 'PhonePe Wallet'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Unlock more with Wallet',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 22),
          const _BenefitRow(
            icon: Icons.credit_card,
            title: 'Top up using credit card',
            subtitle: 'Wallet top-ups are not available in this preview.',
          ),
          const _BenefitRow(
            icon: Icons.south_west,
            title: 'Withdraw money',
            subtitle: 'Connect an account in the full app.',
          ),
          const _BenefitRow(
            icon: Icons.qr_code_2,
            title: 'UPI payments',
            subtitle: 'Scan and review a QR code in demo mode.',
          ),
          const SizedBox(height: 26),
          const Text(
            'By continuing, you agree to the Terms & Conditions.',
            textAlign: TextAlign.center,
            style: TextStyle(color: PhonePeColors.muted, fontSize: 12),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: () => _showDemoNotice(
              context,
              'Wallet activation is not connected in this demo.',
            ),
            style: FilledButton.styleFrom(
              backgroundColor: PhonePeColors.accent,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Resume Activation'),
          ),
        ],
      ),
    );
  }
}

class UpiRecipientPage extends StatefulWidget {
  const UpiRecipientPage({super.key});

  @override
  State<UpiRecipientPage> createState() => _UpiRecipientPageState();
}

class _UpiRecipientPageState extends State<UpiRecipientPage> {
  final _formKey = GlobalKey<FormState>();
  final _recipientController = TextEditingController();

  @override
  void dispose() {
    _recipientController.dispose();
    super.dispose();
  }

  void _verifyRecipient() {
    if (!_formKey.currentState!.validate()) return;
    _push(
      context,
      AmountEntryPage(recipient: _recipientController.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey('upi-recipient-screen'),
      backgroundColor: PhonePeColors.background,
      appBar: _flowAppBar(context, 'To new UPI ID/Number'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Enter any UPI ID or 8–10 digit number',
              style: TextStyle(color: PhonePeColors.muted),
            ),
            const SizedBox(height: 26),
            const Text(
              'UPI ID / Number',
              style: TextStyle(color: PhonePeColors.accentLight),
            ),
            const SizedBox(height: 9),
            TextFormField(
              key: const ValueKey('upi-recipient-input'),
              controller: _recipientController,
              keyboardType: TextInputType.emailAddress,
              validator: _validateRecipient,
              decoration: InputDecoration(
                hintText: 'Enter UPI ID/UPI Number',
                suffixIcon: IconButton(
                  tooltip: 'Verify',
                  onPressed: _verifyRecipient,
                  icon: const Icon(Icons.arrow_forward),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: PhonePeColors.accentLight,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: PhonePeColors.accent,
                    width: 2,
                  ),
                ),
              ),
              onFieldSubmitted: (_) => _verifyRecipient(),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _verifyRecipient,
              style: FilledButton.styleFrom(
                backgroundColor: PhonePeColors.accent,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Verify'),
            ),
            const SizedBox(height: 14),
            const Text(
              'Verification is local only. No UPI app or bank is contacted.',
              textAlign: TextAlign.center,
              style: TextStyle(color: PhonePeColors.muted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  String? _validateRecipient(String? value) {
    final input = value?.trim() ?? '';
    final isPhoneNumber = RegExp(r'^\+?\d{8,10}$').hasMatch(input);
    final isUpiId = RegExp(r'^[A-Za-z0-9._-]+@[A-Za-z0-9.-]+$').hasMatch(input);
    if (isPhoneNumber || isUpiId) return null;
    return 'Enter a valid demo UPI ID or 8–10 digit number';
  }
}

class BankAccountDetailsPage extends StatefulWidget {
  const BankAccountDetailsPage({
    super.key,
    required this.bankName,
    required this.isAddingAccount,
  });

  final String bankName;
  final bool isAddingAccount;

  @override
  State<BankAccountDetailsPage> createState() => _BankAccountDetailsPageState();
}

class _BankAccountDetailsPageState extends State<BankAccountDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final _accountController = TextEditingController();
  final _ifscController = TextEditingController();

  @override
  void dispose() {
    _accountController.dispose();
    _ifscController.dispose();
    super.dispose();
  }

  void _continue() {
    if (!_formKey.currentState!.validate()) return;
    if (widget.isAddingAccount) {
      _showDemoNotice(context, 'Bank linking is not connected in this demo.');
      return;
    }
    _push(
      context,
      AmountEntryPage(recipient: '${widget.bankName} account'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title =
        widget.isAddingAccount ? 'Add new bank account' : 'Account details';
    return Scaffold(
      key: const ValueKey('account-details-screen'),
      backgroundColor: PhonePeColors.background,
      appBar: _flowAppBar(context, title),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              widget.bankName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 22),
            TextFormField(
              controller: _accountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Account number',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  RegExp(r'^\d{6,18}$').hasMatch(value?.trim() ?? '')
                      ? null
                      : 'Enter a valid account number',
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ifscController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'IFSC code',
                border: OutlineInputBorder(),
              ),
              validator: (value) => RegExp(r'^[A-Za-z]{4}0[A-Za-z0-9]{6}$')
                      .hasMatch(value?.trim() ?? '')
                  ? null
                  : 'Enter a valid IFSC code',
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _continue,
              style: FilledButton.styleFrom(
                backgroundColor: PhonePeColors.accent,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: Text(
                widget.isAddingAccount ? 'Link demo account' : 'Continue',
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Entered details stay in this preview and are not submitted.',
              textAlign: TextAlign.center,
              style: TextStyle(color: PhonePeColors.muted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class AmountEntryPage extends StatefulWidget {
  const AmountEntryPage({super.key, required this.recipient});

  final String recipient;

  @override
  State<AmountEntryPage> createState() => _AmountEntryPageState();
}

class _AmountEntryPageState extends State<AmountEntryPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _review() {
    if (!_formKey.currentState!.validate()) return;
    _push(
      context,
      DemoPaymentReviewPage(
        recipient: widget.recipient,
        amount: _amountController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey('amount-entry-screen'),
      backgroundColor: PhonePeColors.background,
      appBar: _flowAppBar(context, 'Send Money'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Paying to',
                style: TextStyle(color: PhonePeColors.muted)),
            const SizedBox(height: 5),
            Text(
              widget.recipient,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 30),
            TextFormField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                prefixText: '₹ ',
                labelText: 'Amount',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final amount = double.tryParse(value?.trim() ?? '');
                return amount == null || amount <= 0
                    ? 'Enter an amount greater than zero'
                    : null;
              },
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _review,
              style: FilledButton.styleFrom(
                backgroundColor: PhonePeColors.accent,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text('Review transfer'),
            ),
          ],
        ),
      ),
    );
  }
}

class DemoPaymentReviewPage extends StatelessWidget {
  const DemoPaymentReviewPage({
    super.key,
    required this.recipient,
    required this.amount,
  });

  final String recipient;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey('demo-payment-review-screen'),
      backgroundColor: PhonePeColors.background,
      appBar: _flowAppBar(context, 'Review transfer'),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 30),
            const Icon(
              Icons.receipt_long_outlined,
              size: 54,
              color: PhonePeColors.accentLight,
            ),
            const SizedBox(height: 22),
            Text(
              '₹$amount',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Text(
              'To $recipient',
              textAlign: TextAlign.center,
              style: const TextStyle(color: PhonePeColors.muted),
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: PhonePeColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Demo preview only. No payment will be sent.',
                textAlign: TextAlign.center,
                style: TextStyle(color: PhonePeColors.accentLight),
              ),
            ),
            const Spacer(),
            FilledButton(
              onPressed: () {
                _push(
                  context,
                  _DemoPaymentSuccessPage(
                    receipt: _DemoPaymentReceipt.create(
                      recipient: recipient,
                      amount: amount,
                    ),
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: PhonePeColors.accent,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text('Preview successful payment'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DemoPaymentReceipt {
  const _DemoPaymentReceipt({
    required this.recipient,
    required this.amount,
    required this.timestamp,
    required this.transactionId,
  });

  factory _DemoPaymentReceipt.create({
    required String recipient,
    required String amount,
  }) {
    final timestamp = DateTime.now();
    return _DemoPaymentReceipt(
      recipient: recipient,
      amount: amount,
      timestamp: timestamp,
      transactionId: 'DEMO-${timestamp.microsecondsSinceEpoch}',
    );
  }

  final String recipient;
  final String amount;
  final DateTime timestamp;
  final String transactionId;
}

class _DemoPaymentSuccessPage extends StatelessWidget {
  const _DemoPaymentSuccessPage({required this.receipt});

  final _DemoPaymentReceipt receipt;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey('payment-success-screen'),
      backgroundColor: const Color(0xFFF2F4F3),
      body: Column(
        children: [
          Container(
            height: 244,
            width: double.infinity,
            color: _receiptGreen,
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: _receiptGreen,
                    size: 38,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Payment Successful',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatDemoTimestamp(context, receipt.timestamp),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'DEMO PREVIEW • NO MONEY SENT',
                    style: TextStyle(
                      color: _receiptGreen,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x12000000),
                        blurRadius: 12,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'DEMO RECEIPT',
                          style: TextStyle(
                            color: _receiptGreen,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _RecipientAvatar(name: receipt.recipient, size: 42),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  receipt.recipient,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: _receiptText,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _maskedRecipient(receipt.recipient),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: _receiptMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '₹${receipt.amount}',
                            style: const TextStyle(
                              color: _receiptText,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 26),
                      Row(
                        children: [
                          Expanded(
                            child: _ReceiptAction(
                              icon: Icons.receipt_long_outlined,
                              label: 'View Details',
                              onTap: () => _push(
                                context,
                                _DemoTransactionDetailsPage(receipt: receipt),
                              ),
                            ),
                          ),
                          Expanded(
                            child: _ReceiptAction(
                              icon: Icons.share_outlined,
                              label: 'Share Receipt',
                              onTap: () => _showDemoNotice(
                                context,
                                'Receipt sharing is disabled in this demo.',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const Center(
                  child: Text(
                    'UPI',
                    style: TextStyle(
                      color: Color(0xFF61666A),
                      fontSize: 22,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: FilledButton(
          onPressed: () =>
              Navigator.of(context).popUntil((route) => route.isFirst),
          style: FilledButton.styleFrom(
            backgroundColor: _receiptGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text('Done'),
        ),
      ),
    );
  }
}

class _DemoTransactionDetailsPage extends StatelessWidget {
  const _DemoTransactionDetailsPage({required this.receipt});

  final _DemoPaymentReceipt receipt;

  @override
  Widget build(BuildContext context) {
    final timestamp = _formatDemoTimestamp(context, receipt.timestamp);
    return Scaffold(
      key: const ValueKey('transaction-details-screen'),
      backgroundColor: const Color(0xFFF2F4F3),
      appBar: AppBar(
        backgroundColor: _receiptGreen,
        foregroundColor: Colors.white,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Transaction Successful',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            Text(
              timestamp,
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DEMO • NOT A REAL TRANSACTION',
                  style: TextStyle(
                    color: Color(0xFF986600),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Paid to',
                  style: TextStyle(
                    color: _receiptText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _RecipientAvatar(name: receipt.recipient, size: 42),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            receipt.recipient,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _receiptText,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _maskedRecipient(receipt.recipient),
                            style: const TextStyle(
                              color: _receiptMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '₹${receipt.amount}',
                      style: const TextStyle(
                        color: _receiptText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                const Text(
                  'Transfer Details',
                  style: TextStyle(
                    color: _receiptText,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                _ReceiptDetailRow(
                  label: 'Demo transaction ID',
                  value: receipt.transactionId,
                ),
                const SizedBox(height: 12),
                const _ReceiptDetailRow(
                  label: 'Debited from',
                  value: 'Demo account ••0000',
                ),
                const SizedBox(height: 12),
                const _ReceiptDetailRow(
                  label: 'Demo reference',
                  value: 'No bank transfer was made',
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _ReceiptAction(
                        icon: Icons.north_east,
                        label: 'Send Again',
                        onTap: () => _push(
                          context,
                          AmountEntryPage(recipient: receipt.recipient),
                        ),
                      ),
                    ),
                    Expanded(
                      child: _ReceiptAction(
                        icon: Icons.history,
                        label: 'View History',
                        onTap: () => _showDemoNotice(
                          context,
                          'Demo previews are not saved to payment history.',
                        ),
                      ),
                    ),
                    Expanded(
                      child: _ReceiptAction(
                        icon: Icons.call_split,
                        label: 'Split Expense',
                        onTap: () => _showDemoNotice(
                          context,
                          'Expense splitting is not connected in this demo.',
                        ),
                      ),
                    ),
                    Expanded(
                      child: _ReceiptAction(
                        icon: Icons.share_outlined,
                        label: 'Share Receipt',
                        onTap: () => _showDemoNotice(
                          context,
                          'Receipt sharing is disabled in this demo.',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Card(
            color: Colors.white,
            child: ListTile(
              leading: const Icon(Icons.support_agent, color: _receiptGreen),
              title: const Text(
                'Contact demo support',
                style: TextStyle(color: _receiptText),
              ),
              trailing: const Icon(Icons.chevron_right, color: _receiptMuted),
              onTap: () => _showDemoNotice(
                context,
                'Support is not connected in this demo.',
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFE7F4ED),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Preview only. No money was sent and no bank service was contacted.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _receiptGreen, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptAction extends StatelessWidget {
  const _ReceiptAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: Color(0xFFF5E9FB),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: _receiptGreen, size: 21),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _receiptText,
                fontSize: 10,
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceiptDetailRow extends StatelessWidget {
  const _ReceiptDetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: _receiptMuted, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: _receiptText,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _RecipientAvatar extends StatelessWidget {
  const _RecipientAvatar({required this.name, required this.size});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: const Color(0xFFEDE6F4),
      child: Text(
        initial,
        style: const TextStyle(
          color: _receiptGreen,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

const _receiptGreen = Color(0xFF078B49);
const _receiptText = Color(0xFF202124);
const _receiptMuted = Color(0xFF64686B);

String _maskedRecipient(String recipient) {
  final digits = recipient.replaceAll(RegExp(r'\D'), '');
  if (digits.length >= 8) {
    return '+91 ••••• ${digits.substring(digits.length - 4)}';
  }
  return recipient;
}

String _formatDemoTimestamp(BuildContext context, DateTime timestamp) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  final time = TimeOfDay.fromDateTime(timestamp).format(context);
  return '${timestamp.day} ${months[timestamp.month - 1]} '
      '${timestamp.year} at $time';
}

class _SendOptionCard extends StatelessWidget {
  const _SendOptionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PhonePeColors.surface,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: PhonePeColors.accent,
                child: Icon(icon, color: Colors.white, size: 25),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BankCircle extends StatelessWidget {
  const _BankCircle({required this.bankName, required this.onTap});

  final String bankName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Column(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: PhonePeColors.surfaceLight,
              child: CircleAvatar(
                radius: 21,
                backgroundColor: Colors.white,
                child: Text(
                  bankName[0],
                  style: const TextStyle(
                    color: PhonePeColors.accent,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              bankName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceAction extends StatelessWidget {
  const _BalanceAction({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.action,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: PhonePeColors.accentLight),
      title: Text(title),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              style: const TextStyle(color: PhonePeColors.muted, fontSize: 12),
            ),
      trailing: action.isEmpty
          ? const Icon(Icons.chevron_right)
          : Text(
              action,
              style: const TextStyle(
                color: PhonePeColors.accentLight,
                fontWeight: FontWeight.w700,
              ),
            ),
      onTap: onTap,
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: PhonePeColors.accentLight),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: PhonePeColors.muted),
      ),
    );
  }
}

class _Overline extends StatelessWidget {
  const _Overline(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: PhonePeColors.muted,
        fontSize: 12,
        letterSpacing: 2,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

PreferredSizeWidget _flowAppBar(BuildContext context, String title) {
  return AppBar(
    backgroundColor: PhonePeColors.background,
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
    actions: [
      IconButton(
        tooltip: 'Help',
        onPressed: () => _showDemoNotice(
          context,
          'Demo screens do not connect to a bank or payment service.',
        ),
        icon: const Icon(Icons.help_outline),
      ),
    ],
  );
}

void _push(BuildContext context, Widget page) {
  Navigator.of(context).push<void>(
    MaterialPageRoute<void>(builder: (_) => page),
  );
}

void openPhonePeFlow(BuildContext context, Widget page) => _push(context, page);

void _showDemoNotice(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
