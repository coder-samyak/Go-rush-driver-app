import { Module } from '@nestjs/common';
import { SafetyController } from './presentation/safety.controller.js';
import { TrackingController } from './presentation/tracking.controller.js';
import { ShareSessionService } from './application/share-session.service.js';

@Module({
  controllers: [SafetyController, TrackingController],
  providers: [ShareSessionService],
  exports: [ShareSessionService],
})
export class SafetyModule {}
