import { Injectable, OnModuleInit, OnModuleDestroy, Logger } from '@nestjs/common';
import sqlite3 from 'sqlite3';
import pg from 'pg';
import * as fs from 'fs';
import * as path from 'path';

@Injectable()
export class DatabaseService implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(DatabaseService.name);
  private sqliteDb?: sqlite3.Database;
  private pgClient?: pg.Client;
  private isPostgres = false;

  async onModuleInit() {
    const pgHost = process.env.POSTGRES_HOST;
    const pgPort = process.env.POSTGRES_PORT ? parseInt(process.env.POSTGRES_PORT, 10) : 5432;
    const pgUser = process.env.POSTGRES_USER || 'postgres';
    const pgPass = process.env.POSTGRES_PASSWORD || 'postgres';
    const pgDb = process.env.POSTGRES_DB || 'gorush';

    if (pgHost) {
      try {
        this.logger.log(`Connecting to PostgreSQL database at ${pgHost}:${pgPort}/${pgDb}...`);
        this.pgClient = new pg.Client({
          host: pgHost,
          port: pgPort,
          user: pgUser,
          password: pgPass,
          database: pgDb,
        });
        await this.pgClient.connect();
        this.isPostgres = true;
        this.logger.log('Successfully connected to PostgreSQL database!');
        await this.initializeTables();
        return;
      } catch (err: any) {
        this.logger.warn(`PostgreSQL connection failed (${err?.message}). Falling back to embedded SQLite store.`);
      }
    }

    // Fallback SQLite Database for 100% reliable out-of-the-box local persistence
    const dbDir = path.resolve(process.cwd(), 'data');
    if (!fs.existsSync(dbDir)) {
      fs.mkdirSync(dbDir, { recursive: true });
    }
    const dbPath = path.join(dbDir, 'gorush_production.sqlite');
    this.sqliteDb = new sqlite3.Database(dbPath, (err) => {
      if (err) {
        this.logger.error('Failed to initialize SQLite database', err);
      } else {
        this.logger.log(`Embedded SQLite database initialized at ${dbPath}`);
      }
    });

    await this.initializeTables();
    await this.seedInitialData();
  }

  onModuleDestroy() {
    if (this.sqliteDb) {
      this.sqliteDb.close();
    }
    if (this.pgClient) {
      this.pgClient.end();
    }
  }

  private async initializeTables() {
    // 1. users
    await this.execute(`
      CREATE TABLE IF NOT EXISTS users (
        id VARCHAR(64) PRIMARY KEY,
        phone VARCHAR(32) NOT NULL UNIQUE,
        email VARCHAR(128),
        password_hash VARCHAR(256),
        status VARCHAR(32) NOT NULL DEFAULT 'ACTIVE',
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      );
    `);

    try {
      await this.execute(`ALTER TABLE users ADD COLUMN password_hash VARCHAR(256)`);
    } catch (_) {
      // Column already exists
    }

    // 2. user_profiles
    await this.execute(`
      CREATE TABLE IF NOT EXISTS user_profiles (
        user_id VARCHAR(64) PRIMARY KEY,
        name VARCHAR(128) NOT NULL,
        photo TEXT,
        gender VARCHAR(32) DEFAULT 'Male',
        preferences TEXT DEFAULT '{}',
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // 3. drivers
    await this.execute(`
      CREATE TABLE IF NOT EXISTS drivers (
        id VARCHAR(64) PRIMARY KEY,
        user_id VARCHAR(64),
        verification_status VARCHAR(32) DEFAULT 'VERIFIED',
        rating NUMERIC(3, 2) DEFAULT 4.90,
        online_status VARCHAR(32) DEFAULT 'ONLINE',
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // 4. driver_documents
    await this.execute(`
      CREATE TABLE IF NOT EXISTS driver_documents (
        id VARCHAR(64) PRIMARY KEY,
        driver_id VARCHAR(64) NOT NULL,
        type VARCHAR(64) NOT NULL,
        number_hash VARCHAR(128) NOT NULL,
        masked VARCHAR(64) NOT NULL,
        expiry TEXT,
        status VARCHAR(32) DEFAULT 'APPROVED',
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // 5. vehicles
    await this.execute(`
      CREATE TABLE IF NOT EXISTS vehicles (
        id VARCHAR(64) PRIMARY KEY,
        driver_id VARCHAR(64) NOT NULL,
        category VARCHAR(64) NOT NULL,
        make VARCHAR(64) NOT NULL,
        model VARCHAR(64) NOT NULL,
        registration VARCHAR(64) NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // 6. vehicle_documents
    await this.execute(`
      CREATE TABLE IF NOT EXISTS vehicle_documents (
        id VARCHAR(64) PRIMARY KEY,
        vehicle_id VARCHAR(64) NOT NULL,
        type VARCHAR(64) NOT NULL,
        expiry TEXT,
        status VARCHAR(32) DEFAULT 'APPROVED',
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // 7. driver_locations
    await this.execute(`
      CREATE TABLE IF NOT EXISTS driver_locations (
        driver_id VARCHAR(64) PRIMARY KEY,
        lat NUMERIC(10, 6) NOT NULL,
        lng NUMERIC(10, 6) NOT NULL,
        heading NUMERIC(5, 2) DEFAULT 0,
        speed NUMERIC(5, 2) DEFAULT 0,
        timestamp TEXT DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // 8. rides
    await this.execute(`
      CREATE TABLE IF NOT EXISTS rides (
        id VARCHAR(64) PRIMARY KEY,
        customer_id VARCHAR(64) NOT NULL,
        driver_id VARCHAR(64),
        category VARCHAR(64) NOT NULL,
        pickup TEXT NOT NULL,
        dropoff TEXT NOT NULL,
        state VARCHAR(32) NOT NULL DEFAULT 'REQUESTED',
        otp_code VARCHAR(8),
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // 9. ride_events
    await this.execute(`
      CREATE TABLE IF NOT EXISTS ride_events (
        id VARCHAR(64) PRIMARY KEY,
        ride_id VARCHAR(64) NOT NULL,
        event_type VARCHAR(64) NOT NULL,
        actor VARCHAR(32) NOT NULL,
        payload TEXT DEFAULT '{}',
        timestamp TEXT DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // 10. ride_fares
    await this.execute(`
      CREATE TABLE IF NOT EXISTS ride_fares (
        ride_id VARCHAR(64) PRIMARY KEY,
        version VARCHAR(32) DEFAULT 'v1.0.0',
        breakdown TEXT NOT NULL,
        total NUMERIC(10, 2) NOT NULL,
        tax NUMERIC(10, 2) NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // 11. payments
    await this.execute(`
      CREATE TABLE IF NOT EXISTS payments (
        id VARCHAR(64) PRIMARY KEY,
        ride_id VARCHAR(64),
        provider_ref VARCHAR(128),
        status VARCHAR(32) DEFAULT 'SUCCESS',
        amount NUMERIC(10, 2) NOT NULL,
        payment_method VARCHAR(64) DEFAULT 'Google Pay',
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // 12. wallets
    await this.execute(`
      CREATE TABLE IF NOT EXISTS wallets (
        id VARCHAR(64) PRIMARY KEY,
        owner_type VARCHAR(32) DEFAULT 'CUSTOMER',
        owner_id VARCHAR(64) NOT NULL UNIQUE,
        balance NUMERIC(10, 2) DEFAULT 450.00,
        promo_balance NUMERIC(10, 2) DEFAULT 150.00,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // 13. wallet_transactions
    await this.execute(`
      CREATE TABLE IF NOT EXISTS wallet_transactions (
        id VARCHAR(64) PRIMARY KEY,
        wallet_id VARCHAR(64) NOT NULL,
        debit_credit VARCHAR(16) NOT NULL,
        amount NUMERIC(10, 2) NOT NULL,
        type VARCHAR(32) NOT NULL,
        title VARCHAR(128) NOT NULL,
        subtitle VARCHAR(256),
        reference VARCHAR(128),
        status VARCHAR(32) DEFAULT 'COMPLETED',
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // 14. payouts
    await this.execute(`
      CREATE TABLE IF NOT EXISTS payouts (
        id VARCHAR(64) PRIMARY KEY,
        driver_id VARCHAR(64) NOT NULL,
        amount NUMERIC(10, 2) NOT NULL,
        status VARCHAR(32) DEFAULT 'COMPLETED',
        provider_ref VARCHAR(128),
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // 15. promocodes
    await this.execute(`
      CREATE TABLE IF NOT EXISTS promocodes (
        id VARCHAR(64) PRIMARY KEY,
        code VARCHAR(64) NOT NULL UNIQUE,
        rule TEXT NOT NULL,
        validity TEXT NOT NULL,
        usage_limit INT DEFAULT 1000,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // 16. ratings
    await this.execute(`
      CREATE TABLE IF NOT EXISTS ratings (
        id VARCHAR(64) PRIMARY KEY,
        ride_id VARCHAR(64) NOT NULL,
        rater_id VARCHAR(64) NOT NULL,
        target_id VARCHAR(64) NOT NULL,
        score INT NOT NULL,
        feedback_tags TEXT DEFAULT '[]',
        comment TEXT,
        tip_amount NUMERIC(10, 2) DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // 17. support_tickets
    await this.execute(`
      CREATE TABLE IF NOT EXISTS support_tickets (
        id VARCHAR(64) PRIMARY KEY,
        user_id VARCHAR(64) NOT NULL,
        ride_id VARCHAR(64),
        priority VARCHAR(32) DEFAULT 'MEDIUM',
        category VARCHAR(64) NOT NULL,
        description TEXT,
        status VARCHAR(32) DEFAULT 'OPEN',
        assignee VARCHAR(64) DEFAULT 'AI_BOT_SUPPORT',
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // 18. sos_events
    await this.execute(`
      CREATE TABLE IF NOT EXISTS sos_events (
        id VARCHAR(64) PRIMARY KEY,
        ride_id VARCHAR(64) NOT NULL,
        user_id VARCHAR(64) NOT NULL,
        location TEXT NOT NULL,
        status VARCHAR(32) DEFAULT 'ACTIVE',
        escalation VARCHAR(64) DEFAULT 'POLICE_HELP_112',
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // 18b. emergency_contacts
    await this.execute(`
      CREATE TABLE IF NOT EXISTS emergency_contacts (
        id VARCHAR(64) PRIMARY KEY,
        user_id VARCHAR(64) NOT NULL,
        name VARCHAR(128) NOT NULL,
        phone VARCHAR(32) NOT NULL,
        relationship VARCHAR(64) DEFAULT 'Family',
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // 19. pricing_rules
    await this.execute(`
      CREATE TABLE IF NOT EXISTS pricing_rules (
        id VARCHAR(64) PRIMARY KEY,
        city VARCHAR(64) DEFAULT 'DELHI_NCR',
        zone VARCHAR(64) DEFAULT 'NCR_ALL',
        category VARCHAR(64) NOT NULL,
        version VARCHAR(32) DEFAULT 'v1.0.0',
        parameters TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // 20. fraud_events
    await this.execute(`
      CREATE TABLE IF NOT EXISTS fraud_events (
        id VARCHAR(64) PRIMARY KEY,
        user_id VARCHAR(64),
        driver_id VARCHAR(64),
        rule VARCHAR(128) NOT NULL,
        score NUMERIC(5, 2) NOT NULL,
        status VARCHAR(32) DEFAULT 'FLAGGED',
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // 21. audit_logs
    await this.execute(`
      CREATE TABLE IF NOT EXISTS audit_logs (
        id VARCHAR(64) PRIMARY KEY,
        actor VARCHAR(64) NOT NULL,
        action VARCHAR(128) NOT NULL,
        entity VARCHAR(64) NOT NULL,
        before_state TEXT,
        after_state TEXT,
        timestamp TEXT DEFAULT CURRENT_TIMESTAMP
      );
    `);

    this.logger.log('All 21 Database Tables Verified & Initialized!');
  }

  private async seedInitialData() {
    // Seed default user and profile if not existing
    const existingUser = await this.query(`SELECT * FROM users WHERE id = 'cust_123'`);
    if (!existingUser || existingUser.length === 0) {
      await this.execute(
        `INSERT INTO users (id, phone, email, status) VALUES ('cust_123', '+91 98765 43210', 'john.doe@example.com', 'ACTIVE')`
      );
      await this.execute(
        `INSERT INTO user_profiles (user_id, name, photo, gender, preferences) VALUES ('cust_123', 'John Doe', 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde', 'Male', '{"memberTier":"GOLD"}')`
      );
      await this.execute(
        `INSERT INTO wallets (id, owner_type, owner_id, balance, promo_balance) VALUES ('wallet_123', 'CUSTOMER', 'cust_123', 450.00, 150.00)`
      );
    }
  }

  async execute(sql: string, params: any[] = []): Promise<any> {
    if (this.isPostgres && this.pgClient) {
      return this.pgClient.query(sql, params);
    }

    return new Promise((resolve, reject) => {
      if (!this.sqliteDb) return resolve(null);
      this.sqliteDb.run(sql, params, function (err) {
        if (err) reject(err);
        else resolve({ lastID: this.lastID, changes: this.changes });
      });
    });
  }

  async query(sql: string, params: any[] = []): Promise<any[]> {
    if (this.isPostgres && this.pgClient) {
      const res = await this.pgClient.query(sql, params);
      return res.rows;
    }

    return new Promise((resolve, reject) => {
      if (!this.sqliteDb) return resolve([]);
      this.sqliteDb.all(sql, params, (err, rows) => {
        if (err) reject(err);
        else resolve(rows || []);
      });
    });
  }

  // Insert user when user inputs phone number during registration
  async saveUserRegistration(phone: string, email?: string, name?: string) {
    const userId = `user_${Date.now()}`;
    const cleanPhone = phone.trim();
    
    // Check if user already exists with this phone
    const existing = await this.query(`SELECT * FROM users WHERE phone = ?`, [cleanPhone]);
    if (existing && existing.length > 0) {
      const user = existing[0];
      if (name || email) {
        await this.execute(
          `UPDATE user_profiles SET name = COALESCE(?, name) WHERE user_id = ?`,
          [name || 'User', user.id]
        );
      }
      await this.execute(
        `INSERT INTO audit_logs (id, actor, action, entity, after_state) VALUES (?, ?, ?, ?, ?)`,
        [`audit_${Date.now()}`, user.id, 'USER_LOGIN', 'users', JSON.stringify({ phone: cleanPhone })]
      );
      return user;
    }

    // Insert new user
    await this.execute(
      `INSERT INTO users (id, phone, email, status) VALUES (?, ?, ?, ?)`,
      [userId, cleanPhone, email || `${cleanPhone}@gorush.app`, 'ACTIVE']
    );

    // Insert user_profile
    await this.execute(
      `INSERT INTO user_profiles (user_id, name, photo, gender) VALUES (?, ?, ?, ?)`,
      [userId, name || 'New Rider', 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde', 'Male']
    );

    // Create wallet for user
    await this.execute(
      `INSERT INTO wallets (id, owner_type, owner_id, balance, promo_balance) VALUES (?, ?, ?, ?, ?)`,
      [`wallet_${userId}`, 'CUSTOMER', userId, 100.00, 50.00]
    );

    // Insert audit log
    await this.execute(
      `INSERT INTO audit_logs (id, actor, action, entity, after_state) VALUES (?, ?, ?, ?, ?)`,
      [`audit_${Date.now()}`, userId, 'USER_REGISTERED', 'users', JSON.stringify({ phone: cleanPhone, email })]
    );

    this.logger.log(`New user registered and persisted to Database: ID=${userId}, Phone=${cleanPhone}`);
    return { id: userId, phone: cleanPhone, email: email || `${cleanPhone}@gorush.app` };
  }

  // Full Registration with Password & DB Persistence
  async registerUserWithPassword(name: string, email: string, phone: string, passwordHash: string) {
    const cleanPhone = phone.trim();
    const cleanEmail = email.trim().toLowerCase();

    // Check if user exists
    const existing = await this.query(`SELECT * FROM users WHERE phone = ? OR email = ?`, [cleanPhone, cleanEmail]);
    if (existing && existing.length > 0) {
      throw new Error('USER_EXISTS: An account with this phone number or email already exists. Please login.');
    }

    const userId = `user_${Date.now()}`;

    // Insert user record
    await this.execute(
      `INSERT INTO users (id, phone, email, password_hash, status) VALUES (?, ?, ?, ?, ?)`,
      [userId, cleanPhone, cleanEmail, passwordHash, 'ACTIVE']
    );

    // Insert user profile record
    await this.execute(
      `INSERT INTO user_profiles (user_id, name, photo, gender, preferences) VALUES (?, ?, ?, ?, ?)`,
      [userId, name.trim(), 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde', 'Male', '{"memberTier":"GOLD"}']
    );

    // Create wallet for user
    await this.execute(
      `INSERT INTO wallets (id, owner_type, owner_id, balance, promo_balance) VALUES (?, ?, ?, ?, ?)`,
      [`wallet_${userId}`, 'CUSTOMER', userId, 450.00, 150.00]
    );

    // Audit Log
    await this.execute(
      `INSERT INTO audit_logs (id, actor, action, entity, after_state) VALUES (?, ?, ?, ?, ?)`,
      [`audit_${Date.now()}`, userId, 'USER_REGISTERED_WITH_PASSWORD', 'users', JSON.stringify({ phone: cleanPhone, email: cleanEmail, name })]
    );

    this.logger.log(`New user account registered in Database: ID=${userId}, Name=${name}, Phone=${cleanPhone}`);

    return {
      id: userId,
      name,
      email: cleanEmail,
      phoneNumber: cleanPhone,
    };
  }

  // Password Login with DB Fetch
  async loginWithPassword(identifier: string, passwordHash: string) {
    const clean = identifier.trim().toLowerCase();

    const users = await this.query(
      `SELECT u.*, p.name, p.photo, p.gender, p.preferences FROM users u LEFT JOIN user_profiles p ON u.id = p.user_id WHERE u.phone = ? OR u.email = ?`,
      [clean, clean]
    );

    if (!users || users.length === 0) {
      throw new Error('USER_NOT_FOUND: No account found with this phone number or email.');
    }

    const user = users[0];

    if (user.password_hash && user.password_hash !== passwordHash) {
      throw new Error('INVALID_PASSWORD: Password is incorrect. Please try again.');
    }

    // Audit log
    await this.execute(
      `INSERT INTO audit_logs (id, actor, action, entity, after_state) VALUES (?, ?, ?, ?, ?)`,
      [`audit_${Date.now()}`, user.id, 'USER_LOGIN_PASSWORD', 'users', JSON.stringify({ identifier: clean })]
    );

    this.logger.log(`User logged in from Database: ID=${user.id}, Name=${user.name}`);

    return {
      id: user.id,
      name: user.name || 'User',
      email: user.email,
      phoneNumber: user.phone,
      photo: user.photo,
      gender: user.gender,
    };
  }
}

