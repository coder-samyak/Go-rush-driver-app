import 'package:flutter/foundation.dart';
import 'token_storage_service.dart';

class AppLanguageService extends ChangeNotifier {
  static final AppLanguageService instance = AppLanguageService._internal();
  AppLanguageService._internal();

  String _currentLanguageCode = 'en';
  String _displayName = 'English (India)';

  String get currentLanguageCode => _currentLanguageCode;
  String get displayName => _displayName;

  Future<void> init() async {
    final savedCode = await TokenStorageService.instance.getLanguage();
    if (savedCode != null && savedCode.isNotEmpty) {
      setLanguage(savedCode, persist: false);
    }
  }

  void setLanguage(String codeOrName, {bool persist = true}) {
    if (codeOrName.contains('Hindi') || codeOrName.contains('हिन्दी') || codeOrName == 'hi') {
      _currentLanguageCode = 'hi';
      _displayName = 'हिन्दी (Hindi)';
    } else if (codeOrName.contains('Punjabi') || codeOrName.contains('ਪੰਜਾਬੀ') || codeOrName == 'pa') {
      _currentLanguageCode = 'pa';
      _displayName = 'ਪੰਜਾਬੀ (Punjabi)';
    } else if (codeOrName.contains('Marathi') || codeOrName.contains('मराठी') || codeOrName == 'mr') {
      _currentLanguageCode = 'mr';
      _displayName = 'मराठी (Marathi)';
    } else if (codeOrName.contains('Bengali') || codeOrName.contains('বাংলা') || codeOrName == 'bn') {
      _currentLanguageCode = 'bn';
      _displayName = 'বাংলা (Bengali)';
    } else if (codeOrName.contains('Tamil') || codeOrName.contains('தமிழ்') || codeOrName == 'ta') {
      _currentLanguageCode = 'ta';
      _displayName = 'தமிழ் (Tamil)';
    } else if (codeOrName.contains('Telugu') || codeOrName.contains('తెలుగు') || codeOrName == 'te') {
      _currentLanguageCode = 'te';
      _displayName = 'తెలుగు (Telugu)';
    } else if (codeOrName.contains('Gujarati') || codeOrName.contains('ગુજરાતી') || codeOrName == 'gu') {
      _currentLanguageCode = 'gu';
      _displayName = 'ગુજરાતી (Gujarati)';
    } else {
      _currentLanguageCode = 'en';
      _displayName = 'English (India)';
    }

    if (persist) {
      TokenStorageService.instance.saveLanguage(_currentLanguageCode);
    }

    notifyListeners();
  }

  static String t(String key) => instance.translate(key);

  String translate(String text) {
    if (_currentLanguageCode == 'en') return text;
    final map = _translations[_currentLanguageCode];
    if (map != null && map.containsKey(text)) {
      return map[text]!;
    }
    return text;
  }

