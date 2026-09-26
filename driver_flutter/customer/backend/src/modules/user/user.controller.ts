import { Controller, Get, Patch, Delete, Body, Headers } from '@nestjs/common';
import { UserService, UserProfile, NotificationSettings, PrivacySettings } from './user.service.js';

@Controller('v1/user')
export class UserController {
  constructor(private readonly userService: UserService) {}

  @Get('profile')
  getProfile(@Headers('Authorization') authHeader: string) {
    return this.userService.getProfile(authHeader);
  }

  @Patch('profile')
  updateProfile(
    @Headers('Authorization') authHeader: string,
    @Body() data: Partial<UserProfile>,
  ) {
    return this.userService.updateProfile(authHeader, data);
  }

  @Get('notifications')
  getNotifications(@Headers('Authorization') authHeader: string) {
    return this.userService.getNotifications();
  }

  @Patch('notifications')
  updateNotifications(
    @Headers('Authorization') authHeader: string,
    @Body() settings: Partial<NotificationSettings>,
  ) {
    return this.userService.updateNotifications(settings);
  }

  @Get('privacy')
  getPrivacy(@Headers('Authorization') authHeader: string) {
    return this.userService.getPrivacy();
  }

  @Patch('privacy')
  updatePrivacy(
    @Headers('Authorization') authHeader: string,
    @Body() settings: Partial<PrivacySettings>,
  ) {
    return this.userService.updatePrivacy(settings);
  }

  @Delete('account')
  requestAccountDeletion(
    @Headers('Authorization') authHeader: string,
    @Body('reason') reason: string,
    @Body('details') details?: string,
  ) {
    return this.userService.requestAccountDeletion(reason, details);
  }

  @Get('support/faqs')
  getSupportFaqs(@Headers('Authorization') authHeader: string) {
    return this.userService.getSupportFaqs();
  }
}
