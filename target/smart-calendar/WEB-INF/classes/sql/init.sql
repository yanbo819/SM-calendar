-- Smart Calendar - H2 Initialization (idempotent)

CREATE TABLE IF NOT EXISTS users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone_number VARCHAR(20),
    full_name VARCHAR(100) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) DEFAULT 'user',
    preferred_language VARCHAR(10) DEFAULT 'en',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Backfill role column if upgrading an existing database
ALTER TABLE users ADD COLUMN IF NOT EXISTS role VARCHAR(20) DEFAULT 'user';

CREATE TABLE IF NOT EXISTS categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    category_color VARCHAR(7) DEFAULT '#007bff',
    user_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS subjects (
    subject_id INT AUTO_INCREMENT PRIMARY KEY,
    subject_name VARCHAR(100) NOT NULL,
    user_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS events (
    event_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    category_id INT,
    subject_id INT,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    event_date DATE NOT NULL,
    event_time TIME,
    duration_minutes INT DEFAULT 60,
    location VARCHAR(255),
    notes TEXT,
    reminder_minutes_before INT DEFAULT 15,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE SET NULL,
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    event_id INT NOT NULL,
    user_id INT NOT NULL,
    message VARCHAR(500) NOT NULL,
    notification_time TIMESTAMP NOT NULL,
    is_sent BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (event_id) REFERENCES events(event_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Multiple reminders per event (optional, complements events.reminder_minutes_before)
CREATE TABLE IF NOT EXISTS event_reminders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    event_id INT NOT NULL,
    minutes_before INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (event_id) REFERENCES events(event_id) ON DELETE CASCADE
);

-- Simple WebAuthn demo storage (credential IDs only, demo purposes)
CREATE TABLE IF NOT EXISTS webauthn_credentials (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    credential_id VARCHAR(255) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Stored user face image + simple perceptual hash for demo recognition
CREATE TABLE IF NOT EXISTS user_faces (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    image BLOB,
    phash VARCHAR(64),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Face ID attempt audit log (captures location + success for register/verify actions)
CREATE TABLE IF NOT EXISTS faceid_attempts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    action VARCHAR(20) NOT NULL, -- 'register' or 'verify'
    latitude DOUBLE,
    longitude DOUBLE,
    success BOOLEAN,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Configurable Face Recognition time windows (admin editable)
CREATE TABLE IF NOT EXISTS face_config (
    id INT AUTO_INCREMENT PRIMARY KEY,
    day_of_week INT NOT NULL, -- 1=Mon .. 7=Sun
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Campus & local locations (gates, hospitals, immigration, etc.)
CREATE TABLE IF NOT EXISTS locations (
    location_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    category VARCHAR(40) NOT NULL, -- gate, hospital, immigration, other
    description TEXT,
    map_url VARCHAR(500),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- CST Shining Team departments
CREATE TABLE IF NOT EXISTS cst_departments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL UNIQUE,
    leader_name VARCHAR(150),
    leader_phone VARCHAR(40),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- CST Shining Team volunteers
CREATE TABLE IF NOT EXISTS cst_volunteers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    department_id INT NOT NULL,
    phone VARCHAR(40),
    student_id VARCHAR(40),
    passport_name VARCHAR(150),
    chinese_name VARCHAR(150),
    gender VARCHAR(20),
    nationality VARCHAR(100),
    photo_url VARCHAR(500),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (department_id) REFERENCES cst_departments(id) ON DELETE CASCADE
);

-- Seed initial departments if not present
MERGE INTO cst_departments (name, leader_name, leader_phone)
KEY(name)
VALUES 
('Accommodation Department','John Leader','+86 13800000001'),
('Academic Department','Alice Scholar','+86 13800000002');

CREATE TABLE IF NOT EXISTS language_resources (
    id INT AUTO_INCREMENT PRIMARY KEY,
    language_code VARCHAR(10) NOT NULL,
    resource_key VARCHAR(100) NOT NULL,
    resource_value TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(language_code, resource_key)
);

-- Seed: essential English strings used by JSPs
MERGE INTO language_resources (language_code, resource_key, resource_value)
KEY(language_code, resource_key)
VALUES
('en', 'app.title', 'Smart Calendar'),
('en', 'login.title', 'Login'),
('en', 'dashboard.welcome', 'Welcome'),
('en', 'nav.logout', 'Logout'),
('en', 'dashboard.search_events', 'Search events...'),
('en', 'dashboard.create_calendar', 'Create calendar'),
('en', 'dashboard.create_reminder', 'Create reminder'),
('en', 'dashboard.view_events', 'View events'),
('en', 'event.title', 'Title'),
('en', 'event.category', 'Category'),
('en', 'event.subject', 'Subject'),
('en', 'event.date', 'Date'),
('en', 'event.time', 'Time'),
('en', 'event.duration', 'Duration'),
('en', 'event.location', 'Location'),
('en', 'event.notes', 'Notes'),
('en', 'event.reminder', 'Reminder'),
('en', 'event.save', 'Save'),
('en', 'event.cancel', 'Cancel'),
('en', 'reminder.5min', '5 minutes before'),
('en', 'reminder.15min', '15 minutes before'),
('en', 'reminder.30min', '30 minutes before'),
('en', 'reminder.1hour', '1 hour before');

-- Optional: a few global categories for convenience
MERGE INTO categories (category_name, category_color)
KEY(category_name)
VALUES
('Work', '#dc3545'),
('Personal', '#28a745'),
('Education', '#007bff');

-- Seed Face Recognition windows (Mon & Wed 08:00–12:00 and 14:00–17:00)
MERGE INTO face_config (day_of_week, start_time, end_time)
KEY(day_of_week, start_time, end_time)
VALUES
(1, TIME '08:00:00', TIME '12:00:00'),
(1, TIME '14:00:00', TIME '17:00:00'),
(3, TIME '08:00:00', TIME '12:00:00'),
(3, TIME '14:00:00', TIME '17:00:00');

-- Seed locations (gates)
MERGE INTO locations (name, category, description, map_url)
KEY(name)
VALUES
('Zhejiang Normal University - Southeast Gate', 'gate', '25 meters northwest of the intersection of the auxiliary road of North Second Ring Road West and Shida Street in Wucheng District, Jinhua City, Zhejiang Province', 'https://surl.amap.com/23w6dMgN1y03n'),
('Zhejiang Normal University - North Gate', 'gate', '74 meters west of the intersection of Beimen Street and Wayun Road, Wucheng District, Jinhua City, Zhejiang Province.', 'https://surl.amap.com/299RHNjj3feF');

-- Seed locations (hospitals)
MERGE INTO locations (name, category, description, map_url)
KEY(name)
VALUES
('Jinhua Central Hospital', 'hospital', 'No. 71 Mingyue Street, Wucheng District, Jinhua City, Zhejiang Province', 'https://map.wap.qq.com/online/h5-map-share/line.html?type=drive&cond=0&startLat=29.309060&startLng=120.089318&endLat=29.105549&endLng=119.659163&key=%E6%88%91%E7%9A%84%E4%BD%8D%E7%BD%AE%7C%7C%E9%87%91%E5%8D%8E%E5%B8%82%E4%B8%AD%E5%BF%83%E5%8C%BB%E9%99%A2'),
('Jinhua International Travel Health Care Center', 'hospital', 'East Auxiliary Building, No. 1000 Songlian Road, Jindong District, Jinhua City, Zhejiang Province', 'https://map.wap.qq.com/online/h5-map-share/line.html?type=drive&cond=0&startLat=29.309053&startLng=120.089323&endLat=29.094057&endLng=119.692297&key=%E6%88%91%E7%9A%84%E4%BD%8D%E7%BD%AE%7C%7C%E9%87%91%E5%8D%8E%E5%9B%BD%E9%99%85%E6%97%85%E8%A1%8C%E5%8D%AB%E7%94%9F%E4%BF%9D%E5%81%A5%E4%B8%AD%E5%BF%83');

-- Seed locations (immigration)
MERGE INTO locations (name, category, description, map_url)
KEY(name)
VALUES
('Jinhua Immigration', 'immigration', 'No. 1055 Bayi North Street, Wucheng District, Jinhua City, Zhejiang Province (50 meters to the left of the main gate of Jinhua Municipal Public Security Bureau)', 'https://map.wap.qq.com/online/h5-map-share/line.html?type=drive&cond=0&startLat=29.309043&startLng=120.089337&endLat=29.117105&endLng=119.653716&key=%E6%88%91%E7%9A%84%E4%BD%8D%E7%BD%AE%7C%7C%E9%87%91%E5%8D%8E%E5%B8%82%E5%85%AC%E5%AE%89%E5%B1%80%E5%87%BA%E5%85%A5%E5%A2%83%E7%AE%A1%E7%90%86%E5%B1%80');

-- (No sample events inserted to avoid mismatched columns/user references)