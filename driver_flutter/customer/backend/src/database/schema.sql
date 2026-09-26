-- GoRush Complete Production Database Schema (PostgreSQL + PostGIS compatible)

-- 1. users
CREATE TABLE IF NOT EXISTS users (
    id VARCHAR(64) PRIMARY KEY,
    phone VARCHAR(32) NOT NULL UNIQUE,
    email VARCHAR(128),
    status VARCHAR(32) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. user_profiles
CREATE TABLE IF NOT EXISTS user_profiles (
    user_id VARCHAR(64) PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(128) NOT NULL,
    photo TEXT,
    gender VARCHAR(32) DEFAULT 'Male',
    preferences JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. drivers
CREATE TABLE IF NOT EXISTS drivers (
    id VARCHAR(64) PRIMARY KEY,
    user_id VARCHAR(64) REFERENCES users(id) ON DELETE CASCADE,
    verification_status VARCHAR(32) NOT NULL DEFAULT 'VERIFIED',
    rating NUMERIC(3, 2) DEFAULT 4.90,
    online_status VARCHAR(32) DEFAULT 'ONLINE',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 4. driver_documents
CREATE TABLE IF NOT EXISTS driver_documents (
    id VARCHAR(64) PRIMARY KEY,
    driver_id VARCHAR(64) NOT NULL REFERENCES drivers(id) ON DELETE CASCADE,
    type VARCHAR(64) NOT NULL,
    number_hash VARCHAR(128) NOT NULL,
    masked VARCHAR(64) NOT NULL,
    expiry DATE,
    status VARCHAR(32) DEFAULT 'APPROVED',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 5. vehicles
CREATE TABLE IF NOT EXISTS vehicles (
    id VARCHAR(64) PRIMARY KEY,
    driver_id VARCHAR(64) NOT NULL REFERENCES drivers(id) ON DELETE CASCADE,
    category VARCHAR(64) NOT NULL,
    make VARCHAR(64) NOT NULL,
    model VARCHAR(64) NOT NULL,
    registration VARCHAR(64) NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 6. vehicle_documents
CREATE TABLE IF NOT EXISTS vehicle_documents (
    id VARCHAR(64) PRIMARY KEY,
    vehicle_id VARCHAR(64) NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
    type VARCHAR(64) NOT NULL,
    expiry DATE,
    status VARCHAR(32) DEFAULT 'APPROVED',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 7. driver_locations
CREATE TABLE IF NOT EXISTS driver_locations (
    driver_id VARCHAR(64) PRIMARY KEY REFERENCES drivers(id) ON DELETE CASCADE,
    lat NUMERIC(10, 6) NOT NULL,
    lng NUMERIC(10, 6) NOT NULL,
    heading NUMERIC(5, 2) DEFAULT 0,
    speed NUMERIC(5, 2) DEFAULT 0,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 8. rides
CREATE TABLE IF NOT EXISTS rides (
    id VARCHAR(64) PRIMARY KEY,
    customer_id VARCHAR(64) NOT NULL REFERENCES users(id),
    driver_id VARCHAR(64) REFERENCES drivers(id),
    category VARCHAR(64) NOT NULL,
    pickup JSONB NOT NULL,
    dropoff JSONB NOT NULL,
    state VARCHAR(32) NOT NULL DEFAULT 'REQUESTED',
    otp_code VARCHAR(8),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 9. ride_events
CREATE TABLE IF NOT EXISTS ride_events (
    id VARCHAR(64) PRIMARY KEY,
    ride_id VARCHAR(64) NOT NULL REFERENCES rides(id) ON DELETE CASCADE,
    event_type VARCHAR(64) NOT NULL,
    actor VARCHAR(32) NOT NULL,
    payload JSONB DEFAULT '{}'::jsonb,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 10. ride_fares
CREATE TABLE IF NOT EXISTS ride_fares (
    ride_id VARCHAR(64) PRIMARY KEY REFERENCES rides(id) ON DELETE CASCADE,
    version VARCHAR(32) NOT NULL DEFAULT 'v1.0.0',
    breakdown JSONB NOT NULL,
    total NUMERIC(10, 2) NOT NULL,
    tax NUMERIC(10, 2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 11. payments
CREATE TABLE IF NOT EXISTS payments (
    id VARCHAR(64) PRIMARY KEY,
    ride_id VARCHAR(64) REFERENCES rides(id) ON DELETE SET NULL,
    provider_ref VARCHAR(128),
    status VARCHAR(32) NOT NULL DEFAULT 'SUCCESS',
    amount NUMERIC(10, 2) NOT NULL,
    payment_method VARCHAR(64) DEFAULT 'Google Pay',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 12. wallets
CREATE TABLE IF NOT EXISTS wallets (
    id VARCHAR(64) PRIMARY KEY,
    owner_type VARCHAR(32) NOT NULL DEFAULT 'CUSTOMER',
    owner_id VARCHAR(64) NOT NULL UNIQUE,
    balance NUMERIC(10, 2) NOT NULL DEFAULT 450.00,
    promo_balance NUMERIC(10, 2) NOT NULL DEFAULT 150.00,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 13. wallet_transactions
CREATE TABLE IF NOT EXISTS wallet_transactions (
    id VARCHAR(64) PRIMARY KEY,
    wallet_id VARCHAR(64) NOT NULL REFERENCES wallets(id) ON DELETE CASCADE,
    debit_credit VARCHAR(16) NOT NULL,
    amount NUMERIC(10, 2) NOT NULL,
    type VARCHAR(32) NOT NULL,
    title VARCHAR(128) NOT NULL,
    subtitle VARCHAR(256),
    reference VARCHAR(128),
    status VARCHAR(32) DEFAULT 'COMPLETED',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 14. payouts
CREATE TABLE IF NOT EXISTS payouts (
    id VARCHAR(64) PRIMARY KEY,
    driver_id VARCHAR(64) NOT NULL REFERENCES drivers(id),
    amount NUMERIC(10, 2) NOT NULL,
    status VARCHAR(32) NOT NULL DEFAULT 'COMPLETED',
    provider_ref VARCHAR(128),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 15. promocodes
CREATE TABLE IF NOT EXISTS promocodes (
    id VARCHAR(64) PRIMARY KEY,
    code VARCHAR(64) NOT NULL UNIQUE,
    rule JSONB NOT NULL,
    validity TIMESTAMP WITH TIME ZONE NOT NULL,
    usage_limit INT DEFAULT 1000,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 16. ratings
CREATE TABLE IF NOT EXISTS ratings (
    id VARCHAR(64) PRIMARY KEY,
    ride_id VARCHAR(64) NOT NULL REFERENCES rides(id),
    rater_id VARCHAR(64) NOT NULL,
    target_id VARCHAR(64) NOT NULL,
    score INT NOT NULL CHECK (score >= 1 AND score <= 5),
    feedback_tags JSONB DEFAULT '[]'::jsonb,
    comment TEXT,
    tip_amount NUMERIC(10, 2) DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 17. support_tickets
CREATE TABLE IF NOT EXISTS support_tickets (
    id VARCHAR(64) PRIMARY KEY,
    user_id VARCHAR(64) NOT NULL REFERENCES users(id),
    ride_id VARCHAR(64),
    priority VARCHAR(32) DEFAULT 'MEDIUM',
    category VARCHAR(64) NOT NULL,
    description TEXT,
    status VARCHAR(32) DEFAULT 'OPEN',
    assignee VARCHAR(64) DEFAULT 'AI_BOT_SUPPORT',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 18. sos_events
CREATE TABLE IF NOT EXISTS sos_events (
    id VARCHAR(64) PRIMARY KEY,
    ride_id VARCHAR(64) NOT NULL REFERENCES rides(id),
    user_id VARCHAR(64) NOT NULL REFERENCES users(id),
    location JSONB NOT NULL,
    status VARCHAR(32) DEFAULT 'ACTIVE',
    escalation VARCHAR(64) DEFAULT 'POLICE_HELP_112',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 19. pricing_rules
CREATE TABLE IF NOT EXISTS pricing_rules (
    id VARCHAR(64) PRIMARY KEY,
    city VARCHAR(64) NOT NULL DEFAULT 'DELHI_NCR',
    zone VARCHAR(64) NOT NULL DEFAULT 'NCR_ALL',
    category VARCHAR(64) NOT NULL,
    version VARCHAR(32) DEFAULT 'v1.0.0',
    parameters JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 20. fraud_events
CREATE TABLE IF NOT EXISTS fraud_events (
    id VARCHAR(64) PRIMARY KEY,
    user_id VARCHAR(64),
    driver_id VARCHAR(64),
    rule VARCHAR(128) NOT NULL,
    score NUMERIC(5, 2) NOT NULL,
    status VARCHAR(32) DEFAULT 'FLAGGED',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 21. audit_logs
CREATE TABLE IF NOT EXISTS audit_logs (
    id VARCHAR(64) PRIMARY KEY,
    actor VARCHAR(64) NOT NULL,
    action VARCHAR(128) NOT NULL,
    entity VARCHAR(64) NOT NULL,
    before JSONB,
    after JSONB,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 22. travel_deals
CREATE TABLE IF NOT EXISTS travel_deals (
    id VARCHAR(64) PRIMARY KEY,
    category VARCHAR(32) NOT NULL CHECK (category IN ('hotel', 'flight', 'bus', 'train')),
    title VARCHAR(128) NOT NULL,
    subtitle VARCHAR(256),
    discount_label VARCHAR(64) NOT NULL,
    discount_description VARCHAR(256),
    partner VARCHAR(64) NOT NULL,
    deep_link_url TEXT,
    icon_type VARCHAR(32) NOT NULL,
    is_zero_fee BOOLEAN NOT NULL DEFAULT FALSE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    sort_order INT NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 23. travel_banners
CREATE TABLE IF NOT EXISTS travel_banners (
    id VARCHAR(64) PRIMARY KEY,
    title VARCHAR(128) NOT NULL,
    subtitle VARCHAR(128),
    promo_code VARCHAR(64),
    promo_description VARCHAR(256),
    image_url TEXT,
    bg_color VARCHAR(32) DEFAULT '#1565C0',
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    valid_from TIMESTAMP WITH TIME ZONE,
    valid_until TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Seed initial travel deals
INSERT INTO travel_deals (id, category, title, subtitle, discount_label, discount_description, partner, deep_link_url, icon_type, is_zero_fee, sort_order)
VALUES
  ('deal_hotel_001', 'hotel', 'Hotel', 'Best room rates', 'Upto 55% Off', 'On top hotel chains across India', 'Goibibo', 'https://goibibo.com', 'hotel', FALSE, 1),
  ('deal_flight_001', 'flight', 'Flight', 'Lowest fare, guaranteed', 'Upto ₹4000 Off', 'On domestic & international flights', 'Goibibo', 'https://goibibo.com/flights', 'flight', FALSE, 2),
  ('deal_bus_001', 'bus', 'Bus', 'Save big on', 'Upto 25% Off', 'On intercity bus bookings', 'redBus', 'https://redbus.in', 'bus', FALSE, 3),
  ('deal_train_001', 'train', 'Train', '', 'Zero Service Fee', 'Book trains with no extra charges', 'Confirmtkt', 'https://confirmtkt.com', 'train', TRUE, 4)
ON CONFLICT (id) DO NOTHING;
