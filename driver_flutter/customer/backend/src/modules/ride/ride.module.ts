import { Module } from '@nestjs/common';
import { RideController } from './presentation/ride.controller.js';
import { RideService } from './application/ride.service.js';
import { PricingModule } from '../pricing/pricing.module.js';

@Module({
  imports: [PricingModule],
  controllers: [RideController],
  providers: [RideService],
})
export class RideModule {}
