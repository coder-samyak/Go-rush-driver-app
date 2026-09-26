import { Module } from '@nestjs/common';
import { AuthModule } from './modules/auth/auth.module.js';
import { PlacesModule } from './modules/places/places.module.js';
import { PricingModule } from './modules/pricing/pricing.module.js';
import { RideModule } from './modules/ride/ride.module.js';
import { AnalyticsModule } from './modules/analytics/analytics.module.js';
import { WalletModule } from './modules/wallet/wallet.module.js';
import { UserModule } from './modules/user/user.module.js';
import { SafetyModule } from './modules/safety/safety.module.js';
import { DatabaseModule } from './database/database.module.js';
import { TravelModule } from './modules/travel/travel.module.js';

@Module({
  imports: [DatabaseModule, AuthModule, PlacesModule, PricingModule, RideModule, AnalyticsModule, WalletModule, UserModule, SafetyModule, TravelModule],
  controllers: [],
  providers: [],
})
export class AppModule {}
