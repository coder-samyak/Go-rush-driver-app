import { RideStatus } from './ride.js';
import { BadRequestException } from '@nestjs/common';

export class RideStateMachine {
  private static readonly transitions: Record<RideStatus, RideStatus[]> = {
    [RideStatus.REQUESTED]: [RideStatus.SEARCHING, RideStatus.CANCELLED, RideStatus.FAILED],
    [RideStatus.SEARCHING]: [RideStatus.DRIVER_ASSIGNED, RideStatus.CANCELLED, RideStatus.NO_DRIVER],
    [RideStatus.DRIVER_ASSIGNED]: [RideStatus.DRIVER_EN_ROUTE, RideStatus.CANCELLED],
    [RideStatus.DRIVER_EN_ROUTE]: [RideStatus.DRIVER_ARRIVED, RideStatus.CANCELLED],
    [RideStatus.DRIVER_ARRIVED]: [RideStatus.RIDE_STARTED, RideStatus.CANCELLED],
    [RideStatus.RIDE_STARTED]: [RideStatus.RIDE_IN_PROGRESS],
    [RideStatus.RIDE_IN_PROGRESS]: [RideStatus.RIDE_COMPLETED],
    
    // Terminal states
    [RideStatus.RIDE_COMPLETED]: [],
    [RideStatus.CANCELLED]: [],
    [RideStatus.NO_DRIVER]: [],
    [RideStatus.FAILED]: [],
  };

  /**
   * Validates if a transition from `currentState` to `nextState` is allowed.
   */
  static validateTransition(currentState: RideStatus, nextState: RideStatus): void {
    const allowedNextStates = this.transitions[currentState];
    
    if (!allowedNextStates) {
      throw new BadRequestException({ code: 'RIDE_INVALID_STATE', message: 'Current state is invalid.' });
    }

    if (!allowedNextStates.includes(nextState)) {
      throw new BadRequestException({
        code: 'RIDE_INVALID_TRANSITION',
        message: `Cannot transition from ${currentState} to ${nextState}.`,
      });
    }
  }

  /**
   * Checks if a state is terminal.
   */
  static isTerminal(state: RideStatus): boolean {
    return this.transitions[state].length === 0;
  }
}
