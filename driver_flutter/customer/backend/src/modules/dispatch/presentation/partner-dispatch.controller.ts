import { Controller, Post, Param, Headers, UnauthorizedException } from '@nestjs/common';
import { DispatchEngine } from '../application/dispatch.engine.js';

@Controller('v1/driver/offers')
export class PartnerDispatchController {
  constructor(private readonly dispatchEngine: DispatchEngine) {}

  private extractDriver(authHeader: string): string {
    const driverId = authHeader ? 'drv_1' : null; // Simulated Partner Auth Token
    if (!driverId) throw new UnauthorizedException();
    return driverId;
  }

  @Post(':offerId/accept')
  async acceptOffer(
    @Headers('Authorization') authHeader: string,
    @Param('offerId') offerId: string
  ) {
    const driverId = this.extractDriver(authHeader);
    await this.dispatchEngine.acceptOffer(offerId, driverId);
    return { success: true };
  }

  @Post(':offerId/reject')
  async rejectOffer(
    @Headers('Authorization') authHeader: string,
    @Param('offerId') offerId: string
  ) {
    const driverId = this.extractDriver(authHeader);
    await this.dispatchEngine.rejectOffer(offerId, driverId);
    return { success: true };
  }
}
