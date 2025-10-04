-- Smart Calendar - H2 Initialization (idempotent)

CREATE TABLE IF NOT EXISTS users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone_number VARCHAR(20),
    full_name VARCHAR(100) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    preferred_language VARCHAR(10) DEFAULT 'en',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

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

-- (No sample events inserted to avoid mismatched columns/user references)