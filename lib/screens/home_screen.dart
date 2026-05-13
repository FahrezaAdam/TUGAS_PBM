import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  List<Product> _products = [];
  bool _isLoading = true;

  static const _cardAccents = [
    Color(0xFFDBEAFE),
    Color(0xFFDCFCE7),
    Color(0xFFFEF9C3),
    Color(0xFFFFE4E6),
    Color(0xFFEDE9FE),
  ];
  static const _cardIcons = [
    Color(0xFF2563EB),
    Color(0xFF16A34A),
    Color(0xFFCA8A04),
    Color(0xFFE11D48),
    Color(0xFF7C3AED),
  ];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _apiService.getProducts();
      setState(() => _products = data);
    } catch (e) {
      if (mounted) _showSnack('Gagal mengambil data', isError: true);
    }
    setState(() => _isLoading = false);
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
      backgroundColor: isError ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  String _formatRupiah(num price) {
    final str = price.toInt().toString();
    final formatted = str.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
      (Match m) => '${m[1]}.'
    );
    return 'Rp $formatted';
  }

  // ─── METHOD: Hapus Produk ─────────────────────
  Future<void> _handleDeleteProduct(Product p, int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Hapus produk?',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: const Color(0xFF111827))),
        content: Text(
            '"${p.name}" akan dihapus dari katalogmu.',
            style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF6B7280),
                height: 1.5)),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal',
                style: GoogleFonts.inter(color: const Color(0xFF6B7280))),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Hapus',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600, color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && p.id != null) {
      final success = await _apiService.deleteProduct(p.id!);
      if (success) {
        setState(() => _products.removeAt(index));
      } else {
        if (mounted) _showSnack('Gagal menghapus produk', isError: true);
      }
    }
  }

  // ─── BOTTOM SHEET: Tambah Draft ───────────────
  void _showAddDraftDialog() {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 20, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Text('Tambah Produk Baru',
                style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827))),
            const SizedBox(height: 4),
            Text('Isi detail produk yang ingin kamu tambahkan',
                style: GoogleFonts.inter(
                    fontSize: 13, color: const Color(0xFF6B7280))),
            const SizedBox(height: 22),
            _CustomTextField(
                controller: nameCtrl,
                label: 'Nama Produk',
                hint: 'Contoh: Laptop Gaming ASUS'),
            const SizedBox(height: 14),
            _CustomTextField(
                controller: priceCtrl,
                label: 'Harga',
                hint: 'Contoh: 12500000',
                type: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
            const SizedBox(height: 14),
            _CustomTextField(
                controller: descCtrl,
                label: 'Deskripsi',
                hint: 'Deskripsi singkat produk',
                maxLines: 3),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6B7280),
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('Batal',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D4ED8),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () async {
                    if (nameCtrl.text.isEmpty || priceCtrl.text.isEmpty) return;
                    await _apiService.createDraft(
                      nameCtrl.text,
                      int.tryParse(priceCtrl.text) ?? 0,
                      descCtrl.text,
                    );
                    if (mounted) Navigator.pop(ctx);
                    _fetchData();
                  },
                  child: Text('Simpan',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  // ─── BOTTOM SHEET: Submit Tugas ───────────────
  void _showSubmitTaskDialog() {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final githubCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 20, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: const Color(0xFFD1FAE5),
                      borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.send_rounded, 
                          color: Color(0xFF059669), size: 18),
                ),
                const SizedBox(width: 10),
                Text('Submit Tugas',
                    style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827))),
              ]),
              const SizedBox(height: 4),
              Text('Data yang sudah dikirim tidak bisa diubah lagi',
                  style: GoogleFonts.inter(
                      fontSize: 13, color: const Color(0xFF6B7280))),
              const SizedBox(height: 22),
              _CustomTextField(
                  controller: nameCtrl,
                  label: 'Nama Produk',
                  hint: 'Nama produk utama'),
              const SizedBox(height: 14),
              _CustomTextField(
                  controller: priceCtrl,
                  label: 'Harga',
                  hint: 'Contoh: 50000',
                  type: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
              const SizedBox(height: 14),
              _CustomTextField(
                  controller: descCtrl,
                  label: 'Deskripsi',
                  hint: 'Deskripsi produk',
                  maxLines: 2),
              const SizedBox(height: 14),
              _CustomTextField(
                  controller: githubCtrl,
                  label: 'GitHub URL',
                  hint: 'https://github.com/username/repo',
                  type: TextInputType.url),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF6B7280),
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: Text('Batal',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () async {
                      if (nameCtrl.text.isEmpty || githubCtrl.text.isEmpty) return;
                      bool success = await _apiService.submitTask(
                        nameCtrl.text,
                        int.tryParse(priceCtrl.text) ?? 0,
                        descCtrl.text,
                        githubCtrl.text,
                      );
                      if (mounted) {
                        Navigator.pop(ctx);
                        _showSnack(
                          success ? 'Tugas berhasil disubmit!' : 'Gagal submit tugas',
                          isError: !success,
                        );
                      }
                    },
                    child: Text('Kirim Sekarang',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  // ─── DIALOG: Logout ───────────────────────────
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Keluar akun?',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: const Color(0xFF111827))),
        content: Text(
            'Kamu perlu login ulang untuk mengakses katalog produk.',
            style: GoogleFonts.inter(
                fontSize: 13.5, color: const Color(0xFF6B7280), height: 1.5)),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal',
                style: GoogleFonts.inter(
                    color: const Color(0xFF6B7280),
                    fontWeight: FontWeight.w600)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              await _apiService.logout();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: Text('Keluar',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // ─── BUILD ────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: RefreshIndicator(
        color: const Color(0xFF1D4ED8),
        onRefresh: () async => _fetchData(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()),
          slivers: [
            _buildAppBar(),
            if (_isLoading)
              const SliverFillRemaining(
                  child: Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF1D4ED8))))
            else if (_products.isEmpty)
              _buildEmptyState()
            else
              _buildProductList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDraftDialog,
        backgroundColor: const Color(0xFF1D4ED8),
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_rounded),
        label: Text('Tambah Produk',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: const Color(0xFF1D4ED8),
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      expandedHeight: 150,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.zero,
        title: null,
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1E40AF), Color(0xFF2563EB)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Material(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                        child: InkWell(
                          onTap: _showSubmitTaskDialog,
                          borderRadius: BorderRadius.circular(20),
                          hoverColor: Colors.white.withValues(alpha: 0.35),
                          splashColor: Colors.white.withValues(alpha: 0.2),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.send_rounded, 
                                  color: Colors.white, size: 14),
                                const SizedBox(width: 5),
                                Text('Submit',
                                    style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Material(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                        child: InkWell(
                          onTap: _showLogoutDialog,
                          borderRadius: BorderRadius.circular(20),
                          hoverColor: Colors.white.withValues(alpha: 0.35),
                          splashColor: Colors.white.withValues(alpha: 0.2),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: const Icon(Icons.logout_rounded,
                                color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Greeting
                  FutureBuilder<String?>(
                    future: _apiService.getName(),
                    builder: (context, snapshot) {
                      final name = snapshot.data ?? '';
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Halo,',
                              style: GoogleFonts.inter(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800)),
                          Text(
                            name.isNotEmpty ? name : 'Katalog Saya',
                            style: GoogleFonts.inter(
                                fontSize: 22,
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_products.length} produk tersimpan',
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.6)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: const [],
    );
  }

  SliverFillRemaining _buildEmptyState() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1D4ED8).withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: const Icon(Icons.inbox_outlined,
                  size: 52, color: Color(0xFF9CA3AF)),
            ),
            const SizedBox(height: 20),
            Text('Belum ada produk',
                style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF374151))),
            const SizedBox(height: 6),
            Text('Ketuk tombol di bawah untuk menambahkan\nproduk baru ke katalog',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF9CA3AF),
                    height: 1.6)),
          ],
        ),
      ),
    );
  }

  SliverPadding _buildProductList() {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final p = _products[index];
            final accentBg = _cardAccents[index % _cardAccents.length];
            final accentFg = _cardIcons[index % _cardIcons.length];

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E293B).withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(
                          product: p,
                          accentBg: accentBg,
                          accentFg: accentFg,
                        ),
                      ),
                    );
                  },  
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: accentBg,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              p.name.isNotEmpty
                                  ? p.name[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: accentFg),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.name,
                                  style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14.5,
                                      color: const Color(0xFF111827))),
                              const SizedBox(height: 3),
                              Text(
                                p.description.isNotEmpty
                                    ? p.description
                                    : 'Tidak ada deskripsi',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                    fontSize: 12.5,
                                    color: const Color(0xFF9CA3AF),
                                    height: 1.4),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _formatRupiah(p.price),
                                  style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF16A34A),
                                      fontSize: 12.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => _handleDeleteProduct(p, index),
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.delete_outline_rounded,
                                size: 17, color: Color(0xFFDC2626)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
          childCount: _products.length,
        ),
      ),
    );
  }
}

// ─── WIDGET TERPISAH: Custom TextField ────────
class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType? type;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;

  const _CustomTextField({
    required this.controller,
    required this.label,
    required this.hint,
    this.type,
    this.inputFormatters,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF374151))),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: type,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF111827)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
                color: const Color(0xFFD1D5DB), fontSize: 13.5),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFF1D4ED8), width: 1.5)),
          ),
        ),
      ],
    );
  }
}