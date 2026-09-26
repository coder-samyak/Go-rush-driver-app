import { Controller, Get, Headers, UnauthorizedException } from '@nestjs/common';

@Controller('v1/admin/analytics')
export class AnalyticsController {
  
  // Feature flag check
  private isAnalyticsEnabled(): boolean {
    return process.env.ANALYTICS_DASHBOARD_ENABLED === 'true';
  }

  private checkAccess(authHeader: string) {
    if (!authHeader || !authHeader.startsWith('Bearer admin-')) {
      throw new UnauthorizedException('Admin access required');
    }
    if (!this.isAnalyticsEnabled()) {
      throw new UnauthorizedException('Analytics dashboard is currently disabled');
    }
  }

  @Get('overview')
  async getOverview(@Headers('Authorization') authHeader: string) {
    this.checkAccess(authHeader);
    
    // Returning DATA_UNAVAILABLE state as per Rule 35 until real data exists
    return {
      state: 'DATA_UNAVAILABLE',
      generatedAt: new Date().toISOString(),
      message: 'Source events not yet propagated to analytical models. No fabricated data allowed.',
      data: null
    };
  }

  @Get('finance')
  async getFinanceAnalytics(@Headers('Authorization') authHeader: string) {
    this.checkAccess(authHeader);
    
    if (process.env.FINANCIAL_ANALYTICS_ENABLED !== 'true') {
       return { state: 'PERMISSION_DENIED', message: 'Financial analytics module disabled' };
    }

    return {
      state: 'DATA_UNAVAILABLE',
      generatedAt: new Date().toISOString(),
      data: null
    };
  }
}