  static final Map<String, Map<String, String>> _translations = {
    // -------------------------------------------------------------
    // HINDI (हिंदी)
    // -------------------------------------------------------------
    'hi': {
      // Bottom Navigation
      'Home': 'होम',
      'Earnings': 'कमाई',
      'History': 'इतिहास',
      'Profile': 'प्रोफ़ाइल',

      // Profile & Settings
      'Profile & Settings': 'प्रोफ़ाइल और सेटिंग्स',
      'Verified Driver': 'सत्यापित चालक',
      'Edit Profile': 'प्रोफ़ाइल संपादित करें',
      'Update phone number & address': 'फ़ोन नंबर और पता अपडेट करें',
      'Vehicle Details': 'वाहन विवरण',
      'Documents & Verification': 'दस्तावेज़ और सत्यापन',
      'Driving License, RC, Insurance': 'ड्राइविंग लाइसेंस, RC, बीमा',
      'Verified': 'सत्यापित',
      'Bank Details & UPI': 'बैंक विवरण और UPI',
      'HDFC Bank • Instant Payouts': 'HDFC बैंक • त्वरित भुगतान',
      'Push Notifications': 'पुश सूचनाएं',
      'Ride alerts, surges & payments': 'राइड अलर्ट, सर्ज और भुगतान',
      'App Language': 'ऐप की भाषा',
      'Privacy & Security': 'गोपनीयता और सुरक्षा',
      'Location permissions & biometric lock': 'स्थान अनुमतियां और बायोमेट्रिक लॉक',
      'Change Password / PIN': 'पासवर्ड / पिन बदलें',
      'Update authentication credentials': 'प्रमाणीकरण क्रेडेंशियल अपडेट करें',
      'Log Out': 'लॉग आउट',
      'Session logged out.': 'सत्र लॉग आउट हो गया।',

      // Push Notifications Sheet
      'Customize your trip alerts and sound preferences': 'अपने ट्रिप अलर्ट और ध्वनि प्राथमिकताएं अनुकूलित करें',
      'Ride Request Alerts': 'राइड अनुरोध अलर्ट',
      'Loud chime and popup for new incoming trip requests': 'नए इनकमिंग ट्रिप अनुरोधों के लिए तेज आवाज और पॉपअप',
      'Surge & Hotspot Alerts': 'सर्ज और हॉटस्पॉट अलर्ट',
      'Notifications when nearby zones enter 1.5x - 2.5x surge': 'नजदीकी क्षेत्रों में 1.5x - 2.5x सर्ज होने पर सूचनाएं',
      'Earnings & Payout Alerts': 'कमाई और भुगतान अलर्ट',
      'Instant alerts when customer pays or daily payout deposits': 'ग्राहक द्वारा भुगतान या दैनिक पेआउट जमा होने पर तुरंत अलर्ट',
      'Safety & Policy Updates': 'सुरक्षा और नीति अपडेट',
      'Critical safety bulletins, SOS checks & regulatory notices': 'महत्वपूर्ण सुरक्षा बुलेटिन, SOS जांच और नियामक नोटिस',
      'Override Silent Mode': 'साइलेंट मोड ओवरराइड करें',
      'Play incoming ride audio at maximum volume even when muted': 'म्यूट होने पर भी अधिकतम वॉल्यूम पर इनकमिंग राइड की आवाज चलाएं',
      'Save Preferences': 'प्राथमिकताएं सहेजें',
      'Notification preferences saved successfully.': 'सूचना प्राथमिकताएं सफलतापूर्वक सहेजी गईं।',

      // App Language Sheet
      'Select App Language': 'ऐप की भाषा चुनें',
      'Choose your preferred language for voice and app UI': 'आवाज और ऐप इंटरफ़ेस के लिए अपनी पसंदीदा भाषा चुनें',
      'App language changed to': 'ऐप की भाषा बदलकर कर दी गई:',

      // Privacy & Security Sheet
      'Manage permissions and device security preferences': 'अनुमतियां और डिवाइस सुरक्षा प्राथमिकताएं प्रबंधित करें',
      'Biometric App Lock': 'बायोमेट्रिक ऐप लॉक',
      'Require fingerprint or face scan when opening driver app': 'ड्राइवर ऐप खोलते समय फिंगरप्रिंट या फेस स्कैन आवश्यक करें',
      'Background Location': 'पृष्ठभूमि स्थान (Background Location)',
      'Always active while online for live customer GPS tracking': 'ऑनलाइन होने पर लाइव ग्राहक जीपीएस ट्रैकिंग के लिए हमेशा सक्रिय',
      '2-Factor Payout Verification': '2-कारक भुगतान सत्यापन',
      'Send SMS OTP before transferring money to bank account': 'बैंक खाते में पैसे ट्रांसफर करने से पहले SMS OTP भेजें',
      'Customer Phone Masking': 'ग्राहक फोन मास्किंग',
      'Anonymize real phone number when calling passengers': 'यात्रियों को कॉल करते समय असली फ़ोन नंबर छिपाएं',
      'System Permissions: All Granted': 'सिस्टम अनुमतियां: सभी स्वीकृत',
      'Location, Camera, Microphone and Storage access verified': 'स्थान, कैमरा, माइक्रोफोन और स्टोरेज पहुंच सत्यापित',
      'Save Security Settings': 'सुरक्षा सेटिंग्स सहेजें',
      'Privacy and security settings updated.': 'गोपनीयता और सुरक्षा सेटिंग्स अपडेट की गईं।',

      // Change Password / PIN Sheet
      'Update your 4-digit driver authentication PIN': 'अपना 4-अंकीय ड्राइवर प्रमाणीकरण पिन अपडेट करें',
      'Current 4-Digit PIN': 'वर्तमान 4-अंकीय पिन',
      'New 4-Digit PIN': 'नया 4-अंकीय पिन',
      'Confirm New 4-Digit PIN': 'नए 4-अंकीय पिन की पुष्टि करें',
      'Update PIN': 'पिन अपडेट करें',
      'Security PIN changed successfully!': 'सुरक्षा पिन सफलतापूर्वक बदल दिया गया!',
      'Please enter your current PIN.': 'कृपया अपना वर्तमान पिन दर्ज करें।',
      'New PIN must be at least 4 digits.': 'नया पिन कम से कम 4 अंकों का होना चाहिए।',
      'New PIN and confirmation PIN do not match.': 'नया पिन और पुष्टि पिन मेल नहीं खाते।',

      // Driver Profile Setup / Edit Profile
      'Driver Profile': 'ड्राइवर प्रोफ़ाइल',
      'Change Photo': 'फ़ोटो बदलें',
      'Full Name': 'पूरा नाम',
      'Phone Number': 'फ़ोन नंबर',
      'Email Address': 'ईमेल पता',
      'Date of Birth': 'जन्म तिथि',
      'City / Operational Hub': 'शहर / परिचालन हब',
      'Permanent Address': 'स्थायी पता',
      'Save Changes': 'बदलाव सहेजें',
      'Next: Upload Documents': 'अगला: दस्तावेज़ अपलोड करें',
      'Profile details updated successfully!': 'प्रोफ़ाइल विवरण सफलतापूर्वक अपडेट किया गया!',

      // Home Dashboard
      'Good Morning,': 'शुभ प्रभात,',
      'Online': 'ऑनलाइन',
      'Offline': 'ऑफलाइन',
      'Current Location: Sector 62, Noida': 'वर्तमान स्थान: सेक्टर 62, नोएडा',
      'High Demand Zone (1.4x)': 'उच्च मांग क्षेत्र (1.4x)',
      'Available Requests': 'उपलब्ध अनुरोध',
      'in 2 km radius': '2 किमी के दायरे में',
      "Today's Earnings": 'आज की कमाई',
      '+₹360 incentive': '+₹360 प्रोत्साहन',
      'Completed Rides': 'पूर्ण हुई राइड्स',
      '98% acceptance': '98% स्वीकृति',
      'Online Hours': 'ऑनलाइन घंटे',
      'Target: 8h': 'लक्ष्य: 8 घंटे',
      'Ride Request Available!': 'राइड अनुरोध उपलब्ध!',
      'Priya Sharma • ₹362': 'प्रिया शर्मा • ₹362',
      'Pickup: Sector 18 Metro (1.2 km)': 'पिकअप: सेक्टर 18 मेट्रो (1.2 किमी)',
      'View Incoming Request (Screen 10) →': 'आने वाला अनुरोध देखें (स्क्रीन 10) →',
      'Emergency SOS': 'आपातकालीन SOS',
      'Police & Ambulance': 'पुलिस और एम्बुलेंस',
      'Support Hub': 'सहायता केंद्र',
      '24x7 Helpdesk': '24x7 हेल्पडेस्क',

      // Earnings & History
      "Today's Net Earnings": 'आज की कुल कमाई',
      'Linked Bank: HDFC Bank': 'लिंक किया गया बैंक: HDFC बैंक',
      'Instant Cash Out': 'तुरंत पैसे निकालें',
      'View Earnings Statement': 'कमाई का विवरण देखें',
      'Trip History': 'यात्रा इतिहास',
    },

    // -------------------------------------------------------------
    // PUNJABI (ਪੰਜਾਬੀ)
    // -------------------------------------------------------------
    'pa': {
      // Bottom Navigation
      'Home': 'ਘਰ',
      'Earnings': 'ਕਮਾਈ',
      'History': 'ਇਤਿਹਾਸ',
      'Profile': 'ਪ੍ਰੋਫਾਈਲ',

      // Profile & Settings
      'Profile & Settings': 'ਪ੍ਰੋਫਾਈਲ ਅਤੇ ਸੈਟਿੰਗਾਂ',
      'Verified Driver': 'ਪ੍ਰਮਾਣਿਤ ਡਰਾਈਵਰ',
      'Edit Profile': 'ਪ੍ਰੋਫਾਈਲ ਸੰਪਾਦਿਤ ਕਰੋ',
      'Update phone number & address': 'ਫ਼ੋਨ ਨੰਬਰ ਅਤੇ ਪਤਾ ਅੱਪਡੇਟ ਕਰੋ',
      'Vehicle Details': 'ਵਾਹਨ ਦੇ ਵੇਰਵੇ',
      'Documents & Verification': 'ਦਸਤਾਵੇਜ਼ ਅਤੇ ਤਸਦੀਕ',
      'Driving License, RC, Insurance': 'ਡ੍ਰਾਈਵਿੰਗ ਲਾਇਸੰਸ, RC, ਬੀਮਾ',
      'Verified': 'ਪ੍ਰਮਾਣਿਤ',
      'Bank Details & UPI': 'ਬੈਂਕ ਵੇਰਵੇ ਅਤੇ UPI',
      'HDFC Bank • Instant Payouts': 'HDFC ਬੈਂਕ • ਤੁਰੰਤ ਭੁਗਤਾਨ',
      'Push Notifications': 'ਪੁਸ਼ ਸੂਚਨਾਵਾਂ',
      'Ride alerts, surges & payments': 'ਰਾਈਡ ਅਲਰਟ, ਸਰਜ ਅਤੇ ਭੁਗਤਾਨ',
      'App Language': 'ਐਪ ਦੀ ਭਾਸ਼ਾ',
      'Privacy & Security': 'ਗੋਪਨੀਯਤਾ ਅਤੇ ਸੁਰੱਖਿਆ',
      'Location permissions & biometric lock': 'ਟਿਕਾਣਾ ਇਜਾਜ਼ਤਾਂ ਅਤੇ ਬਾਇਓਮੈਟ੍ਰਿਕ ਲਾਕ',
      'Change Password / PIN': 'ਪਾਸਵਰਡ / ਪਿੰਨ ਬਦਲੋ',
      'Update authentication credentials': 'ਪ੍ਰਮਾਣਿਕਤਾ ਪ੍ਰਮਾਣ ਪੱਤਰ ਅੱਪਡੇਟ ਕਰੋ',
      'Log Out': 'ਲਾਗ ਆਉਟ',
      'Session logged out.': 'ਸੈਸ਼ਨ ਲਾਗ ਆਉਟ ਹੋ ਗਿਆ।',

      // Push Notifications Sheet
      'Customize your trip alerts and sound preferences': 'ਆਪਣੇ ਟ੍ਰਿਪ ਅਲਰਟ ਅਤੇ ਆਵਾਜ਼ ਤਰਜੀਹਾਂ ਨੂੰ ਅਨੁਕੂਲਿਤ ਕਰੋ',
      'Ride Request Alerts': 'ਰਾਈਡ ਬੇਨਤੀ ਅਲਰਟ',
      'Loud chime and popup for new incoming trip requests': 'ਨਵੀਆਂ ਇਨਕਮਿੰਗ ਟ੍ਰਿਪ ਬੇਨਤੀਆਂ ਲਈ ਉੱਚੀ ਆਵਾਜ਼ ਅਤੇ ਪੌਪਅੱਪ',
      'Surge & Hotspot Alerts': 'ਸਰਜ ਅਤੇ ਹੌਟਸਪੌਟ ਅਲਰਟ',
      'Notifications when nearby zones enter 1.5x - 2.5x surge': 'ਜਦੋਂ ਨੇੜਲੇ ਜ਼ੋਨ 1.5x - 2.5x ਸਰਜ ਵਿੱਚ ਆਉਂਦੇ ਹਨ ਤਾਂ ਸੂਚਨਾਵਾਂ',
      'Earnings & Payout Alerts': 'ਕਮਾਈ ਅਤੇ ਭੁਗਤਾਨ ਅਲਰਟ',
      'Instant alerts when customer pays or daily payout deposits': 'ਗਾਹਕ ਦੇ ਭੁਗਤਾਨ ਕਰਨ ਜਾਂ ਰੋਜ਼ਾਨਾ ਪੇਆਉਟ ਜਮ੍ਹਾ ਹੋਣ ਤੇ ਤੁਰੰਤ ਅਲਰਟ',
      'Safety & Policy Updates': 'ਸੁਰੱਖਿਆ ਅਤੇ ਨੀਤੀ ਅੱਪਡੇਟ',
      'Critical safety bulletins, SOS checks & regulatory notices': 'ਮਹੱਤਵਪੂਰਨ ਸੁਰੱਖਿਆ ਬੁਲੇਟਿਨ, SOS ਜਾਂਚ ਅਤੇ ਰੈਗੂਲੇਟਰੀ ਨੋਟਿਸ',
      'Override Silent Mode': 'ਸਾਈਲੈਂਟ ਮੋਡ ਓਵਰਰਾਈਡ ਕਰੋ',
      'Play incoming ride audio at maximum volume even when muted': 'ਮਿਊਟ ਹੋਣ ਤੇ ਵੀ ਵੱਧ ਤੋਂ ਵੱਧ ਆਵਾਜ਼ ਤੇ ਇਨਕਮਿੰਗ ਰਾਈਡ ਆਡੀਓ ਚਲਾਓ',
      'Save Preferences': 'ਤਰਜੀਹਾਂ ਸੰਭਾਲੋ',
      'Notification preferences saved successfully.': 'ਸੂਚਨਾ ਤਰਜੀਹਾਂ ਸਫਲਤਾਪੂਰਵਕ ਸੰਭਾਲੀਆਂ ਗਈਆਂ।',

      // App Language Sheet
      'Select App Language': 'ਐਪ ਦੀ ਭਾਸ਼ਾ ਚੁਣੋ',
      'Choose your preferred language for voice and app UI': 'ਆਵਾਜ਼ ਅਤੇ ਐਪ ਇੰਟਰਫੇਸ ਲਈ ਆਪਣੀ ਪਸੰਦੀਦਾ ਭਾਸ਼ਾ ਚੁਣੋ',
      'App language changed to': 'ਐਪ ਦੀ ਭਾਸ਼ਾ ਬਦਲ ਦਿੱਤੀ ਗਈ:',

      // Privacy & Security Sheet
      'Manage permissions and device security preferences': 'ਇਜਾਜ਼ਤਾਂ ਅਤੇ ਡਿਵਾਈਸ ਸੁਰੱਖਿਆ ਤਰਜੀਹਾਂ ਦਾ ਪ੍ਰਬੰਧਨ ਕਰੋ',
      'Biometric App Lock': 'ਬਾਇਓਮੈਟ੍ਰਿਕ ਐਪ ਲਾਕ',
      'Require fingerprint or face scan when opening driver app': 'ਡਰਾਈਵਰ ਐਪ ਖੋਲ੍ਹਣ ਵੇਲੇ ਫਿੰਗਰਪ੍ਰਿੰਟ ਜਾਂ ਫੇਸ ਸਕੈਨ ਦੀ ਲੋੜ ਹੈ',
      'Background Location': 'ਬੈਕਗ੍ਰਾਊਂਡ ਟਿਕਾਣਾ',
      'Always active while online for live customer GPS tracking': 'ਔਨਲਾਈਨ ਹੋਣ ਤੇ ਲਾਈਵ ਗਾਹਕ GPS ਟਰੈਕਿੰਗ ਲਈ ਹਮੇਸ਼ਾ ਕਿਰਿਆਸ਼ੀਲ',
      '2-Factor Payout Verification': '2-ਫੈਕਟਰ ਪੇਆਉਟ ਤਸਦੀਕ',
      'Send SMS OTP before transferring money to bank account': 'ਬੈਂਕ ਖਾਤੇ ਵਿੱਚ ਪੈਸੇ ਟ੍ਰਾਂਸਫਰ ਕਰਨ ਤੋਂ ਪਹਿਲਾਂ SMS OTP ਭੇਜੋ',
      'Customer Phone Masking': 'ਗਾਹਕ ਫ਼ੋਨ ਮਾਸਕਿੰਗ',
      'Anonymize real phone number when calling passengers': 'ਯਾਤਰੀਆਂ ਨੂੰ ਕਾਲ ਕਰਨ ਵੇਲੇ ਅਸਲੀ ਫ਼ੋਨ ਨੰਬਰ ਲੁਕਾਓ',
      'System Permissions: All Granted': 'ਸਿਸਟਮ ਇਜਾਜ਼ਤਾਂ: ਸਭ ਮਨਜ਼ੂਰ',
      'Location, Camera, Microphone and Storage access verified': 'ਟਿਕਾਣਾ, ਕੈਮਰਾ, ਮਾਈਕ੍ਰੋਫ਼ੋਨ ਅਤੇ ਸਟੋਰੇਜ ਪਹੁੰਚ ਪ੍ਰਮਾਣਿਤ',
      'Save Security Settings': 'ਸੁਰੱਖਿਆ ਸੈਟਿੰਗਾਂ ਸੰਭਾਲੋ',
      'Privacy and security settings updated.': 'ਗੋਪਨੀਯਤਾ ਅਤੇ ਸੁਰੱਖਿਆ ਸੈਟਿੰਗਾਂ ਅੱਪਡੇਟ ਕੀਤੀਆਂ ਗਈਆਂ।',

      // Change Password / PIN Sheet
      'Update your 4-digit driver authentication PIN': 'ਆਪਣਾ 4-ਅੰਕਾਂ ਦਾ ਡਰਾਈਵਰ ਪ੍ਰਮਾਣੀਕਰਨ ਪਿੰਨ ਅੱਪਡੇਟ ਕਰੋ',
      'Current 4-Digit PIN': 'ਮੌਜੂਦਾ 4-ਅੰਕਾਂ ਵਾਲਾ ਪਿੰਨ',
      'New 4-Digit PIN': 'ਨਵਾਂ 4-ਅੰਕਾਂ ਵਾਲਾ ਪਿੰਨ',
      'Confirm New 4-Digit PIN': 'ਨਵੇਂ 4-ਅੰਕਾਂ ਵਾਲੇ ਪਿੰਨ ਦੀ ਪੁਸ਼ਟੀ ਕਰੋ',
      'Update PIN': 'ਪਿੰਨ ਅੱਪਡੇਟ ਕਰੋ',
      'Security PIN changed successfully!': 'ਸੁਰੱਖਿਆ ਪਿੰਨ ਸਫਲਤਾਪੂਰਵਕ ਬਦਲਿਆ ਗਿਆ!',
      'Please enter your current PIN.': 'ਕਿਰਪਾ ਕਰਕੇ ਆਪਣਾ ਮੌਜੂਦਾ ਪਿੰਨ ਦਰਜ ਕਰੋ।',
      'New PIN must be at least 4 digits.': 'ਨਵਾਂ ਪਿੰਨ ਘੱਟੋ-ਘੱਟ 4 ਅੰਕਾਂ ਦਾ ਹੋਣਾ ਚਾਹੀਦਾ ਹੈ।',
      'New PIN and confirmation PIN do not match.': 'ਨਵਾਂ ਪਿੰਨ ਅਤੇ ਪੁਸ਼ਟੀਕਰਨ ਪਿੰਨ ਮੇਲ ਨਹੀਂ ਖਾਂਦੇ।',

      // Driver Profile Setup / Edit Profile
      'Driver Profile': 'ਡਰਾਈਵਰ ਪ੍ਰੋਫਾਈਲ',
      'Change Photo': 'ਫ਼ੋਟੋ ਬਦਲੋ',
      'Full Name': 'ਪੂਰਾ ਨਾਮ',
      'Phone Number': 'ਫ਼ੋਨ ਨੰਬਰ',
      'Email Address': 'ਈਮੇਲ ਪਤਾ',
      'Date of Birth': 'ਜਨਮ ਤਾਰੀਖ',
      'City / Operational Hub': 'ਸ਼ਹਿਰ / ਸੰਚਾਲਨ ਹੱਬ',
      'Permanent Address': 'ਪੱਕਾ ਪਤਾ',
      'Save Changes': 'ਬਦਲਾਅ ਸੰਭਾਲੋ',
      'Next: Upload Documents': 'ਅਗਲਾ: ਦਸਤਾਵੇਜ਼ ਅੱਪਲੋਡ ਕਰੋ',
      'Profile details updated successfully!': 'ਪ੍ਰੋਫਾਈਲ ਵੇਰਵੇ ਸਫਲਤਾਪੂਰਵਕ ਅੱਪਡੇਟ ਕੀਤੇ ਗਏ!',

      // Home Dashboard
      'Good Morning,': 'ਸ਼ੁਭ ਸਵੇਰ,',
      'Online': 'ਔਨਲਾਈਨ',
      'Offline': 'ਔਫਲਾਈਨ',
      'Current Location: Sector 62, Noida': 'ਮੌਜੂਦਾ ਟਿਕਾਣਾ: ਸੈਕਟਰ 62, ਨੋਇਡਾ',
      'High Demand Zone (1.4x)': 'ਉੱਚ ਮੰਗ ਜ਼ੋਨ (1.4x)',
      'Available Requests': 'ਉਪਲਬਧ ਬੇਨਤੀਆਂ',
      'in 2 km radius': '2 ਕਿਲੋਮੀਟਰ ਦੇ ਘੇਰੇ ਵਿੱਚ',
      "Today's Earnings": 'ਅੱਜ ਦੀ ਕਮਾਈ',
      '+₹360 incentive': '+₹360 ਪ੍ਰੋਤਸਾਹਨ',
      'Completed Rides': 'ਮੁਕੰਮਲ ਰਾਈਡਾਂ',
      '98% acceptance': '98% ਸਵੀਕ੍ਰਿਤੀ',
      'Online Hours': 'ਔਨਲਾਈਨ ਘੰਟੇ',
      'Target: 8h': 'ਟੀਚਾ: 8 ਘੰਟੇ',
      'Ride Request Available!': 'ਰਾਈਡ ਬੇਨਤੀ ਉਪਲਬਧ ਹੈ!',
      'Priya Sharma • ₹362': 'ਪ੍ਰਿਆ ਸ਼ਰਮਾ • ₹362',
      'Pickup: Sector 18 Metro (1.2 km)': 'ਪਿਕਅੱਪ: ਸੈਕਟਰ 18 ਮੈਟਰੋ (1.2 ਕਿਲੋਮੀਟਰ)',
      'View Incoming Request (Screen 10) →': 'ਇਨਕਮਿੰਗ ਬੇਨਤੀ ਦੇਖੋ (ਸਕ੍ਰੀਨ 10) →',
      'Emergency SOS': 'ਐਮਰਜੈਂਸੀ SOS',
      'Police & Ambulance': 'ਪੁਲਿਸ ਅਤੇ ਐਂਬੂਲੈਂਸ',
      'Support Hub': 'ਸਹਾਇਤਾ ਕੇਂਦਰ',
      '24x7 Helpdesk': '24x7 ਹੈਲਪਡੈਸਕ',

      // Earnings & History
      "Today's Net Earnings": 'ਅੱਜ ਦੀ ਕੁੱਲ ਕਮਾਈ',
      'Linked Bank: HDFC Bank': 'ਲਿੰਕ ਕੀਤਾ ਬੈਂਕ: HDFC ਬੈਂਕ',
      'Instant Cash Out': 'ਤੁਰੰਤ ਕੈਸ਼ ਆਊਟ',
      'View Earnings Statement': 'ਕਮਾਈ ਦਾ ਬਿਆਨ ਦੇਖੋ',
      'Trip History': 'ਟ੍ਰਿਪ ਇਤਿਹਾਸ',
    },

    // -------------------------------------------------------------
    // MARATHI (मराठी)
    // -------------------------------------------------------------
    'mr': {
      // Bottom Navigation
      'Home': 'मुख्यपृष्ठ',
      'Earnings': 'कमाई',
      'History': 'इतिहास',
      'Profile': 'प्रोफाइल',

      // Profile & Settings
      'Profile & Settings': 'प्रोफाइल आणि सेटिंग्ज',
      'Verified Driver': 'सत्यापित ड्रायव्हर',
      'Edit Profile': 'प्रोफाइल संपादित करा',
      'Update phone number & address': 'फोन नंबर आणि पत्ता अपडेट करा',
      'Vehicle Details': 'वाहन तपशील',
      'Documents & Verification': 'कागदपत्रे आणि पडताळणी',
      'Driving License, RC, Insurance': 'ड्रायव्हिंग लायसन्स, RC, विमा',
      'Verified': 'सत्यापित',
      'Bank Details & UPI': 'बँक तपशील आणि UPI',
      'HDFC Bank • Instant Payouts': 'HDFC बँक • त्वरित पेआउट',
      'Push Notifications': 'पुश सूचना',
      'Ride alerts, surges & payments': 'राइड अलर्ट, सर्ज आणि पेमेंट',
      'App Language': 'अॅपची भाषा',
      'Privacy & Security': 'गोपनीयता आणि सुरक्षा',
      'Location permissions & biometric lock': 'स्थान परवानगी आणि बायोमेट्रिक लॉक',
      'Change Password / PIN': 'पासवर्ड / पिन बदला',
      'Update authentication credentials': 'प्रमाणीकरण क्रेडेंटियल्स अपडेट करा',
      'Log Out': 'लॉग आउट',
      'Session logged out.': 'सत्र लॉग आउट झाले.',

      // Push Notifications Sheet
      'Customize your trip alerts and sound preferences': 'तुमचे ट्रिप अलर्ट आणि आवाज प्राधान्ये सानुकूलित करा',
      'Ride Request Alerts': 'राइड विनंती सूचना',
      'Loud chime and popup for new incoming trip requests': 'नवीन इनकमिंग ट्रिप विनंत्यांसाठी मोठा आवाज आणि पॉपअप',
      'Surge & Hotspot Alerts': 'सर्ज आणि हॉटस्पॉट अलर्ट',
      'Notifications when nearby zones enter 1.5x - 2.5x surge': 'जवळपासचे झोन 1.5x - 2.5x सर्जमध्ये आल्यावर सूचना',
      'Earnings & Payout Alerts': 'कमाई आणि पेआउट सूचना',
      'Instant alerts when customer pays or daily payout deposits': 'ग्राहकाने पैसे भरल्यावर किंवा दैनिक पेआउट जमा झाल्यावर त्वरित सूचना',
      'Safety & Policy Updates': 'सुरक्षा आणि धोरण अद्यतने',
      'Critical safety bulletins, SOS checks & regulatory notices': 'महत्त्वाचे सुरक्षा बुलेटिन, SOS तपासण्या आणि नियामक सूचना',
      'Override Silent Mode': 'सायलेंट मोड ओव्हरराइड करा',
      'Play incoming ride audio at maximum volume even when muted': 'म्यूट असतानाही कमाल आवाजात इनकमिंग राइड ऑडिओ प्ले करा',
      'Save Preferences': 'प्राधान्ये जतन करा',
      'Notification preferences saved successfully.': 'सूचना प्राधान्ये यशस्वीरित्या जतन केली.',

      // App Language Sheet
      'Select App Language': 'अॅपची भाषा निवडा',
      'Choose your preferred language for voice and app UI': 'आवाज आणि अॅप इंटरफेससाठी तुमची पसंतीची भाषा निवडा',
      'App language changed to': 'अॅपची भाषा बदलली:',

      // Privacy & Security Sheet
      'Manage permissions and device security preferences': 'परवानग्या आणि डिव्हाइस सुरक्षा प्राधान्ये व्यवस्थापित करा',
      'Biometric App Lock': 'बायोमेट्रिक अॅप लॉक',
      'Require fingerprint or face scan when opening driver app': 'ड्रायव्हर अॅप उघडताना फिंगरप्रिंट किंवा फेस स्कॅन आवश्यक करा',
      'Background Location': 'पार्श्वभूमी स्थान (Background Location)',
      'Always active while online for live customer GPS tracking': 'ऑनलाइन असताना थेट ग्राहक GPS ट्रॅकिंगसाठी नेहमी सक्रिय',
      '2-Factor Payout Verification': '2-घटक पेआउट पडताळणी',
      'Send SMS OTP before transferring money to bank account': 'बँक खात्यात पैसे ट्रान्सफर करण्यापूर्वी SMS OTP पाठवा',
      'Customer Phone Masking': 'ग्राहक फोन मास्किंग',
      'Anonymize real phone number when calling passengers': 'प्रवाशांना कॉल करताना खरा फोन नंबर लपवा',
      'System Permissions: All Granted': 'सिस्टम परवानग्या: सर्व मंजूर',
      'Location, Camera, Microphone and Storage access verified': 'स्थान, कॅमेरा, मायक्रोफोन आणि स्टोरेज प्रवेश सत्यापित',
      'Save Security Settings': 'सुरक्षा सेटिंग्ज जतन करा',
      'Privacy and security settings updated.': 'गोपनीयता आणि सुरक्षा सेटिंग्ज अद्यतनित केल्या.',

      // Change Password / PIN Sheet
      'Update your 4-digit driver authentication PIN': 'तुमचा 4-अंकी ड्रायव्हर ऑथेंटिकेशन पिन अपडेट करा',
      'Current 4-Digit PIN': 'वर्तमान 4-अंकी पिन',
      'New 4-Digit PIN': 'नवीन 4-अंकी पिन',
      'Confirm New 4-Digit PIN': 'नवीन 4-अंकी पिनची पुष्टी करा',
      'Update PIN': 'पिन अपडेट करा',
      'Security PIN changed successfully!': 'सुरक्षा पिन यशस्वीरित्या बदलला!',
      'Please enter your current PIN.': 'कृपया तुमचा वर्तमान पिन प्रविष्ट करा.',
      'New PIN must be at least 4 digits.': 'नवीन पिन किमान 4 अंकांचा असावा.',
      'New PIN and confirmation PIN do not match.': 'नवीन पिन आणि पुष्टीकरण पिन जुळत नाहीत.',

      // Driver Profile Setup / Edit Profile
      'Driver Profile': 'ड्रायव्हर प्रोफाइल',
      'Change Photo': 'फोटो बदला',
      'Full Name': 'पूर्ण नाव',
      'Phone Number': 'फोन नंबर',
      'Email Address': 'ईमेल पत्ता',
      'Date of Birth': 'जन्मतारीख',
      'City / Operational Hub': 'शहर / ऑपरेशनल हब',
      'Permanent Address': 'कायमचा पत्ता',
      'Save Changes': 'बदल जतन करा',
      'Next: Upload Documents': 'पुढील: कागदपत्रे अपलोड करा',
      'Profile details updated successfully!': 'प्रोफाइल तपशील यशस्वीरित्या अद्यतनित केले!',

      // Home Dashboard
      'Good Morning,': 'शुभ सकाळ,',
      'Online': 'ऑनलाइन',
      'Offline': 'ऑफलाइन',
      'Current Location: Sector 62, Noida': 'वर्तमान स्थान: सेक्टर 62, नोएडा',
      'High Demand Zone (1.4x)': 'उच्च मागणी झोन (1.4x)',
      'Available Requests': 'उपलब्ध विनंत्या',
      'in 2 km radius': '2 किमी च्या परिघात',
      "Today's Earnings": 'आजची कमाई',
      '+₹360 incentive': '+₹360 प्रोत्साहन',
      'Completed Rides': 'पूर्ण झालेल्या राइड्स',
      '98% acceptance': '98% स्वीकृती',
      'Online Hours': 'ऑनलाइन तास',
      'Target: 8h': 'लक्ष्य: 8 तास',
      'Ride Request Available!': 'राइड विनंती उपलब्ध आहे!',
      'Priya Sharma • ₹362': 'प्रिया शर्मा • ₹362',
      'Pickup: Sector 18 Metro (1.2 km)': 'पिकअप: सेक्टर 18 मेट्रो (1.2 किमी)',
      'View Incoming Request (Screen 10) →': 'इनकमिंग विनंती पहा (स्क्रीन 10) →',
      'Emergency SOS': 'आपत्कालीन SOS',
      'Police & Ambulance': 'पोलीस आणि रुग्णवाहिका',
      'Support Hub': 'सपोर्ट हब',
      '24x7 Helpdesk': '24x7 हेल्पडेस्क',

      // Earnings & History
      "Today's Net Earnings": 'आजची निव्वळ कमाई',
      'Linked Bank: HDFC Bank': 'लिंक केलेली बँक: HDFC बँक',
      'Instant Cash Out': 'त्वरित कॅश आउट',
      'View Earnings Statement': 'कमाईचे विवरण पहा',
      'Trip History': 'सहलीचा इतिहास',
    },

    // -------------------------------------------------------------
    // BENGALI (বাংলা)
    // -------------------------------------------------------------
    'bn': {
      'Home': 'হোম',
      'Earnings': 'উপার্জন',
      'History': 'ইতিহাস',
      'Profile': 'প্রোফাইল',
      'Profile & Settings': 'প্রোফাইল ও সেটিংস',
      'Verified Driver': 'যাচাইকৃত ড্রাইভার',
      'Edit Profile': 'প্রোফাইল সম্পাদনা করুন',
      'Update phone number & address': 'ফোন নম্বর এবং ঠিকানা আপডেট করুন',
      'Vehicle Details': 'গাড়ির বিবরণ',
      'Documents & Verification': 'নথিপত্র ও যাচাইকরণ',
      'Bank Details & UPI': 'ব্যাংক বিবরণ ও UPI',
      'Push Notifications': 'পুশ বিজ্ঞপ্তি',
      'App Language': 'অ্যাপের ভাষা',
      'Privacy & Security': 'গোপনীয়তা ও নিরাপত্তা',
      'Change Password / PIN': 'পাসওয়ার্ড / পিন পরিবর্তন করুন',
      'Log Out': 'লগ আউট',
      'Save Preferences': 'পছন্দগুলি সংরক্ষণ করুন',
      'Save Security Settings': 'নিরাপত্তা সেটিংস সংরক্ষণ করুন',
      'Update PIN': 'পিন আপডেট করুন',
      'Save Changes': 'পরিবর্তন সংরক্ষণ করুন',
      'Good Morning,': 'সুপ্রভাত,',
      'Online': 'অনলাইন',
      'Offline': 'অফলাইন',
      'Emergency SOS': 'জরুরি SOS',
      'Support Hub': 'সহায়তা কেন্দ্র',
    },

    // -------------------------------------------------------------
    // TAMIL (தமிழ்)
    // -------------------------------------------------------------
    'ta': {
      'Home': 'முகப்பு',
      'Earnings': 'வருவாய்',
      'History': 'வரலாறு',
      'Profile': 'சுயவிவரம்',
      'Profile & Settings': 'சுயவிவரம் & அமைப்புகள்',
      'Verified Driver': 'சரிபார்க்கப்பட்ட ஓட்டுநர்',
      'Edit Profile': 'சுயவிவரத்தைத் திருத்தவும்',
      'Update phone number & address': 'தொலைபேசி எண் & முகவரியைப் புதுப்பிக்கவும்',
      'Vehicle Details': 'வாகன விவரங்கள்',
      'Documents & Verification': 'ஆவணங்கள் & சரிபார்ப்பு',
      'Bank Details & UPI': 'வங்கி விவரங்கள் & UPI',
      'Push Notifications': 'புஷ் அறிவிப்புகள்',
      'App Language': 'பயன்பாட்டு மொழி',
      'Privacy & Security': 'தனியுரிமை & பாதுகாப்பு',
      'Change Password / PIN': 'கடவுச்சொல் / பின் மாற்றவும்',
      'Log Out': 'வெளியேறு',
      'Save Preferences': 'விருப்பங்களைச் சேமி',
      'Save Security Settings': 'பாதுகாப்பு அமைப்புகளைச் சேமி',
      'Update PIN': 'பின்னைப் புதுப்பிக்கவும்',
      'Save Changes': 'மாற்றங்களைச் சேமி',
      'Good Morning,': 'காலை வணக்கம்,',
      'Online': 'ஆன்லைன்',
      'Offline': 'ஆஃப்லைன்',
      'Emergency SOS': 'அவசர SOS',
      'Support Hub': 'ஆதரவு மையம்',
    },

    // -------------------------------------------------------------
    // TELUGU (తెలుగు)
    // -------------------------------------------------------------
    'te': {
      'Home': 'హోమ్',
      'Earnings': 'ఆదాయం',
      'History': 'చరిత్ర',
      'Profile': 'ప్రొఫైల్',
      'Profile & Settings': 'ప్రొఫైల్ & సెట్టింగ్‌లు',
      'Verified Driver': 'ధృవీకరించబడిన డ్రైవర్',
      'Edit Profile': 'ప్రొఫైల్‌ని సవరించండి',
      'Update phone number & address': 'ఫోన్ నంబర్ & చిరునామాను అప్‌డేట్ చేయండి',
      'Vehicle Details': 'వాహనం వివరాలు',
      'Documents & Verification': 'పత్రాలు & ధృవీకరణ',
      'Bank Details & UPI': 'బ్యాంక్ వివరాలు & UPI',
      'Push Notifications': 'పుష్ నోటిఫికేషన్‌లు',
      'App Language': 'యాప్ భాష',
      'Privacy & Security': 'గోప్యత & భద్రత',
      'Change Password / PIN': 'పాస్‌వర్డ్ / పిన్ మార్చండి',
      'Log Out': 'లాగ్ అవుట్',
      'Save Preferences': 'ప్రాధాన్యతలను సేవ్ చేయండి',
      'Save Security Settings': 'భద్రతా సెట్టింగ్‌లను సేవ్ చేయండి',
      'Update PIN': 'పిన్ అప్‌డేట్ చేయండి',
      'Save Changes': 'మార్పులను సేవ్ చేయండి',
      'Good Morning,': 'శుభోదయం,',
      'Online': 'ఆన్‌లైన్',
      'Offline': 'ఆఫ్‌లైన్',
      'Emergency SOS': 'అత్యవసర SOS',
      'Support Hub': 'సహాయ కేంద్రం',
    },

    // -------------------------------------------------------------
    // GUJARATI (ગુજરાતી)
    // -------------------------------------------------------------
    'gu': {
      'Home': 'હોમ',
      'Earnings': 'કમાણી',
      'History': 'ઇતિહાસ',
      'Profile': 'પ્રોફાઇલ',
      'Profile & Settings': 'પ્રોફાઇલ અને સેટિંગ્સ',
      'Verified Driver': 'ચકાસાયેલ ડ્રાઇવર',
      'Edit Profile': 'પ્રોફાઇલ સંપાદિત કરો',
      'Update phone number & address': 'ફોન નંબર અને સરનામું અપડેટ કરો',
      'Vehicle Details': 'વાહનની વિગતો',
      'Documents & Verification': 'દસ્તાવેજો અને ચકાસણી',
      'Bank Details & UPI': 'બેંક વિગતો અને UPI',
      'Push Notifications': 'પુશ સૂચનાઓ',
      'App Language': 'એપ્લિકેશન ભાષા',
      'Privacy & Security': 'ગોપનીયતા અને સુરક્ષા',
      'Change Password / PIN': 'પાસવર્ડ / પિન બદલો',
      'Log Out': 'લૉગ આઉટ',
      'Save Preferences': 'પસંદગીઓ સાચવો',
      'Save Security Settings': 'સુરક્ષા સેટિંગ્સ સાચવો',
      'Update PIN': 'પિન અપડેટ કરો',
      'Save Changes': 'ફેરફારો સાચવો',
      'Good Morning,': 'સુપ્રભાત,',
      'Online': 'ઓનલાઇન',
      'Offline': 'ઓફલાઇન',
      'Emergency SOS': 'ઇમરજન્સી SOS',
      'Support Hub': 'સહાયતા કેન્દ્ર',
    },
  };
}

String tr(String key) => AppLanguageService.t(key);
