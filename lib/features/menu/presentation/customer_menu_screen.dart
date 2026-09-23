import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fireshots_pos/core/constants/app_constants.dart';
import 'package:fireshots_pos/features/menu/data/product_model.dart';
import 'package:fireshots_pos/features/menu/providers/menu_provider.dart';
import 'package:fireshots_pos/features/orders/providers/system_settings_provider.dart';

class CustomerMenuScreen extends ConsumerStatefulWidget {
  const CustomerMenuScreen({super.key});

  @override
  ConsumerState<CustomerMenuScreen> createState() => _CustomerMenuScreenState();
}

class _CustomerMenuScreenState extends ConsumerState<CustomerMenuScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'Todos';
  bool _isOpen = true;
  bool _isOpenLoaded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    _checkBarStatus();
  }

  Future<void> _checkBarStatus() async {
    try {
      final isOpen = await ref
          .read(systemSettingsServiceProvider)
          .getIsBarOpen()
          .timeout(const Duration(seconds: 4));
      if (mounted) {
        setState(() {
          _isOpen = isOpen;
          _isOpenLoaded = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isOpenLoaded = true);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(availableProductsStreamProvider);
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    if (_isOpenLoaded && !_isOpen) {
      return Scaffold(
        backgroundColor: AppConstants.backgroundDark,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.closed_caption_off,
                  size: 80,
                  color: Colors.red[300],
                ),
                const SizedBox(height: 24),
                Text(
                  'Sistema cerrado',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[300],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'El sistema se encuentra apagado.\nVuelve más tarde.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                ),
                const SizedBox(height: 32),
                IconButton(
                  icon: Icon(Icons.person_outline, color: Colors.grey[600]),
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  tooltip: 'Acceso personal',
                ),
              ],
            ),
          ),
        ),
      );
    }

    return _buildMenu(productsAsync, cart, cartNotifier, true);
  }

  Widget _buildMenu(
    AsyncValue<List<Product>> productsAsync,
    Map<String, CartItem> cart,
    CartNotifier cartNotifier,
    bool isOpen,
  ) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundDark,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppConstants.backgroundDark,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'logos/logo_fireshots.png',
              height: 32,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.local_fire_department,
                color: AppConstants.primaryGold,
                size: 28,
              ),
            ),
            const SizedBox(width: 10),
            const Flexible(
              child: Text(
                'Fire Shots',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppConstants.primaryGold,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.shopping_cart_outlined,
                  color: AppConstants.textWhite,
                ),
                onPressed: cart.isNotEmpty
                    ? () => Navigator.pushNamed(context, '/cart')
                    : null,
              ),
              if (cartNotifier.itemCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${cartNotifier.itemCount}',
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(
              Icons.person_outline,
              color: AppConstants.textGray,
            ),
            onPressed: () => Navigator.pushNamed(context, '/login'),
            tooltip: 'Acceso personal',
          ),
        ],
      ),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (products) {
          final categories = _getCategories(products);
          if (_tabController.length != categories.length &&
              categories.length > 1) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final catLen = _getCategories(products).length;
              if (catLen > 1 && _tabController.length != catLen) {
                _tabController.dispose();
                _tabController = TabController(
                  length: catLen,
                  vsync: this,
                  initialIndex: 0,
                );
                _tabController.addListener(() {
                  if (!_tabController.indexIsChanging) {
                    setState(() {
                      _selectedCategory = categories[_tabController.index];
                    });
                  }
                });
                setState(() {});
              }
            });
          }

          final filtered = _selectedCategory == 'Todos'
              ? products
              : products.where((p) => p.category == _selectedCategory).toList();

          return Column(
            children: [
              Container(
                color: AppConstants.backgroundCard,
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: AppConstants.primaryGold,
                  unselectedLabelColor: AppConstants.textGray,
                  indicatorColor: AppConstants.primaryGold,
                  indicatorWeight: 3,
                  tabs: categories.map((cat) {
                    return Tab(
                      child: Text(
                        cat,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.restaurant_menu,
                              size: 64,
                              color: AppConstants.textGray,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No hay productos disponibles',
                              style: TextStyle(color: AppConstants.textGray),
                            ),
                          ],
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final crossAxisCount = constraints.maxWidth > 900
                              ? 4
                              : constraints.maxWidth > 600
                              ? 3
                              : 2;
                          return CustomScrollView(
                            slivers: [
                              SliverPadding(
                                padding: const EdgeInsets.fromLTRB(
                                  12,
                                  12,
                                  12,
                                  12,
                                ),
                                sliver: SliverGrid(
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: crossAxisCount,
                                        childAspectRatio: 0.72,
                                        crossAxisSpacing: 10,
                                        mainAxisSpacing: 10,
                                      ),
                                  delegate: SliverChildBuilderDelegate((
                                    context,
                                    index,
                                  ) {
                                    return _ProductCard(
                                      product: filtered[index],
                                    );
                                  }, childCount: filtered.length),
                                ),
                              ),
                              SliverToBoxAdapter(child: _MenuFooter()),
                            ],
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      bottomSheet: cart.isNotEmpty
          ? Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: AppConstants.backgroundCard,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(77),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              color: AppConstants.textGray,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            AppConstants.formatCurrency(
                              cartNotifier.totalAmount,
                            ),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.primaryGold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/checkout'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryGold,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'PAGAR',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  List<String> _getCategories(List<Product> products) {
    final cats = products.map((p) => p.category).toSet().toList();
    cats.sort();
    return ['Todos', ...cats];
  }
}

class _MenuFooter extends StatelessWidget {
  const _MenuFooter();

  void _openWhatsApp(BuildContext context) {
    final message = Uri.encodeComponent(AppConstants.whatsappMessage);
    launchUrl(
      Uri.parse('https://wa.me/57${AppConstants.phone1}?text=$message'),
      mode: LaunchMode.externalApplication,
    );
  }

  void _openInstagram() {
    launchUrl(
      Uri.parse(AppConstants.instagramUrl),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 100),
      color: AppConstants.backgroundCard,
      child: Column(
        children: [
          const Text(
            'Plaza Norte | Fire Shots',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppConstants.primaryGold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'logos/logo_plaza_norte.png',
                height: 40,
                width: 40,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.local_fire_department,
                  color: AppConstants.primaryGold,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Image.asset(
                'logos/logo_fireshots.png',
                height: 40,
                width: 40,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.store,
                  color: AppConstants.primaryGold,
                  size: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Disfruta de los mejores licores y\nmomentos inolvidables',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppConstants.textGray),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              _SocialButton(
                imagePath: 'logos/whatsapp.png',
                label: 'Reserva',
                color: const Color(0xFF25D366),
                onTap: () => _openWhatsApp(context),
              ),
              _SocialButton(
                imagePath: 'logos/instagram.png',
                label: 'Instagram',
                color: const Color(0xFFE4405F),
                onTap: _openInstagram,
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Síguenos en redes y reserva con nosotros',
            style: TextStyle(fontSize: 12, color: AppConstants.textGray),
          ),
          const SizedBox(height: 24),
          const Divider(color: AppConstants.textGray),
          const SizedBox(height: 16),
          const Text(
            '© 2026 Fire Shots. Todos los derechos reservados.',
            style: TextStyle(fontSize: 12, color: AppConstants.textGray),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'El mejor lugar para vivirse la noche en grande',
            style: TextStyle(fontSize: 12, color: AppConstants.textGray),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String imagePath;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SocialButton({
    required this.imagePath,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color.withAlpha(102)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  Icon(Icons.link, color: color, size: 24),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: color),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends ConsumerWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      color: AppConstants.backgroundCard,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: product.imageUrl != null
                      ? Image.network(
                          product.imageUrl!,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.local_bar,
                            size: 48,
                            color: Colors.grey[600],
                          ),
                        )
                      : Icon(
                          Icons.local_bar,
                          size: 48,
                          color: Colors.grey[600],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppConstants.textWhite,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              AppConstants.formatCurrency(product.price),
              style: const TextStyle(
                color: AppConstants.primaryGold,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 36,
              child: ElevatedButton(
                onPressed: () =>
                    ref.read(cartProvider.notifier).addItem(product),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryGold,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.zero,
                ),
                child: const Text(
                  'Agregar',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
