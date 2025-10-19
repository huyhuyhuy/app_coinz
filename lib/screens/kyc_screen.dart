import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../utils/app_localizations.dart';
import '../providers/auth_provider.dart';

class KYCScreen extends StatefulWidget {
  const KYCScreen({super.key});

  @override
  State<KYCScreen> createState() => _KYCScreenState();
}

class _KYCScreenState extends State<KYCScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idCardNumberController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _bankAccountNumberController = TextEditingController();
  final _bankAccountNameController = TextEditingController();

  File? _idCardFrontImage;
  File? _idCardBackImage;
  File? _selfieImage;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _idCardNumberController.dispose();
    _bankNameController.dispose();
    _bankAccountNumberController.dispose();
    _bankAccountNameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(String type) async {
    final localizations = AppLocalizations.of(context);
    
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(localizations.takePhoto),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await _picker.pickImage(
                  source: ImageSource.camera,
                  maxWidth: 1920,
                  maxHeight: 1080,
                  imageQuality: 85,
                );
                if (image != null) {
                  setState(() {
                    _setImage(type, File(image.path));
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(localizations.chooseFromGallery),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await _picker.pickImage(
                  source: ImageSource.gallery,
                  maxWidth: 1920,
                  maxHeight: 1080,
                  imageQuality: 85,
                );
                if (image != null) {
                  setState(() {
                    _setImage(type, File(image.path));
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _setImage(String type, File image) {
    switch (type) {
      case 'front':
        _idCardFrontImage = image;
        break;
      case 'back':
        _idCardBackImage = image;
        break;
      case 'selfie':
        _selfieImage = image;
        break;
    }
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement KYC submission
      // For now, show coming soon message
      final localizations = AppLocalizations.of(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            localizations.locale.languageCode == 'vi'
                ? '${localizations.comingSoon} - Chức năng KYC đang được phát triển'
                : '${localizations.comingSoon} - KYC feature under development',
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizations.kycVerification,
          style: GoogleFonts.roboto(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        localizations.locale.languageCode == 'vi'
                            ? 'Vui lòng điền đầy đủ thông tin để xác minh danh tính.'
                            : 'Please fill in all information for identity verification.',
                        style: GoogleFonts.roboto(
                          fontSize: 13,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Section 1: Personal Information
              Text(
                localizations.personalInformation,
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),

              // ID Card Number
              TextFormField(
                controller: _idCardNumberController,
                decoration: InputDecoration(
                  labelText: localizations.idCardNumber,
                  hintText: '123456789012',
                  prefixIcon: const Icon(Icons.credit_card),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localizations.pleaseEnterIdCardNumber;
                  }
                  if (value.length < 9) {
                    return localizations.locale.languageCode == 'vi'
                        ? 'Số CMND/CCCD không hợp lệ'
                        : 'Invalid ID card number';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Section 2: Photo Documents
              Text(
                localizations.photoDocuments,
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),

              // ID Card Front Photo
              _buildPhotoUploadCard(
                context,
                localizations.idCardFrontPhoto,
                _idCardFrontImage,
                () => _pickImage('front'),
                Icons.credit_card,
              ),

              const SizedBox(height: 12),

              // ID Card Back Photo
              _buildPhotoUploadCard(
                context,
                localizations.idCardBackPhoto,
                _idCardBackImage,
                () => _pickImage('back'),
                Icons.credit_card,
              ),

              const SizedBox(height: 12),

              // Selfie Photo
              _buildPhotoUploadCard(
                context,
                localizations.selfiePhoto,
                _selfieImage,
                () => _pickImage('selfie'),
                Icons.face,
              ),

              const SizedBox(height: 24),

              // Section 3: Bank Information
              Text(
                localizations.bankInformation,
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),

              // Bank Name
              TextFormField(
                controller: _bankNameController,
                decoration: InputDecoration(
                  labelText: localizations.bankName,
                  hintText: 'Vietcombank, BIDV, Techcombank...',
                  prefixIcon: const Icon(Icons.account_balance),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localizations.pleaseEnterBankName;
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Bank Account Number
              TextFormField(
                controller: _bankAccountNumberController,
                decoration: InputDecoration(
                  labelText: localizations.bankAccountNumber,
                  hintText: '1234567890',
                  prefixIcon: const Icon(Icons.numbers),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localizations.pleaseEnterBankAccountNumber;
                  }
                  if (value.length < 6) {
                    return localizations.locale.languageCode == 'vi'
                        ? 'Số tài khoản không hợp lệ'
                        : 'Invalid account number';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Bank Account Name
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  final registeredName = authProvider.userName ?? '';
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _bankAccountNameController,
                        decoration: InputDecoration(
                          labelText: localizations.bankAccountName,
                          hintText: 'NGUYEN VAN A',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        textCapitalization: TextCapitalization.characters,
                        onChanged: (value) {
                          // Trigger validation khi user nhập
                          setState(() {});
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return localizations.pleaseEnterBankAccountName;
                          }
                          
                          // ✅ Validation: Check khớp với tên đăng ký
                          final inputName = value.trim().toUpperCase();
                          final expectedName = registeredName.trim().toUpperCase();
                          
                          // Normalize spaces (loại bỏ khoảng trắng thừa)
                          final normalizedInput = inputName.replaceAll(RegExp(r'\s+'), ' ');
                          final normalizedExpected = expectedName.replaceAll(RegExp(r'\s+'), ' ');
                          
                          if (normalizedInput != normalizedExpected) {
                            return localizations.locale.languageCode == 'vi'
                                ? '❌ Tên tài khoản phải khớp với tên đăng ký: "$registeredName"'
                                : '❌ Account name must match registration name: "$registeredName"';
                          }
                          
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // ⚠️ Thông báo quan trọng về tên tài khoản ngân hàng
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade300, width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red.shade700,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    localizations.locale.languageCode == 'vi'
                                        ? '⚠️ Tên tài khoản ngân hàng phải:'
                                        : '⚠️ Bank account name must:',
                                    style: GoogleFonts.roboto(
                                      fontSize: 13,
                                      color: Colors.red.shade900,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.only(left: 28),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    localizations.locale.languageCode == 'vi'
                                        ? '1. Trùng khớp với tên trên CMND/CCCD'
                                        : '1. Match with name on ID card',
                                    style: GoogleFonts.roboto(
                                      fontSize: 12,
                                      color: Colors.red.shade800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: Colors.red.shade200),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.info, 
                                          size: 16, 
                                          color: Colors.blue.shade700,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            localizations.locale.languageCode == 'vi'
                                                ? 'Nếu không khớp, KYC sẽ thất bại!'
                                                : 'If not matched, KYC will fail!',
                                            style: GoogleFonts.roboto(
                                              fontSize: 11,
                                              color: Colors.blue.shade900,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // ✅ Live validation indicator
                      if (_bankAccountNameController.text.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: _buildValidationIndicator(
                            _bankAccountNameController.text.trim().toUpperCase().replaceAll(RegExp(r'\s+'), ' '),
                            registeredName.trim().toUpperCase().replaceAll(RegExp(r'\s+'), ' '),
                            localizations,
                          ),
                        ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _handleSubmit,
                  icon: const Icon(Icons.check_circle, size: 24),
                  label: Text(
                    '${localizations.submit} (${localizations.comingSoon})',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Warning
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        localizations.locale.languageCode == 'vi'
                            ? 'Chức năng gửi KYC đang được phát triển. Dữ liệu chưa được lưu.'
                            : 'KYC submission feature is under development. Data will not be saved.',
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          color: Colors.orange.shade700,
                        ),
                      ),
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

  Widget _buildPhotoUploadCard(
    BuildContext context,
    String title,
    File? imageFile,
    VoidCallback onTap,
    IconData icon,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: imageFile != null 
                      ? Colors.green.shade50
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: imageFile != null 
                        ? Colors.green.shade300
                        : Colors.grey.shade300,
                  ),
                ),
                child: imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          imageFile,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(
                        icon,
                        size: 30,
                        color: Colors.grey.shade400,
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      imageFile != null
                          ? AppLocalizations.of(context).locale.languageCode == 'vi'
                              ? 'Đã chọn ảnh'
                              : 'Photo selected'
                          : AppLocalizations.of(context).locale.languageCode == 'vi'
                              ? 'Nhấn để chọn ảnh'
                              : 'Tap to select photo',
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        color: imageFile != null 
                            ? Colors.green.shade700
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                imageFile != null ? Icons.check_circle : Icons.upload,
                color: imageFile != null 
                    ? Colors.green.shade600
                    : Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget hiển thị trạng thái validation real-time
  Widget _buildValidationIndicator(
    String inputName,
    String expectedName,
    AppLocalizations localizations,
  ) {
    final isMatch = inputName == expectedName;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isMatch ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isMatch ? Colors.green.shade300 : Colors.red.shade300,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isMatch ? Icons.check_circle : Icons.cancel,
            color: isMatch ? Colors.green.shade700 : Colors.red.shade700,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isMatch
                  ? (localizations.locale.languageCode == 'vi'
                      ? '✅ Tên khớp! Bạn có thể tiếp tục.'
                      : '✅ Name matched! You can proceed.')
                  : (localizations.locale.languageCode == 'vi'
                      ? '❌ Tên chưa khớp. Vui lòng nhập chính xác: "$expectedName"'
                      : '❌ Name not matched. Please enter exactly: "$expectedName"'),
              style: GoogleFonts.roboto(
                fontSize: 12,
                color: isMatch ? Colors.green.shade900 : Colors.red.shade900,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

