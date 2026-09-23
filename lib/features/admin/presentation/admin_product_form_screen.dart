import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fireshots_pos/core/constants/app_constants.dart';
import 'package:fireshots_pos/core/services/cloudinary_service.dart';
import 'package:fireshots_pos/features/menu/data/product_model.dart';
import 'package:fireshots_pos/features/menu/providers/menu_provider.dart';

class AdminProductFormScreen extends ConsumerStatefulWidget {
  const AdminProductFormScreen({super.key});

  @override
  ConsumerState<AdminProductFormScreen> createState() =>
      _AdminProductFormScreenState();
}

class _AdminProductFormScreenState
    extends ConsumerState<AdminProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  String _selectedCategory = 'Licores Nacionales';
  Product? _editingProduct;
  String? _imageUrl;
  bool _isUploading = false;

  final _cloudinaryService = CloudinaryService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Product?;
      if (args != null) {
        setState(() {
          _editingProduct = args;
          _nameController.text = args.name;
          _priceController.text = args.price.toStringAsFixed(0);
          _stockController.text = args.stock.toString();
          _imageUrl = args.imageUrl;
          _selectedCategory = args.category;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    final file = await _cloudinaryService.pickImage();
    if (file == null) return;

    setState(() => _isUploading = true);
    try {
      final url = await _cloudinaryService.uploadProductImage(file);
      if (url != null && mounted) {
        setState(() => _imageUrl = url);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al subir imagen. Verifica tu cuenta de Cloudinary.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir imagen: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final product = Product(
      id: _editingProduct?.id ?? '',
      name: _nameController.text.trim(),
      price: double.tryParse(_priceController.text.trim()) ?? 0,
      category: _selectedCategory,
      stock: int.tryParse(_stockController.text.trim()) ?? 0,
      imageUrl: _imageUrl,
      isAvailable: _editingProduct?.isAvailable ?? true,
    );

    try {
      if (_editingProduct != null) {
        await ref.read(menuServiceProvider).updateProduct(product);
      } else {
        await ref.read(menuServiceProvider).addProduct(product);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _editingProduct != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Producto' : 'Nuevo Producto'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Producto',
                  prefixIcon: Icon(Icons.label_outline),
                ),
                validator: (v) =>
                    v?.isEmpty ?? true ? 'Nombre requerido' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: AppConstants.productCategories.map((c) {
                  return DropdownMenuItem(value: c, child: Text(c));
                }).toList(),
                onChanged: (v) =>
                    setState(() => _selectedCategory = v!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Precio COP',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v?.isEmpty ?? true ? 'Precio requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(
                  labelText: 'Stock',
                  prefixIcon: Icon(Icons.inventory),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              const Text(
                'Imagen del Producto',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.textWhite,
                ),
              ),
              const SizedBox(height: 8),
              if (_imageUrl != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      _imageUrl!,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Container(
                        height: 120,
                        color: AppConstants.backgroundCard,
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image, size: 32, color: AppConstants.textGray),
                              SizedBox(height: 4),
                              Text('Vista previa no disponible',
                                  style: TextStyle(fontSize: 12, color: AppConstants.textGray)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isUploading ? null : _pickAndUploadImage,
                      icon: _isUploading
                          ? const SizedBox(
                              width: 18, height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(Icons.image_outlined, color: AppConstants.primaryGold),
                      label: Text(
                        _isUploading ? 'Subiendo...' : 'Subir imagen',
                        style: const TextStyle(color: AppConstants.textWhite),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppConstants.primaryGold),
                      ),
                    ),
                  ),
                  if (_imageUrl != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => setState(() => _imageUrl = null),
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _save,
                  child: Text(isEditing ? 'ACTUALIZAR' : 'CREAR PRODUCTO'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
