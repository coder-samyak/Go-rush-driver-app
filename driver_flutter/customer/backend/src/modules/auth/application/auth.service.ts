import { Injectable, Inject, UnauthorizedException, BadRequestException } from '@nestjs/common';
import { 
  OtpProvider, 
  OTP_PROVIDER_TOKEN, 
  AuthResponse, 
  SendOtpDto, 
  VerifyOtpDto, 
  SocialLoginDto,
  EmailAuthDto,
  AccountRecoveryDto,
  RefreshDto,
  UserSession 
} from '../domain/auth.types.js';

import { DatabaseService } from '../../../database/database.service.js';

@Injectable()
export class AuthService {
  constructor(
    @Inject(OTP_PROVIDER_TOKEN)
    private readonly otpProvider: OtpProvider,
    private readonly databaseService: DatabaseService,
  ) {}

  async sendOtp(dto: SendOtpDto): Promise<{ message: string }> {
    if (!dto.phoneNumber) {
      throw new BadRequestException({ code: 'AUTH_001', message: 'Phone number is required' });
    }
    await this.otpProvider.sendOtp(dto.phoneNumber);
    // Persist registration in DB
    await this.databaseService.saveUserRegistration(dto.phoneNumber);
    return { message: 'OTP Sent' };
  }

  async verifyOtp(dto: VerifyOtpDto): Promise<AuthResponse> {
    const isValid = await this.otpProvider.verifyOtp(dto.phoneNumber, dto.otp);
    
    if (!isValid) {
      throw new UnauthorizedException({ code: 'AUTH_002', message: 'Invalid OTP' });
    }

    const savedUser = await this.databaseService.saveUserRegistration(dto.phoneNumber);

    return {
      user: {
        id: savedUser.id || 'cust_123',
        phoneNumber: dto.phoneNumber,
        profileComplete: false,
        authProvider: 'phone',
      },
      session: {
        accessToken: 'mock_access_token_' + Date.now(),
        refreshToken: 'mock_refresh_token_' + Date.now(),
        expiresAt: new Date(Date.now() + 3600000).toISOString(),
      },
    };
  }

  async registerWithPassword(dto: { name: string; email: string; phoneNumber: string; password: string }): Promise<AuthResponse> {
    if (!dto.name || !dto.phoneNumber || !dto.password) {
      throw new BadRequestException({ code: 'AUTH_010', message: 'Name, phone number, and password are required' });
    }

    try {
      const savedUser = await this.databaseService.registerUserWithPassword(
        dto.name,
        dto.email || `${dto.phoneNumber}@gorush.app`,
        dto.phoneNumber,
        dto.password
      );

      return {
        user: {
          id: savedUser.id,
          name: savedUser.name,
          email: savedUser.email,
          phoneNumber: savedUser.phoneNumber,
          profileComplete: true,
          authProvider: 'password',
        },
        session: {
          accessToken: 'mock_access_token_' + Date.now(),
          refreshToken: 'mock_refresh_token_' + Date.now(),
          expiresAt: new Date(Date.now() + 3600000).toISOString(),
        },
      };
    } catch (err: any) {
      throw new BadRequestException({ code: 'AUTH_REGISTRATION_FAILED', message: err.message });
    }
  }

  async loginWithPassword(dto: { identifier: string; password: string }): Promise<AuthResponse> {
    if (!dto.identifier || !dto.password) {
      throw new BadRequestException({ code: 'AUTH_011', message: 'Phone number/Email and password are required' });
    }

    try {
      const user = await this.databaseService.loginWithPassword(dto.identifier, dto.password);

      return {
        user: {
          id: user.id,
          name: user.name,
          email: user.email,
          phoneNumber: user.phoneNumber,
          profileComplete: true,
          authProvider: 'password',
        },
        session: {
          accessToken: 'mock_access_token_' + Date.now(),
          refreshToken: 'mock_refresh_token_' + Date.now(),
          expiresAt: new Date(Date.now() + 3600000).toISOString(),
        },
      };
    } catch (err: any) {
      throw new UnauthorizedException({ code: 'AUTH_LOGIN_FAILED', message: err.message });
    }
  }

  async socialLogin(dto: SocialLoginDto): Promise<AuthResponse> {
    if (!dto.provider || !dto.idToken) {
      throw new BadRequestException({ code: 'AUTH_004', message: 'Provider and ID Token are required' });
    }

    return {
      user: {
        id: 'cust_soc_' + Math.random().toString(36).substring(2, 9),
        email: dto.email ?? `user_${dto.provider}@gorush.com`,
        name: dto.name ?? `${dto.provider.toUpperCase()} User`,
        profileComplete: true,
        authProvider: dto.provider,
      },
      session: {
        accessToken: 'mock_social_token_' + Date.now(),
        refreshToken: 'mock_social_refresh_' + Date.now(),
        expiresAt: new Date(Date.now() + 3600000).toISOString(),
      },
    };
  }

  async emailAuth(dto: EmailAuthDto): Promise<AuthResponse> {
    if (!dto.email) {
      throw new BadRequestException({ code: 'AUTH_005', message: 'Email address is required' });
    }

    return {
      user: {
        id: 'cust_email_' + Math.random().toString(36).substring(2, 9),
        email: dto.email,
        profileComplete: true,
        authProvider: 'email',
      },
      session: {
        accessToken: 'mock_email_token_' + Date.now(),
        refreshToken: 'mock_email_refresh_' + Date.now(),
        expiresAt: new Date(Date.now() + 3600000).toISOString(),
      },
    };
  }

  async accountRecovery(dto: AccountRecoveryDto): Promise<{ message: string; recoveryCode?: string }> {
    if (!dto.identifier) {
      throw new BadRequestException({ code: 'AUTH_006', message: 'Identifier is required for recovery' });
    }

    return {
      message: `Recovery instructions sent via ${dto.recoveryType} to ${dto.identifier}`,
      recoveryCode: 'REC-' + Math.floor(100000 + Math.random() * 900000),
    };
  }

  async getActiveSessions(): Promise<{ sessions: UserSession[] }> {
    return {
      sessions: [
        {
          id: 'sess_1',
          deviceName: 'Chrome Browser (Web)',
          ipAddress: '127.0.0.1',
          lastActive: new Date().toISOString(),
          isCurrent: true,
        },
        {
          id: 'sess_2',
          deviceName: 'GoRush Android App',
          ipAddress: '192.168.1.45',
          lastActive: new Date(Date.now() - 86400000).toISOString(),
          isCurrent: false,
        },
      ],
    };
  }

  async revokeSession(sessionId: string): Promise<{ message: string }> {
    return { message: `Session ${sessionId} revoked successfully` };
  }

  async refresh(dto: RefreshDto): Promise<AuthResponse> {
    if (!dto.refreshToken) {
      throw new UnauthorizedException({ code: 'AUTH_003', message: 'Invalid Refresh Token' });
    }

    return {
      user: {
        id: 'cust_mock_123',
        phoneNumber: '+919876543210',
        profileComplete: true,
        authProvider: 'phone',
      },
      session: {
        accessToken: 'mock_access_token_' + Date.now(),
        refreshToken: 'mock_refresh_token_' + Date.now(),
        expiresAt: new Date(Date.now() + 3600000).toISOString(),
      },
    };
  }

  async logout(): Promise<{ message: string }> {
    return { message: 'Logged out successfully' };
  }
}
