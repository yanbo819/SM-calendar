-- Insert sample data for Smart Calendar application
USE smart_calendar;

-- Insert default categories
INSERT INTO categories (category_name, category_color, is_system_category) VALUES
('Activity', '#28a745', TRUE),
('Class', '#007bff', TRUE),
('Meeting', '#dc3545', TRUE),
('Personal', '#6f42c1', TRUE),
('Work', '#fd7e14', TRUE),
('Other', '#6c757d', TRUE);

-- Insert language resources for English
INSERT INTO language_resources (language_code, resource_key, resource_value) VALUES
('en', 'app.title', 'SM Calendar'),
('en', 'login.title', 'Login'),
('en', 'login.email', 'Email Address'),
('en', 'login.submit', 'Login'),
('en', 'login.forgot_password', 'Forgot Password?'),
('en', 'login.no_account', 'Don''t have an account?'),
('en', 'login.register_here', 'Register here'),
('en', 'register.title', 'Register'),
('en', 'register.full_name', 'Full Name'),
('en', 'register.email', 'Email Address'),
('en', 'register.phone', 'Phone Number'),
('en', 'register.password', 'Password'),
('en', 'register.confirm_password', 'Confirm Password'),
('en', 'register.language', 'Preferred Language'),
('en', 'register.submit', 'Register'),
('en', 'register.have_account', 'Already have an account?'),
('en', 'register.login_here', 'Login here'),
('en', 'dashboard.welcome', 'Welcome'),
('en', 'dashboard.create_calendar', 'Create New Calendar'),
('en', 'dashboard.create_reminder', 'Create New Reminder'),
('en', 'dashboard.view_events', 'View All Events'),
('en', 'dashboard.search_events', 'Search Events'),
('en', 'event.title', 'Title'),
('en', 'event.category', 'Category'),
('en', 'event.subject', 'Subject'),
('en', 'event.date', 'Date'),
('en', 'event.time', 'Time'),
('en', 'event.duration', 'Duration (minutes)'),
('en', 'event.location', 'Location'),
('en', 'event.notes', 'Notes'),
('en', 'event.reminder', 'Reminder'),
('en', 'event.save', 'Save Event'),
('en', 'event.cancel', 'Cancel'),
('en', 'reminder.5min', '5 minutes before'),
('en', 'reminder.15min', '15 minutes before'),
('en', 'reminder.30min', '30 minutes before'),
('en', 'reminder.1hour', '1 hour before'),
('en', 'language.english', 'English'),
('en', 'language.arabic', 'Arabic'),
('en', 'language.chinese', 'Chinese'),
('en', 'nav.logout', 'Logout'),
('en', 'nav.profile', 'Profile'),
('en', 'nav.settings', 'Settings');

-- Insert language resources for Arabic
INSERT INTO language_resources (language_code, resource_key, resource_value) VALUES
('ar', 'app.title', 'SM Calendar'),
('ar', 'login.title', 'تسجيل الدخول'),
('ar', 'login.email', 'عنوان البريد الإلكتروني'),
('ar', 'login.submit', 'تسجيل الدخول'),
('ar', 'login.forgot_password', 'نسيت كلمة المرور؟'),
('ar', 'login.no_account', 'ليس لديك حساب؟'),
('ar', 'login.register_here', 'سجل هنا'),
('ar', 'register.title', 'التسجيل'),
('ar', 'register.full_name', 'الاسم الكامل'),
('ar', 'register.email', 'عنوان البريد الإلكتروني'),
('ar', 'register.phone', 'رقم الهاتف'),
('ar', 'register.password', 'كلمة المرور'),
('ar', 'register.confirm_password', 'تأكيد كلمة المرور'),
('ar', 'register.language', 'اللغة المفضلة'),
('ar', 'register.submit', 'التسجيل'),
('ar', 'register.have_account', 'لديك حساب بالفعل؟'),
('ar', 'register.login_here', 'سجل دخولك هنا'),
('ar', 'dashboard.welcome', 'مرحباً'),
('ar', 'dashboard.create_calendar', 'إنشاء تقويم جديد'),
('ar', 'dashboard.create_reminder', 'إنشاء تذكير جديد'),
('ar', 'dashboard.view_events', 'عرض جميع الأحداث'),
('ar', 'dashboard.search_events', 'البحث في الأحداث'),
('ar', 'event.title', 'العنوان'),
('ar', 'event.category', 'الفئة'),
('ar', 'event.subject', 'الموضوع'),
('ar', 'event.date', 'التاريخ'),
('ar', 'event.time', 'الوقت'),
('ar', 'event.duration', 'المدة (بالدقائق)'),
('ar', 'event.location', 'الموقع'),
('ar', 'event.notes', 'الملاحظات'),
('ar', 'event.reminder', 'التذكير'),
('ar', 'event.save', 'حفظ الحدث'),
('ar', 'event.cancel', 'إلغاء'),
('ar', 'reminder.5min', 'قبل 5 دقائق'),
('ar', 'reminder.15min', 'قبل 15 دقيقة'),
('ar', 'reminder.30min', 'قبل 30 دقيقة'),
('ar', 'reminder.1hour', 'قبل ساعة واحدة'),
('ar', 'language.english', 'الإنجليزية'),
('ar', 'language.arabic', 'العربية'),
('ar', 'language.chinese', 'الصينية'),
('ar', 'nav.logout', 'تسجيل الخروج'),
('ar', 'nav.profile', 'الملف الشخصي'),
('ar', 'nav.settings', 'الإعدادات');

