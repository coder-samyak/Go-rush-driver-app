import { Controller, Post, Get, Body, Param, HttpCode, HttpStatus } from '@nestjs/common';
import { AuthService } from '../application/auth.service.js';
import { 
  SendOtpDto, 
  VerifyOtpDto, 
  SocialLoginDto,
  EmailAuthDto,
  AccountRecoveryDto,
  RefreshDto 
} from '../domain/auth.types.js';

@Controller('v1/auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('send-otp')
  @HttpCode(HttpStatus.OK)
  async sendOtp(@Body() dto: SendOtpDto) {
    return this.authService.sendOtp(dto);
  }

  @Post('verify-otp')
  @HttpCode(HttpStatus.OK)
  async verifyOtp(@Body() dto: VerifyOtpDto) {
    return this.authService.verifyOtp(dto);
  }

  @Post('register')
  @HttpCode(HttpStatus.OK)
  async registerWithPassword(@Body() dto: { name: string; email: string; phoneNumber: string; password: string }) {
    return this.authService.registerWithPassword(dto);
  }

  @Post('login-password')
  @HttpCode(HttpStatus.OK)
  async loginWithPassword(@Body() dto: { identifier: string; password: string }) {
    return this.authService.loginWithPassword(dto);
  }

  @Post('social')
  @HttpCode(HttpStatus.OK)
  async socialLogin(@Body() dto: SocialLoginDto) {
    return this.authService.socialLogin(dto);
  }

  @Post('email')
  @HttpCode(HttpStatus.OK)
  async emailAuth(@Body() dto: EmailAuthDto) {
    return this.authService.emailAuth(dto);
  }

  @Post('recover')
  @HttpCode(HttpStatus.OK)
  async accountRecovery(@Body() dto: AccountRecoveryDto) {
    return this.authService.accountRecovery(dto);
  }

  @Get('sessions')
  async getActiveSessions() {
    return this.authService.getActiveSessions();
  }

  @Post('sessions/revoke/:id')
  @HttpCode(HttpStatus.OK)
  async revokeSession(@Param('id') id: string) {
    return this.authService.revokeSession(id);
  }

  @Post('refresh')
  @HttpCode(HttpStatus.OK)
  async refresh(@Body() dto: RefreshDto) {
    return this.authService.refresh(dto);
  }

  @Post('logout')
  @HttpCode(HttpStatus.OK)
  async logout() {
    return this.authService.logout();
  }
}
