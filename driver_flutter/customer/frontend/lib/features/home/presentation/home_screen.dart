import '../../../core/location/domain/location_models.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/theme/typography.dart';
import '../../quote/presentation/widgets/gorush_ride_category_card.dart';
import '../../quote/presentation/widgets/gorush_metro_card.dart';
import '../../../shared/widgets/map/gorush_location_pill.dart';
import '../../../shared/map/maps_provider.dart';
import '../../../core/location/location_service.dart';
import '../../../core/ride/domain/ride_models.dart';
import '../../../core/pricing/domain/ride_category.dart';
import '../../../core/pricing/domain/quote_models.dart';
import '../../../core/pricing/domain/money.dart';
import '../../safety/presentation/sos_emergency_sheet.dart';
import '../../ride/presentation/ride_status_screen.dart';
import '../../../core/ride/data/ride_repository.dart';
import '../../../core/pricing/data/quote_repository.dart';
import '../../../core/realtime/application/realtime_service.dart';
import '../../../core/security/token_manager.dart';
import '../../../core/security/secure_storage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final OpenStreetMapProviderImpl _mapsProvider = OpenStreetMapProviderImpl();
  final LocationServiceImpl _locationService = LocationServiceImpl();
  final TextEditingController _searchController = TextEditingController();
  
  bool _isLoadingLocation = false;
  int _selectedCategoryIndex = 3; // Default selected: GoSedan (index 3)
  String _paymentMethod = 'Google Pay';
  bool _showNearbyVehicles = true;
  String _currentAddress = 'G-Block, Sector 63, Noida';
  String _destinationAddress = 'Select destination...';

  // Saved / Favourites / Recent Places Data
  final Map<String, Map<String, String>> _savedPlaces = {
    'home': {
      'title': 'Home',
      'subtitle': 'G-Block, Sector 63, Noida',
      'address': 'G-Block, Sector 63, Noida, UP 201301',
    },
    'work': {
      'title': 'Work',
      'subtitle': 'Noida City Centre, Sector 32',
      'address': 'Wave City Center, Sector 32, Noida',
    },
    'fav1': {
      'title': 'DLF Mall of India',
      'subtitle': 'Sector 18, Noida',
      'address': 'Plot M-03, Sector 18, Noida, UP',
    },
  };

  final List<Map<String, String>> _recentPlaces = [
    {
      'title': 'Indira Gandhi International Airport (DEL)',
      'subtitle': 'Terminal 3, New Delhi',
      'address': 'New Delhi, Delhi 110037',
    },
    {
      'title': 'Connaught Place',
      'subtitle': 'Inner Circle, New Delhi',
      'address': 'Connaught Place, New Delhi, Delhi 110001',
    },
  ];

  // Ride Categories with Nearby Vehicle Count (Bike, Bike lite, Auto, Auto lite, Cab, Cab lite, Prime sedan, 7 seter)
  final List<Map<String, dynamic>> _rideCategories = [
    {
      'title': 'Bike',
      'capacity': '1',
      'eta': '2 min away',
      'fare': '₹45',
      'icon': Icons.two_wheeler_rounded,
      'nearbyCount': 6,
      'desc': 'Quickest single-rider bike trip',
    },
    {
      'title': 'Bike lite',
      'capacity': '1',
      'eta': '3 min away',
      'fare': '₹35',
      'icon': Icons.two_wheeler_rounded,
      'nearbyCount': 8,
      'desc': 'Budget-friendly quick bike ride',
    },
    {
      'title': 'Auto',
      'capacity': '3',
      'eta': '4 min away',
      'fare': '₹65',
      'icon': Icons.electric_rickshaw_rounded,
      'nearbyCount': 5,
      'desc': 'Doorstep 3-seater auto rickshaw',
    },
    {
      'title': 'Auto lite',
      'capacity': '3',
      'eta': '5 min away',
      'fare': '₹52',
      'icon': Icons.electric_rickshaw_rounded,
      'nearbyCount': 4,
      'desc': 'Economical pocket-friendly auto',
    },
    {
      'title': 'Cab',
      'capacity': '4',
      'eta': '3 min away',
      'fare': '₹125',
      'icon': Icons.directions_car_filled_rounded,
      'nearbyCount': 7,
      'desc': 'Comfortable hatchback AC cab',
    },
    {
      'title': 'Cab lite',
      'capacity': '4',
      'eta': '4 min away',
      'fare': '₹98',
      'icon': Icons.directions_car_filled_rounded,
      'nearbyCount': 6,
      'desc': 'Low fare everyday hatchback ride',
    },
    {
      'title': 'Prime sedan',
      'capacity': '4',
      'eta': '3 min away',
      'fare': '₹165',
      'icon': Icons.local_taxi_rounded,
      'nearbyCount': 5,
      'desc': 'Top-rated spacious sedan (Dzire, Etios)',
    },
    {
      'title': '7 seter',
      'capacity': '7',
      'eta': '5 min away',
      'fare': '₹220',
      'icon': Icons.airport_shuttle_rounded,
      'nearbyCount': 3,
      'desc': 'Spacious 7-seater SUV (Ertiga, Innova)',
    },
    {
      'title': 'Metro',
      'capacity': 'Unlimited',
      'eta': 'Coming Soon',
      'fare': 'Coming Soon',
      'icon': Icons.subway_rounded,
      'nearbyCount': 0,
      'desc': 'Fast • Affordable • Direct city transit',
      'isMetro': true,
    },
  ];

  @override
  void dispose() {
    _mapsProvider.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _requestCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      final position = await _locationService.getCurrentPosition();
      _mapsProvider.animateCamera(position.coordinate, zoom: 16);
      setState(() {
        _currentAddress = 'Sector 63, Noida (GPS Fixed)';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📍 Current GPS Location updated'),
            backgroundColor: Color(0xFF00C853),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('GPS updated: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  void _openDestinationSearchModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final query = _searchController.text.trim();
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Search Destination', style: GoRushTypography.headline.copyWith(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 14),

                // Search Input Box
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF00C853)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    onChanged: (val) => setModalState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Search address, landmark, or metro station...',
                      prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF00C853)),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Live Autocomplete Results or Saved Places
                Expanded(
                  child: query.isNotEmpty
                      ? FutureBuilder<http.Response>(
                          future: http.get(Uri.parse('https://nominatim.openstreetmap.org/search?format=json&q=$query')),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                            final List<dynamic> results = jsonDecode(snapshot.data!.body);
                            return ListView.builder(
                              itemCount: results.length,
                              itemBuilder: (context, index) {
                                final place = results[index];
                                return ListTile(
                                  leading: const Icon(Icons.location_on_rounded, color: Color(0xFF00C853)),
                                  title: Text(place['display_name'].split(',').first, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text(place['display_name']),
                                  onTap: () async {
                                    setState(() {
                                      _destinationAddress = place['display_name'];
                                      _mapsProvider.animateCamera(GeoCoordinate(
                                        latitude: double.parse(place['lat']),
                                        longitude: double.parse(place['lon']),
                                      ), zoom: 16);
                                    });
                                    Navigator.pop(context);
                                    
                                    try {
                                      final currentPos = await _locationService.getCurrentPosition();
                                      final startLat = currentPos.coordinate.latitude;
                                      final startLng = currentPos.coordinate.longitude;
                                      final endLat = double.parse(place['lat']);
                                      final endLng = double.parse(place['lon']);
                                      
                                      final response = await http.get(Uri.parse(
                                          'https://router.project-osrm.org/route/v1/driving/$startLng,$startLat;$endLng,$endLat?overview=full&geometries=geojson'));
                                      
                                      if (response.statusCode == 200) {
                                        final data = jsonDecode(response.body);
                                        final coords = data['routes'][0]['geometry']['coordinates'] as List;
                                        
                                        final polylinePoints = coords.map((c) => GeoCoordinate(
                                          latitude: (c[1] as num).toDouble(),
                                          longitude: (c[0] as num).toDouble(),
                                        )).toList();
                                        
                                        _mapsProvider.setRoutePolyline(polylinePoints);
                                        _mapsProvider.setMarkers([
                                          GeoCoordinate(latitude: startLat, longitude: startLng),
                                          GeoCoordinate(latitude: endLat, longitude: endLng),
                                        ]);
                                      }
                                    } catch (_) {}
                                  },
                                );
                              },
                            );
                          },
                        )
                      : ListView(
                          children: [
                            // Saved Places Section
                            Text('SAVED PLACES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[600], letterSpacing: 0.8)),
                            const SizedBox(height: 8),
                            _buildSavedPlaceTile(
                              icon: Icons.home_rounded,
                              iconColor: const Color(0xFF00C853),
                              title: 'Home',
                              address: _savedPlaces['home']!['address']!,
                              onTap: () {
                                setState(() => _destinationAddress = _savedPlaces['home']!['title']!);
                                Navigator.pop(context);
                              },
                            ),
                            _buildSavedPlaceTile(
                              icon: Icons.work_rounded,
                              iconColor: Colors.blue,
                              title: 'Work',
                              address: _savedPlaces['work']!['address']!,
                              onTap: () {
                                setState(() => _destinationAddress = _savedPlaces['work']!['title']!);
                                Navigator.pop(context);
                              },
                            ),
                            _buildSavedPlaceTile(
                              icon: Icons.star_rounded,
                              iconColor: Colors.amber,
                              title: _savedPlaces['fav1']!['title']!,
                              address: _savedPlaces['fav1']!['address']!,
                              onTap: () {
                                setState(() => _destinationAddress = _savedPlaces['fav1']!['title']!);
                                Navigator.pop(context);
                              },
                            ),

                            const Divider(height: 24),

                            // Recent Places Section
                            Text('RECENT SEARCHES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[600], letterSpacing: 0.8)),
                            const SizedBox(height: 8),
                            ..._recentPlaces.map(
                              (p) => _buildSavedPlaceTile(
                                icon: Icons.history_rounded,
                                iconColor: Colors.grey,
                                title: p['title']!,
                                address: p['address']!,
                                onTap: () {
                                  setState(() => _destinationAddress = p['title']!);
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSavedPlaceTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String address,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(address, style: TextStyle(fontSize: 12, color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis),
      onTap: onTap,
    );
  }

  void _showPaymentSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Payment Method', style: GoRushTypography.headline.copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF00C853)),
              title: const Text('Google Pay (UPI)', style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: _paymentMethod == 'Google Pay' ? const Icon(Icons.check_circle, color: Color(0xFF00C853)) : null,
              onTap: () {
                setState(() => _paymentMethod = 'Google Pay');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.credit_card_rounded, color: Colors.blue),
              title: const Text('GoRush Wallet (₹450)'),
              trailing: _paymentMethod == 'GoRush Wallet' ? const Icon(Icons.check_circle, color: Color(0xFF00C853)) : null,
              onTap: () {
                setState(() => _paymentMethod = 'GoRush Wallet');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.payments_rounded, color: Colors.orange),
              title: const Text('Cash on Delivery'),
              trailing: _paymentMethod == 'Cash' ? const Icon(Icons.check_circle, color: Color(0xFF00C853)) : null,
              onTap: () {
                setState(() => _paymentMethod = 'Cash');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showMetroComingSoonSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Metro Icon Badge
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1565C0).withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.subway_rounded,
                color: Colors.white,
                size: 36,
                semanticLabel: 'Metro ride option',
              ),
            ),
            const SizedBox(height: 16),

            // Metro Title
            const Text(
              'Metro',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
                letterSpacing: -0.5,
              ),
              semanticsLabel: 'Metro — Public Transport Option',
            ),
            const SizedBox(height: 6),

            // Description
            Text(
              'Fast • Affordable • Direct city transit',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 24),

            // Info Rows
            _buildMetroInfoRow(
              icon: Icons.access_time_rounded,
              label: 'Estimated Time',
              value: '—',
              valueColor: Colors.grey[500]!,
            ),
            const SizedBox(height: 10),
            _buildMetroInfoRow(
              icon: Icons.confirmation_number_rounded,
              label: 'Fare',
              value: '—',
              valueColor: Colors.grey[500]!,
            ),
            const SizedBox(height: 10),
            _buildMetroInfoRow(
              icon: Icons.train_rounded,
              label: 'Station',
              value: '—',
              valueColor: Colors.grey[500]!,
            ),
            const SizedBox(height: 24),

            // Coming Soon Badge
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF1E88E5).withValues(alpha: 0.4)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.rocket_launch_rounded, color: Color(0xFF1565C0), size: 22),
                  const SizedBox(height: 6),
                  const Text(
                    'Metro booking — Coming Soon',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'We are working on integrating Metro into GoRush.',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Close Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text(
                  'Got it',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetroInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF1565C0)),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmRideBooking() async {
    final selectedRide = _rideCategories[_selectedCategoryIndex];

    // Metro: show Coming Soon sheet instead of booking flow
    if (selectedRide['isMetro'] == true) {
      _showMetroComingSoonSheet();
      return;
    }

    final rootContext = context;
    
    showDialog(
      context: rootContext,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF00C853)),
      ),
    );

    try {
      final quoteRepo = HttpQuoteRepository();
      final rideRepo = HttpRideRepository();
      
      final quotes = await quoteRepo.generateQuotes(
        distanceMeters: 8500,
        durationSeconds: 1320,
      );
      
      if (quotes.isEmpty) throw Exception('No quotes available');
      
      final quote = quotes.firstWhere(
        (q) => q.rideCategory.id == selectedRide['id'],
        orElse: () => quotes.first,
      );

      final activeRide = await rideRepo.createRide(
        quoteId: quote.quoteId,
        idempotencyKey: DateTime.now().millisecondsSinceEpoch.toString(),
        pickupAddress: _currentAddress.isEmpty ? 'G-Block, Sector 63, Noida' : _currentAddress,
        dropoffAddress: _searchController.text.isEmpty ? 'Noida City Centre, Sector 32' : _searchController.text,
        paymentMethod: _paymentMethod,
      );

      Navigator.of(rootContext).pop(); // Dismiss loading

      final tokenManager = TokenManager(SecureStorageImpl());
      final token = await tokenManager.getAccessToken() ?? 'mock_token';

      final realtimeService = SocketIoRealtimeService();
      realtimeService.connect(token);
      
      Navigator.of(rootContext).push(
        MaterialPageRoute(
          builder: (_) => RideStatusScreen(
            initialRide: activeRide,
            repository: rideRepo,
            realtimeService: realtimeService,
          ),
        ),
      );
    } catch (e) {
      Navigator.of(rootContext).pop(); // Dismiss loading
      ScaffoldMessenger.of(rootContext).showSnackBar(
        SnackBar(
          content: Text('Failed to book ride: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final activeRideCategory = _rideCategories[_selectedCategoryIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 440),
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00C853).withValues(alpha: 0.2),
                blurRadius: 40,
                spreadRadius: 4,
              ),
            ],
          ),
          child: ClipRRect(
            child: Stack(
              children: [
                // 1. Live OpenStreetMap using MapsProvider
                Positioned.fill(
                  child: _mapsProvider.buildMap(),
                ),

                // 2. Nearby Vehicles Overlay Markers
                if (_showNearbyVehicles) ...[
                  Positioned(
                    top: 260,
                    left: 120,
                    child: _buildNearbyVehiclePin('GoSedan', 'Rahul (3m away)'),
                  ),
                  Positioned(
                    top: 210,
                    right: 80,
                    child: _buildNearbyVehiclePin('GoBike', 'Vikram (2m away)'),
                  ),
                  Positioned(
                    top: 310,
                    right: 140,
                    child: _buildNearbyVehiclePin('GoAuto', 'Amit (4m away)'),
                  ),
                ],

                // 3. Top Header Overlay (Profile + Wallet + SOS + Nearby Vehicle Toggle)
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox.shrink(),

                            // Wallet + SOS
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: const Color(0xFF00C853)),
                                  ),
                                  child: Row(
                                    children: const [
                                      Icon(Icons.electric_bolt_rounded, color: Color(0xFF00C853), size: 14),
                                      SizedBox(width: 4),
                                      Text(
                                        '₹450',
                                        style: TextStyle(
                                          color: Color(0xFF00C853),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () => SosEmergencySheet.show(context),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFDC2626),
                                      borderRadius: BorderRadius.all(Radius.circular(16)),
                                      boxShadow: [
                                        BoxShadow(color: Colors.redAccent, blurRadius: 8, spreadRadius: 1),
                                      ],
                                    ),
                                    child: const Text(
                                      'SOS',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Interactive Destination Search Box ("Where to?")
                        GestureDetector(
                          onTap: _openDestinationSearchModal,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFF00C853).withValues(alpha: 0.4), width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            child: Row(
                              children: [
                                const Icon(Icons.search_rounded, color: Color(0xFF00C853), size: 24),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.my_location_rounded, size: 10, color: Color(0xFF00C853)),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              _currentAddress,
                                              style: TextStyle(fontSize: 10, color: Colors.grey[700]),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _destinationAddress,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: _destinationAddress.contains('Select') ? Colors.black45 : Colors.black87,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(color: Color(0xFFE8F5E9), shape: BoxShape.circle),
                                  child: const Icon(Icons.arrow_forward_rounded, color: Color(0xFF00C853), size: 16),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Saved & Shortcut Places Chips (Home, Work, Favourites)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildShortcutChip(
                                icon: Icons.home_rounded,
                                title: _savedPlaces['home']!['title']!,
                                subtitle: _savedPlaces['home']!['subtitle']!,
                                onTap: () => setState(() => _destinationAddress = _savedPlaces['home']!['title']!),
                              ),
                              const SizedBox(width: 8),
                              _buildShortcutChip(
                                icon: Icons.work_rounded,
                                title: _savedPlaces['work']!['title']!,
                                subtitle: _savedPlaces['work']!['subtitle']!,
                                onTap: () => setState(() => _destinationAddress = _savedPlaces['work']!['title']!),
                              ),
                              const SizedBox(width: 8),
                              _buildShortcutChip(
                                icon: Icons.star_rounded,
                                title: 'DLF Mall',
                                subtitle: 'Sector 18',
                                onTap: () => setState(() => _destinationAddress = _savedPlaces['fav1']!['title']!),
                              ),
                              const SizedBox(width: 8),
                              _buildShortcutChip(
                                icon: Icons.add_location_alt_rounded,
                                title: '+ Add Saved',
                                subtitle: 'New Place',
                                onTap: _openDestinationSearchModal,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Nearby Vehicles Visibility Toggle & Current Location GPS Pill
                Positioned(
                  bottom: 395,
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Nearby Vehicles Toggle
                      GestureDetector(
                        onTap: () => setState(() => _showNearbyVehicles = !_showNearbyVehicles),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF00C853)),
                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _showNearbyVehicles ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                                size: 14,
                                color: const Color(0xFF00C853),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                activeRideCategory['isMetro'] == true
                                    ? 'Metro Coming Soon'
                                    : '${activeRideCategory['nearbyCount']} Nearby Rides',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF00C853)),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Current Location GPS Pin Button
                      _isLoadingLocation
                          ? Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00C853)),
                              ),
                            )
                          : GoRushLocationPill(
                              onTap: _requestCurrentLocation,
                            ),
                    ],
                  ),
                ),

                // 4. Draggable Bottom Sheet for Ride Selection
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 380),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 20,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: Container(
                            width: 38,
                            height: 4,
                            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                          ),
                        ),
                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Choose a Ride',
                              style: GoRushTypography.headline.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: const [
                                  Icon(Icons.verified_rounded, color: Color(0xFF00C853), size: 14),
                                  SizedBox(width: 4),
                                  Text(
                                    'Top Rated',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF00C853)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        Expanded(
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            itemCount: _rideCategories.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final category = _rideCategories[index];
                              final isSelected = _selectedCategoryIndex == index;
                              final isMetro = category['isMetro'] == true;
                              return isMetro
                                  ? GoRushMetroCard(
                                      isSelected: isSelected,
                                      onTap: () => setState(() => _selectedCategoryIndex = index),
                                    )
                                  : GoRushRideCategoryCard(
                                      title: category['title'],
                                      capacity: category['capacity'],
                                      eta: category['eta'],
                                      fare: category['fare'],
                                      icon: category['icon'],
                                      isSelected: isSelected,
                                      onTap: () => setState(() => _selectedCategoryIndex = index),
                                    );
                            },
                          ),
                        ),

                        const SizedBox(height: 10),

                        InkWell(
                          onTap: _showPaymentSelector,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: GoRushColors.border),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF00C853), size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  _paymentMethod,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                const Spacer(),
                                const Text('Change', style: TextStyle(color: Color(0xFF00C853), fontWeight: FontWeight.bold, fontSize: 12)),
                                const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFF00C853)),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _confirmRideBooking,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00C853),
                              foregroundColor: Colors.white,
                              elevation: 4,
                              shadowColor: const Color(0xFF00C853).withValues(alpha: 0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: Builder(builder: (_) {
                              final sel = _rideCategories[_selectedCategoryIndex];
                              final isMetro = sel['isMetro'] == true;
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    isMetro ? Icons.subway_rounded : null,
                                    color: Colors.white,
                                    size: isMetro ? 18 : 0,
                                  ),
                                  if (isMetro) const SizedBox(width: 6),
                                  Text(
                                    isMetro
                                        ? 'Metro — Coming Soon'
                                        : 'Confirm ${sel['title'].toString().split(' ')[0]}',
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  if (!isMetro) ...[
                                    const SizedBox(width: 8),
                                    Text(
                                      '• ${sel['fare']}',
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ],
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShortcutChip({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: GoRushColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: const Color(0xFF00C853)),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87)),
                Text(subtitle, style: const TextStyle(fontSize: 9, color: Colors.black54)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNearbyVehiclePin(String vehicleType, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF00C853),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.electric_car_rounded, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
