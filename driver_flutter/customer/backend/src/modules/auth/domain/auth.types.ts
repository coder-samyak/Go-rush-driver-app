export interface SendOtpDto {
  phoneNumber: string;
  deviceId?: string;
}

export interface VerifyOtpDto {
  phoneNumber: string;
  otp: string;
  deviceId?: string;
  deviceInfo?: string;
}

export interface SocialLoginDto {
  provider: 'google' | 'apple';
  idToken: string;
  email?: string;
  name?: string;
  deviceId?: string;
}

export interface EmailAuthDto {
  email: string;
  password?: string;
  deviceId?: string;
}

export interface AccountRecoveryDto {
  identifier: string; // phone or email
  recoveryType: 'sms' | 'email' | 'support';
}

export interface RefreshDto {
  refreshToken: string;
}

export interface UserSession {
  id: string;
  deviceName: string;
  ipAddress: string;
  lastActive: string;
  isCurrent: boolean;
}

export interface AuthResponse {
  user: {
    id: string;
    phoneNumber?: string;
    email?: string;
    name?: string;
    profileComplete: boolean;
    authProvider: 'phone' | 'google' | 'apple' | 'email' | 'password';
  };
  session: {
    accessToken: string;
    refreshToken: string;
    expiresAt: string;
  };
}

export interface OtpProvider {
  sendOtp(phoneNumber: string): Promise<void>;
  verifyOtp(phoneNumber: string, otp: string): Promise<boolean>;
}

export const OTP_PROVIDER_TOKEN = 'OtpProviderToken';
