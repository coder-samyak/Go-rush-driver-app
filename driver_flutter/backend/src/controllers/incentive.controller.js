const Ride = require('../models/ride.model');

const startOfCurrentWeek = (now) => {
  const start = new Date(now);
  const day = start.getDay();
  const daysSinceMonday = (day + 6) % 7;
  start.setHours(0, 0, 0, 0);
  start.setDate(start.getDate() - daysSinceMonday);
  return start;
};

/** GET /api/driver/incentives - authenticated, live incentive progress. */
exports.getIncentives = async (req, res) => {
  try {
    const now = new Date();
    const weekStart = startOfCurrentWeek(now);
    const completedRides = await Ride.find({
      driverId: req.driver._id,
      status: 'completed',
      completedAt: { $gte: weekStart, $lte: now },
    }).select('completedAt');

    const weeklyCompleted = completedRides.length;
    const weekendCompleted = completedRides.filter((ride) => {
      const day = new Date(ride.completedAt).getDay();
      return day === 0 || day === 6;
    }).length;
    const rating = Number(req.driver.rating) || 0;
    const weeklyTarget = 15;
    const weekendTarget = 10;
    const ratingTarget = 4.5;

    const quest = (completed, target, reward) => ({
      completed,
      target,
      reward,
      progress: Math.min(completed / target, 1),
      eligible: completed >= target,
      status: completed >= target ? 'Qualified' : 'In progress',
    });

    return res.status(200).json({
      success: true,
      data: {
        weekly: quest(weeklyCompleted, weeklyTarget, 1000),
        weekend: quest(weekendCompleted, weekendTarget, 500),
        topDriver: {
          rating,
          target: ratingTarget,
          reward: 1500,
          progress: Math.min(rating / ratingTarget, 1),
          eligible: rating >= ratingTarget,
          status: rating >= ratingTarget ? 'Qualified' : 'Not qualified',
        },
      },
    });
  } catch (err) {
    console.error('getIncentives error:', err);
    return res.status(500).json({ success: false, message: 'Unable to load incentives' });
  }
};
