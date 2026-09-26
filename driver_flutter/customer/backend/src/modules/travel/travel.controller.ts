import { Controller, Get, Headers, UnauthorizedException } from '@nestjs/common';
import { TravelService } from './travel.service.js';

@Controller('v1/travel')
export class TravelController {
  constructor(private readonly travelService: TravelService) {}

  private extractUser(authHeader: string): string {
    const userId = authHeader ? 'cust_123' : null;
    if (!userId) throw new UnauthorizedException();
    return userId;
  }

  /**
   * GET /v1/travel/banner
   * Returns the hero promotional banner data for the Travel screen.
   */
  @Get('banner')
  getBanner(@Headers('Authorization') authHeader: string) {
    this.extractUser(authHeader);
    return this.travelService.getBanner();
  }

  /**
   * GET /v1/travel/deals
   * Returns all travel category deals (hotel, flight, bus, train) for the grid.
   */
  @Get('deals')
  getDeals(@Headers('Authorization') authHeader: string) {
    this.extractUser(authHeader);
    return {
      deals: this.travelService.getDeals(),
      partners: ['Goibibo', 'redBus', 'Confirmtkt'],
    };
  }

  /**
   * GET /v1/travel/hotels
   * Returns hotel listings with discount info.
   */
  @Get('hotels')
  getHotels(@Headers('Authorization') authHeader: string) {
    this.extractUser(authHeader);
    return {
      hotels: this.travelService.getHotels(),
      totalCount: this.travelService.getHotels().length,
    };
  }

  /**
   * GET /v1/travel/buses
   * Returns intercity bus options.
   */
  @Get('buses')
  getBuses(@Headers('Authorization') authHeader: string) {
    this.extractUser(authHeader);
    return {
      buses: this.travelService.getBuses(),
      totalCount: this.travelService.getBuses().length,
    };
  }

  /**
   * GET /v1/travel/flights
   * Returns available flight options.
   */
  @Get('flights')
  getFlights(@Headers('Authorization') authHeader: string) {
    this.extractUser(authHeader);
    return {
      flights: this.travelService.getFlights(),
      totalCount: this.travelService.getFlights().length,
    };
  }

  /**
   * GET /v1/travel/trains
   * Returns available train options with zero service fee.
   */
  @Get('trains')
  getTrains(@Headers('Authorization') authHeader: string) {
    this.extractUser(authHeader);
    return {
      trains: this.travelService.getTrains(),
      totalCount: this.travelService.getTrains().length,
    };
  }
}
