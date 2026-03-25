import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mosa/config/app_colors.dart';
import 'package:mosa/router/app_routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  // --- Mockup Illustrations for the 5 pages ---
  Widget _buildSlide1Illustration() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                const Text('Tháng 9', style: TextStyle(color: Colors.black87, fontSize: 14)),
                const Text(
                  '\$2,500',
                  style: TextStyle(color: AppColors.error, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 120,
                  height: 180,
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.4),
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                const Text('Tháng 10', style: TextStyle(color: Colors.black87, fontSize: 14)),
                const Text(
                  '\$1,625',
                  style: TextStyle(color: AppColors.error, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.8),
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSlide2Illustration() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background upward line/area representing growth
        Positioned.fill(
          child: Align(
            alignment: Alignment.bottomRight,
            child: ClipPath(
              clipper: _UpwardGrowthClipper(),
              child: Container(color: AppColors.success.withOpacity(0.2)),
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 40),
              child: Text('Tiết kiệm trong tháng', style: TextStyle(fontSize: 16)),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 40, bottom: 24),
              child: Row(
                children: [
                  const Text('\$840', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(4)),
                    child: const Text('+ 15%', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            _buildAchievementCard(
              icon: Icons.phone_android,
              color: Colors.orange,
              title: 'Điện thoại mới',
              amount: '+\$320',
            ),
            const SizedBox(height: 12),
            _buildAchievementCard(
              icon: Icons.savings,
              color: Colors.green,
              title: 'Tài khoản tiết kiệm',
              amount: '+\$520',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAchievementCard({
    required IconData icon,
    required Color color,
    required String title,
    required String amount,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 24),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                  child: const Icon(Icons.check, color: Colors.white, size: 10),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
          Text(amount, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.success)),
        ],
      ),
    );
  }

  Widget _buildSlide3Illustration() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLighter, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tổng số dư',
                  style: TextStyle(fontSize: 18, color: AppColors.success, fontWeight: FontWeight.bold),
                ),
                const Text(
                  '\$6,787',
                  style: TextStyle(fontSize: 18, color: AppColors.success, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 32, thickness: 1),
            _buildWalletRow(Icons.wallet, Colors.orange, 'Tiền mặt', '\$873'),
            const SizedBox(height: 16),
            _buildWalletRow(Icons.credit_card, Colors.teal, 'Thẻ tín dụng', '\$2,000'),
            const SizedBox(height: 16),
            _buildWalletRow(Icons.savings, Colors.blueGrey, 'Tài khoản tiết kiệm', '\$3,914'),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletRow(IconData icon, Color color, String title, String amount) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(child: Text(title, style: const TextStyle(fontSize: 16))),
        Text(amount, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> slides = [
      {'image': _buildSlide1Illustration(), 'title': 'Cắt giảm những chi phí không cần thiết'},
      {'image': _buildSlide2Illustration(), 'title': 'Gia tăng tiết kiệm đều đặn hàng tháng'},
      {'image': _buildSlide3Illustration(), 'title': 'Quản lý tất cả ở một nơi'},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // Container(
                      //   padding: const EdgeInsets.all(4),
                      //   decoration: BoxDecoration(
                      //     color: AppColors.primary.withOpacity(0.1),
                      //     borderRadius: BorderRadius.circular(8),
                      //   ),
                      //   child: const Icon(Icons.account_balance_wallet, color: AppColors.primary, size: 24),
                      // ),
                      // const SizedBox(width: 8),
                      const Text(
                        'MOSA',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: AppColors.borderLighter, borderRadius: BorderRadius.circular(16)),
                    child: const Text(
                      'TIẾNG VIỆT',
                      style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            // PageView constraints: ensure it expands but has enough height
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: slides.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Expanded(child: slides[index]['image']),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                        child: Text(
                          slides[index]['title'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Page Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                slides.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  width: _currentPage == index ? 8.0 : 8.0,
                  height: 8.0,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? AppColors.success : AppColors.borderLighter,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to Register (Currently goes to Login as placeholder, update if register is created)
                      context.push(AppRoutes.login);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: const Text(
                      'ĐĂNG KÝ MIỄN PHÍ',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {
                      context.push(AppRoutes.login);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: const Text('ĐĂNG NHẬP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      context.go(AppRoutes.overview);
                    },
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: const Text(
                      'Tiếp tục với tư cách khách',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                        decorationColor: AppColors.textHint,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpwardGrowthClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(0, size.height * 0.8);
    path.lineTo(size.width, size.height * 0.2);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
