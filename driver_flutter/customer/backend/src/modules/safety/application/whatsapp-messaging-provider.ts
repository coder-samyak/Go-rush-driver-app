import { Injectable, Logger } from '@nestjs/common';

export interface WhatsAppMessagingProvider {
  sendRideShareMessage(recipientPhone: string, shareUrl: string, customerName: string): Promise<boolean>;
}

@Injectable()
export class MockWhatsAppProvider implements WhatsAppMessagingProvider {
  private readonly logger = new Logger(MockWhatsAppProvider.name);

  async sendRideShareMessage(recipientPhone: string, shareUrl: string, customerName: string): Promise<boolean> {
    this.logger.log(`[WHATSAPP MOCK] To: ${recipientPhone} - ${customerName} has shared a live ride: ${shareUrl}`);
    // Simulate network delay
    await new Promise(resolve => setTimeout(resolve, 500));
    return true; 
  }
}
