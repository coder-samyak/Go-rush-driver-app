import { Module } from '@nestjs/common';
import { PlacesController } from './presentation/places.controller.js';
import { PlacesService } from './application/places.service.js';

@Module({
  controllers: [PlacesController],
  providers: [PlacesService],
})
export class PlacesModule {}
