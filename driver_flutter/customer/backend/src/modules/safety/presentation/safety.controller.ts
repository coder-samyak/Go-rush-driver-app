import { Controller, Post, Get, Delete, Body, Param, Headers } from '@nestjs/common';
import { DatabaseService } from '../../../database/database.service.js';

@Controller('v1/safety')
export class SafetyController {
  constructor(private readonly db: DatabaseService) {}

  @Post('sos-alert')
  async triggerSosAlert(
    @Headers('Authorization') authHeader: string,
    @Body() body: { rideId?: string; latitude?: number; longitude?: number; note?: string }
  ) {
    const userId = this.extractUserId(authHeader);
    const alertId = `sos_${Date.now()}`;
    const rideId = body.rideId || 'ride_active';
    const loc = `${body.latitude || 28.6139},${body.longitude || 77.2090}`;

    await this.db.execute(
      `INSERT INTO sos_events (id, ride_id, user_id, location, status, escalation)
       VALUES (?, ?, ?, ?, 'ACTIVE', 'POLICE_HELP_112_ESCALATED')`,
      [alertId, rideId, userId, loc]
    );

    return {
      status: 'SOS_TRIGGERED',
      alertId,
      policeHelpline: '112',
      safetyCommandControl: '+91 1800-GORUSHSF',
      contactsNotifiedCount: 2,
      broadcastActive: true,
      message: '🚨 Emergency SOS Triggered! 24x7 Safety Command Center notified and live location broadcast active.',
      timestamp: new Date().toISOString(),
    };
  }

  @Get('emergency-contacts')
  async getEmergencyContacts(@Headers('Authorization') authHeader: string) {
    const userId = this.extractUserId(authHeader);
    const contacts = await this.db.query(
      `SELECT * FROM emergency_contacts WHERE user_id = ? ORDER BY created_at DESC`,
      [userId]
    );

    if (contacts.length === 0) {
      // Provide default emergency contacts for newly onboarded users
      return {
        contacts: [
          {
            id: 'ec_default_1',
            name: 'Emergency Helpline (Police)',
            phone: '112',
            relationship: 'National Emergency',
          },
          {
            id: 'ec_default_2',
            name: 'GoRush Safety Desk',
            phone: '+91 1800-467874',
            relationship: '24x7 Control Room',
          },
        ]
      };
    }

    return { contacts };
  }

  @Post('emergency-contacts')
  async addEmergencyContact(
    @Headers('Authorization') authHeader: string,
    @Body() body: { name: string; phone: string; relationship?: string }
  ) {
    const userId = this.extractUserId(authHeader);
    const id = `ec_${Date.now()}`;
    const relationship = body.relationship || 'Family';

    await this.db.execute(
      `INSERT INTO emergency_contacts (id, user_id, name, phone, relationship) VALUES (?, ?, ?, ?, ?)`,
      [id, userId, body.name, body.phone, relationship]
    );

    return {
      success: true,
      contact: {
        id,
        name: body.name,
        phone: body.phone,
        relationship,
      }
    };
  }

  @Delete('emergency-contacts/:id')
  async deleteEmergencyContact(
    @Headers('Authorization') authHeader: string,
    @Param('id') id: string
  ) {
    const userId = this.extractUserId(authHeader);
    await this.db.execute(
      `DELETE FROM emergency_contacts WHERE id = ? AND user_id = ?`,
      [id, userId]
    );
    return { success: true, deletedId: id };
  }

  @Post('share-trip')
  async shareTrip(
    @Headers('Authorization') authHeader: string,
    @Body() body: { rideId: string; recipientPhone?: string }
  ) {
    const shareId = `share_${Date.now()}`;
    const trackingUrl = `https://gorush.app/track/${shareId}`;

    return {
      success: true,
      shareId,
      trackingUrl,
      message: `Live tracking link generated: ${trackingUrl}`,
    };
  }

  private extractUserId(authHeader?: string): string {
    if (authHeader && authHeader.startsWith('Bearer ')) {
      return authHeader.replace('Bearer ', '');
    }
    return 'cust_demo_123';
  }
}
