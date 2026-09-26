import { Injectable, BadRequestException } from '@nestjs/common';
import { DatabaseService } from '../../database/database.service.js';

export interface UserProfile {
  userId: string;
  name: string;
  email: string;
  phone: string;
  avatarUrl: string;
  gender: string;
  memberTier: 'BRONZE' | 'SILVER' | 'GOLD' | 'PLATINUM';
  memberSince: string;
  emergencyContacts: Array<{ name: string; phone: string; relationship: string }>;
  rating: number;
  totalTrips: number;
}

export interface NotificationSettings {
  pushEnabled: boolean;
  smsEnabled: boolean;
  promoOffersEnabled: boolean;
  tripStatusAlerts: boolean;
  safetyAlerts: boolean;
  soundVibrationEnabled: boolean;
}

export interface PrivacySettings {
  locationPermission: 'ALWAYS' | 'WHILE_USING' | 'NEVER';
  shareLiveTripWithEmergency: boolean;
  personalizedAdsConsent: boolean;
  analyticsConsent: boolean;
  dataRetentionYears: number;
}

@Injectable()
export class UserService {
  constructor(private readonly db: DatabaseService) {}

  private notificationSettings: NotificationSettings = {
    pushEnabled: true,
    smsEnabled: true,
    promoOffersEnabled: false,
    tripStatusAlerts: true,
    safetyAlerts: true,
    soundVibrationEnabled: true,
  };

  private privacySettings: PrivacySettings = {
    locationPermission: 'WHILE_USING',
    shareLiveTripWithEmergency: true,
    personalizedAdsConsent: false,
    analyticsConsent: true,
    dataRetentionYears: 3,
  };

  private deletionRequests: Array<any> = [];

  async getProfile(userIdOrToken?: string): Promise<UserProfile> {
    let userRecord: any;

    if (userIdOrToken && userIdOrToken.length > 3) {
      // Clean token / userId prefix if Bearer was passed
      const cleanTarget = userIdOrToken.replace('Bearer ', '').replace('mock_access_token_', '').trim();

      const rows = await this.db.query(
        `SELECT u.id as userId, u.phone, u.email, p.name, p.photo as avatarUrl, p.gender, p.preferences 
         FROM users u LEFT JOIN user_profiles p ON u.id = p.user_id 
         WHERE u.id = ? OR u.phone = ? OR u.email = ?`,
        [cleanTarget, cleanTarget, cleanTarget]
      );

      if (rows && rows.length > 0) {
        userRecord = rows[0];
      }
    }

    // Fallback to latest registered user in database if specific target not found
    if (!userRecord) {
      const rows = await this.db.query(
        `SELECT u.id as userId, u.phone, u.email, p.name, p.photo as avatarUrl, p.gender, p.preferences 
         FROM users u LEFT JOIN user_profiles p ON u.id = p.user_id 
         ORDER BY u.created_at DESC LIMIT 1`
      );
      if (rows && rows.length > 0) {
        userRecord = rows[0];
      }
    }

    if (userRecord) {
      return {
        userId: userRecord.userId || userRecord.id || 'cust_123',
        name: userRecord.name || 'Rider',
        email: userRecord.email || 'user@gorush.app',
        phone: userRecord.phone || '+91 98765 43210',
        avatarUrl: userRecord.avatarUrl || 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde',
        gender: userRecord.gender || 'Male',
        memberTier: 'GOLD',
        memberSince: 'January 2026',
        emergencyContacts: [
          { name: 'Sarah Doe', phone: '+91 98765 00001', relationship: 'Spouse' },
        ],
        rating: 4.95,
        totalTrips: 12,
      };
    }

    // Hardcoded fallback if database has 0 users
    return {
      userId: 'cust_123',
      name: 'GoRush Rider',
      email: 'rider@gorush.app',
      phone: '+91 98765 43210',
      avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde',
      gender: 'Male',
      memberTier: 'GOLD',
      memberSince: 'January 2026',
      emergencyContacts: [],
      rating: 5.0,
      totalTrips: 0,
    };
  }

  async updateProfile(userId: string, data: Partial<UserProfile>): Promise<UserProfile> {
    const cleanId = userId || 'cust_123';

    if (data.name) {
      await this.db.execute(
        `UPDATE user_profiles SET name = ? WHERE user_id = ?`,
        [data.name.trim(), cleanId]
      );
    }
    if (data.email) {
      await this.db.execute(
        `UPDATE users SET email = ? WHERE id = ?`,
        [data.email.trim(), cleanId]
      );
    }
    if (data.phone) {
      await this.db.execute(
        `UPDATE users SET phone = ? WHERE id = ?`,
        [data.phone.trim(), cleanId]
      );
    }

    return this.getProfile(cleanId);
  }

  getNotifications(): NotificationSettings {
    return this.notificationSettings;
  }

  updateNotifications(settings: Partial<NotificationSettings>): NotificationSettings {
    this.notificationSettings = { ...this.notificationSettings, ...settings };
    return this.notificationSettings;
  }

  getPrivacy(): PrivacySettings {
    return this.privacySettings;
  }

  updatePrivacy(settings: Partial<PrivacySettings>): PrivacySettings {
    this.privacySettings = { ...this.privacySettings, ...settings };
    return this.privacySettings;
  }

  requestAccountDeletion(reason: string, details?: string) {
    if (!reason) {
      throw new BadRequestException({ code: 'MISSING_REASON', message: 'Reason for deletion is required' });
    }

    const scheduledDate = new Date(Date.now() + 30 * 24 * 3600 * 1000).toISOString();
    const req = {
      requestId: `del_req_${Date.now()}`,
      userId: 'user_active',
      reason,
      details: details || '',
      status: 'PENDING_GRACE_PERIOD',
      requestedAt: new Date().toISOString(),
      scheduledPermanentDeletionAt: scheduledDate,
      gracePeriodDaysRemaining: 30,
    };

    this.deletionRequests.push(req);
    return req;
  }

  getSupportFaqs() {
    return [
      {
        category: 'Rides & Booking',
        faqs: [
          { q: 'How do I schedule a ride in advance?', a: 'You can tap on the Schedule icon on the home screen, select your desired date & pickup time up to 7 days ahead.' },
          { q: 'What is the OTP verification for?', a: 'The 4-digit OTP code ensures you get into the correct vehicle assigned to your booking for safety.' },
        ],
      },
      {
        category: 'Payments & Fare',
        faqs: [
          { q: 'How are fares calculated?', a: 'Fares are upfront prices based on base fare, distance, estimated travel time, platform fee, and GST.' },
          { q: 'When will I receive my refund for a cancelled ride?', a: 'Wallet refunds are processed instantly. Bank refunds take 2-3 business days depending on your bank.' },
        ],
      },
      {
        category: 'Safety & Emergency',
        faqs: [
          { q: 'What is the SOS button for?', a: 'Pressing SOS immediately alerts our 24/7 Safety Command Center, shares your live GPS with emergency contacts, and dials 112 helpline.' },
          { q: 'Is my phone number shared with the driver?', a: 'No, all calls and chats go through GoRush 256-bit masked private relay to protect your identity.' },
        ],
      },
    ];
  }
}