-- Insert language resources for Chinese
INSERT INTO language_resources (language_code, resource_key, resource_value) VALUES
('zh', 'app.title', 'SM Calendar'),
('zh', 'login.title', '登录'),
('zh', 'login.email', '邮箱地址'),
('zh', 'login.submit', '登录'),
('zh', 'login.forgot_password', '忘记密码？'),
('zh', 'login.no_account', '没有账户？'),
('zh', 'login.register_here', '在这里注册'),
('zh', 'register.title', '注册'),
('zh', 'register.full_name', '姓名'),
('zh', 'register.email', '邮箱地址'),
('zh', 'register.phone', '电话号码'),
('zh', 'register.password', '密码'),
('zh', 'register.confirm_password', '确认密码'),
('zh', 'register.language', '首选语言'),
('zh', 'register.submit', '注册'),
('zh', 'register.have_account', '已经有账户？'),
('zh', 'register.login_here', '在这里登录'),
('zh', 'dashboard.welcome', '欢迎'),
('zh', 'dashboard.create_calendar', '创建新日历'),
('zh', 'dashboard.create_reminder', '创建新提醒'),
('zh', 'dashboard.view_events', '查看所有事件'),
('zh', 'dashboard.search_events', '搜索事件'),
('zh', 'event.title', '标题'),
('zh', 'event.category', '类别'),
('zh', 'event.subject', '主题'),
('zh', 'event.date', '日期'),
('zh', 'event.time', '时间'),
('zh', 'event.duration', '持续时间（分钟）'),
('zh', 'event.location', '地点'),
('zh', 'event.notes', '备注'),
('zh', 'event.reminder', '提醒'),
('zh', 'event.save', '保存事件'),
('zh', 'event.cancel', '取消'),
('zh', 'reminder.5min', '提前5分钟'),
('zh', 'reminder.15min', '提前15分钟'),
('zh', 'reminder.30min', '提前30分钟'),
('zh', 'reminder.1hour', '提前1小时'),
('zh', 'language.english', '英语'),
('zh', 'language.arabic', '阿拉伯语'),
('zh', 'language.chinese', '中文'),
('zh', 'nav.logout', '注销'),
('zh', 'nav.profile', '个人资料'),
('zh', 'nav.settings', '设置');

-- Insert a demo user (password is 'demo123' hashed with bcrypt)
INSERT INTO users (email, phone_number, full_name, password_hash, preferred_language) VALUES
('demo@smartcalendar.com', '+1234567890', 'Demo User', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'en');

-- Get the demo user ID for creating sample data
SET @demo_user_id = LAST_INSERT_ID();

-- Insert sample subjects for demo user
INSERT INTO subjects (user_id, subject_name) VALUES
(@demo_user_id, 'Project Meeting'),
(@demo_user_id, 'Java Programming'),
(@demo_user_id, 'Database Design'),
(@demo_user_id, 'Team Standup'),
(@demo_user_id, 'Client Presentation');

-- Insert sample events for demo user
INSERT INTO events (user_id, category_id, subject_id, title, description, event_date, event_time, duration_minutes, location, notes, reminder_minutes_before) VALUES
(@demo_user_id, 3, 1, 'Weekly Team Meeting', 'Discuss project progress and upcoming tasks', CURDATE() + INTERVAL 1 DAY, '10:00:00', 60, 'Conference Room A', 'Bring project status report', 15),
(@demo_user_id, 2, 2, 'Java Development Session', 'Continue working on Smart Calendar features', CURDATE() + INTERVAL 2 DAY, '14:00:00', 120, 'Office Desk', 'Focus on authentication module', 30),
(@demo_user_id, 1, NULL, 'Gym Workout', 'Cardio and strength training', CURDATE() + INTERVAL 1 DAY, '18:00:00', 90, 'Local Gym', 'Remember to bring water bottle', 15);

-- Create indexes for better performance
CREATE INDEX idx_events_datetime ON events(event_date, event_time);
CREATE INDEX idx_notifications_pending ON notifications(is_sent, scheduled_time);
CREATE INDEX idx_users_email_active ON users(email, is_active);