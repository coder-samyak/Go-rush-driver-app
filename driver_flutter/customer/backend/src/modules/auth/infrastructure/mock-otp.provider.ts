import { Injectable, Logger } from '@nestjs/common';
import { OtpProvider } from '../domain/auth.types.js';

@Injectable()
export class MockOtpProvider implements OtpProvider {
  private readonly logger = new Logger(MockOtpProvider.name);

  async sendOtp(phoneNumber: string): Promise<void> {
    this.logger.log(`[MOCK] Sending OTP to ${phoneNumber}. Use 123456 to verify.`);
    // Simulate network delay
    await new Promise((resolve) => setTimeout(resolve, 500));
  }

  async verifyOtp(phoneNumber: string, otp: string): Promise<boolean> {
    this.logger.log(`[MOCK] Verifying OTP ${otp} for ${phoneNumber}`);
    await new Promise((resolve) => setTimeout(resolve, 500));
    return otp === '123456';
  }
}
