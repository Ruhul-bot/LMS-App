import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/course_provider.dart';
import '../../widgets/custom_button.dart';

class PaymentScreen extends StatefulWidget {
  final String courseId;
  final double amount;

  const PaymentScreen({
    super.key,
    required this.courseId,
    required this.amount,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late Razorpay _razorpay;
  bool _isProcessing = false;
  String? _errorMessage;
  bool _isPaymentSuccess = false;

  @override
  void initState() {
    super.initState();
    _initializeRazorpay();
  }

  void _initializeRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Payment successful, enroll the user in the course
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);

    courseProvider
        .enrollInCourse(authProvider.userModel!.uid, widget.courseId)
        .then((success) {
          setState(() {
            _isProcessing = false;
            _isPaymentSuccess = success;
            if (!success) {
              _errorMessage =
                  'Failed to enroll in the course. Please contact support.';
            }
          });
        })
        .catchError((error) {
          setState(() {
            _isProcessing = false;
            _errorMessage = error.toString();
          });
        });
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
      _isProcessing = false;
      _errorMessage = response.message ?? 'Payment failed. Please try again.';
    });
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('External wallet selected: ${response.walletName}'),
      ),
    );
  }

  void _openCheckout() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.userModel;

    if (user == null) {
      setState(() {
        _errorMessage = 'User information not available. Please log in again.';
      });
      return;
    }

    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    final course = courseProvider.getCourseById(widget.courseId);

    if (course == null) {
      setState(() {
        _errorMessage = 'Course information not available.';
      });
      return;
    }

    var options = {
      'key': 'rzp_test_YOUR_KEY_HERE', // Replace with your Razorpay API key
      'amount':
          (widget.amount * 100)
              .toInt(), // Amount in smallest currency unit (paise for INR)
      'name': 'LMS App',
      'description': 'Payment for ${course.title}',
      'prefill': {
        'contact': user.phoneNumber ?? '',
        'email': user.email,
        'name': user.displayName,
      },
      'external': {
        'wallets': ['paytm', 'gpay'],
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final courseProvider = Provider.of<CourseProvider>(context);
    final course = courseProvider.getCourseById(widget.courseId);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Text(
          'Payment',
          style: AppTextStyles.heading2.copyWith(color: Colors.white),
        ),
      ),
      body:
          _isPaymentSuccess
              ? _buildSuccessScreen()
              : _buildPaymentScreen(course?.title ?? 'Course'),
    );
  }

  Widget _buildPaymentScreen(String courseTitle) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Payment Header
          Text('Course Purchase', style: AppTextStyles.heading1),
          const SizedBox(height: 8),
          Text(
            'Complete your payment to enroll in this course',
            style: AppTextStyles.bodyText.copyWith(
              color: AppColors.lightTextColor,
            ),
          ),
          const SizedBox(height: 32),

          // Order Summary Card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order Summary', style: AppTextStyles.heading3),
                  const SizedBox(height: 16),

                  // Course details
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.school,
                            color: AppColors.primaryColor,
                            size: 32,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              courseTitle,
                              style: AppTextStyles.bodyText.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Full Course Access',
                              style: AppTextStyles.smallText,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '₹${widget.amount.toStringAsFixed(2)}',
                        style: AppTextStyles.bodyText.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 32),

                  // Price breakdown
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Course Price', style: AppTextStyles.bodyText),
                      Text(
                        '₹${widget.amount.toStringAsFixed(2)}',
                        style: AppTextStyles.bodyText,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Discount', style: AppTextStyles.bodyText),
                      Text('₹0.00', style: AppTextStyles.bodyText),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tax', style: AppTextStyles.bodyText),
                      Text('₹0.00', style: AppTextStyles.bodyText),
                    ],
                  ),

                  const Divider(height: 32),

                  // Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total', style: AppTextStyles.heading3),
                      Text(
                        '₹${widget.amount.toStringAsFixed(2)}',
                        style: AppTextStyles.heading3.copyWith(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Payment Methods
          Text('Payment Methods', style: AppTextStyles.heading3),
          const SizedBox(height: 16),

          // Payment methods list
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            ),
            elevation: 2,
            child: Column(
              children: [
                _buildPaymentMethodItem(
                  icon: Icons.credit_card,
                  title: 'Credit/Debit Card',
                  subtitle: 'Pay using your card',
                  isSelected: true,
                ),
                const Divider(height: 1),
                _buildPaymentMethodItem(
                  icon: Icons.account_balance,
                  title: 'Net Banking',
                  subtitle: 'Pay using your bank account',
                ),
                const Divider(height: 1),
                _buildPaymentMethodItem(
                  icon: Icons.smartphone,
                  title: 'UPI',
                  subtitle: 'Google Pay, PhonePe, Paytm',
                ),
              ],
            ),
          ),

          // Error message
          if (_errorMessage != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.errorColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.errorColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: AppTextStyles.bodyText.copyWith(
                        color: AppColors.errorColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 32),

          // Payment button
          CustomButton(
            text: 'Pay ₹${widget.amount.toStringAsFixed(2)}',
            onPressed: _isProcessing ? () {} : _openCheckout,
            isLoading: _isProcessing,
            width: double.infinity,
            height: 50,
          ),

          const SizedBox(height: 16),

          // Terms and conditions
          Center(
            child: Text(
              'By completing this purchase, you agree to our Terms of Service and Privacy Policy.',
              style: AppTextStyles.smallText.copyWith(
                color: AppColors.lightTextColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodItem({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isSelected = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primaryColor : AppColors.lightTextColor,
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyText.copyWith(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(subtitle, style: AppTextStyles.smallText),
      trailing:
          isSelected
              ? const Icon(Icons.check_circle, color: AppColors.primaryColor)
              : null,
      onTap: () {
        // In a real app, you would switch between payment methods
      },
    );
  }

  Widget _buildSuccessScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              color: AppColors.successColor,
              size: 80,
            ),
            const SizedBox(height: 24),
            Text(
              'Payment Successful!',
              style: AppTextStyles.heading1.copyWith(
                color: AppColors.successColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'You have successfully enrolled in the course.',
              style: AppTextStyles.bodyText,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Start Learning',
              onPressed: () {
                // Navigate back to the course detail screen
                Navigator.of(context).pop();
              },
              width: 200,
            ),
          ],
        ),
      ),
    );
  }
}
