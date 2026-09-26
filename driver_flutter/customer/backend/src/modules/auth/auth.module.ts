import { Module } from '@nestjs/common';
import { AuthController } from './presentation/auth.controller.js';
import { AuthService } from './application/auth.service.js';
import { OTP_PROVIDER_TOKEN } from './domain/auth.types.js';
import { MockOtpProvider } from './infrastructure/mock-otp.provider.js';

@Module({
  controllers: [AuthController],
  providers: [
    AuthService,
    {
      provide: OTP_PROVIDER_TOKEN,
      useClass: MockOtpProvider,
    },
  ],
})
export class AuthModule {}
