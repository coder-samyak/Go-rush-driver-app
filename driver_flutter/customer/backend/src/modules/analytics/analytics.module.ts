import { Module } from '@nestjs/common';
import { AnalyticsController } from './presentation/analytics.controller.js';

@Module({
  controllers: [AnalyticsController],
  providers: [],
})
export class AnalyticsModule {}
