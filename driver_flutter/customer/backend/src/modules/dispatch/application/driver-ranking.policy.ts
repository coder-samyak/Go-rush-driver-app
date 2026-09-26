import { Injectable } from '@nestjs/common';
import { Driver } from '../domain/driver.js';

export interface RankedDriver {
  driver: Driver;
  distanceMeters: number;
  score: number; // lower is better
}

@Injectable()
export class DriverRankingPolicy {
  
  rank(candidates: { driver: Driver; distanceMeters: number }[]): RankedDriver[] {
    return candidates
      .map(c => {
        // Base score is distance.
        let score = c.distanceMeters;
        
        // Add fairness logic. If a driver has been online longer, give them a slight edge.
        // For phase 7 we mock this out, focusing purely on distance.
        return {
          driver: c.driver,
          distanceMeters: c.distanceMeters,
          score,
        };
      })
      .sort((a, b) => a.score - b.score);
  }
}
