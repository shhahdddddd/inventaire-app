import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'screens/login_screen.dart'; 
import 'package:interventionasm/screens/article_list_screen.dart';
import 'package:interventionasm/screens/add_article_screen.dart';
import 'package:interventionasm/screens/home_screen.dart';
import 'package:interventionasm/screens/bon_transfert_screen.dart';
import 'screens/inventaire_list_screen.dart';
import 'screens/create_inventaire_screen.dart';
import 'package:get_storage/get_storage.dart';
import 'screens/user_management_screen.dart';
import 'screens/register_screen.dart';
import 'controllers/article_controller.dart';
import 'package:interventionasm/controllers/user_controller.dart';
import 'controllers/login_controller.dart';
import 'screens/activate_user_screen.dart';
import 'screens/station_management_screen.dart';
import 'screens/supplier_management_screen.dart';
import 'screens/transfer_list_screen.dart';
import 'screens/purchase_management_screen.dart';
import 'controllers/station_controller.dart';
import 'controllers/supplier_controller.dart';
import 'controllers/inventory_controller.dart';
import 'controllers/transfer_controller.dart';
import 'controllers/purchase_controller.dart';
import 'controllers/user_invite_controller.dart';

// el main kima ay main hiya el entry point kif el programme yebda yexecuti menha hiya el programme principale kifh yebda el programme yexecuti menhaaa

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  
  // Only initialize essential controllers at startup
  Get.put(LoginController(), permanent: true);
  Get.put(UserController());
  
  // Initialize other controllers lazily when needed
  runApp(const MyApp());
}
//el widget principal mt3 el app mt3ek 
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      navigatorKey: navigatorKey,
      title: 'Intervention ASM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => SplashScreen()),
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/home', page: () => HomeScreen()),
        GetPage(name: '/register', page: () => RegisterScreen()),
        GetPage(name: '/articles', page: () => ArticleListScreen()),
        GetPage(name: '/add-article', page: () => AddArticleScreen()),
        GetPage(name: '/bon-transfert', page: () => BonTransfertScreen()),
        GetPage(name: '/transfer-list', page: () => TransferListScreen()),
        GetPage(name: '/inventaires', page: () => InventaireListScreen()),
        GetPage(name: '/create-inventaire', page: () => CreateInventaireScreen()),
        GetPage(name: '/user-management', page: () => UserManagementScreen()),
        GetPage(name: '/activate', page: () => ActivateUserScreen()),
        GetPage(name: '/station-management', page: () => StationManagementScreen()),
        GetPage(name: '/supplier-management', page: () => SupplierManagementScreen()),
        GetPage(name: '/purchase-management', page: () => PurchaseManagementScreen()),
      ],
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
    
    // Start animations
    _fadeController.forward();
    _scaleController.forward();
    
    // Navigate to login screen after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      Get.offAllNamed('/login');
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF333333),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with animation
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/inventory.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.business,
                            size: 60,
                            color: Colors.grey.shade600,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'ASMPro Inventory',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Gestion d\'inventaire intelligente',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 50),
                // Loading indicator
                const SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                    strokeWidth: 3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
