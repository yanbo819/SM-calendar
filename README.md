# Smart Calendar & Reminder Application

A cross-platform smart calendar and reminder system with multi-language support (Arabic, English, Chinese).

## Features
- User Registration & Authentication
- Multi-language Support (Arabic, English, Chinese)
- Create Calendar Events & Reminders
- Push Notifications & Web Alerts
- Search & Filter Events
- Data Synchronization
- Responsive Web Interface

## Technology Stack
- **Backend**: Java Servlets, JSP
- **Frontend**: JSP, CSS, JavaScript
- **Database**: MySQL
- **Languages**: Arabic (RTL), English, Chinese

## Project Structure
```
Smart calendar/
├── src/main/java/com/smartcalendar/
│   ├── servlets/          # Servlet controllers
│   ├── models/            # Data models
│   └── utils/             # Utility classes
├── src/main/webapp/
│   ├── WEB-INF/           # Web configuration
│   ├── css/               # Stylesheets
│   ├── js/                # JavaScript files
│   ├── images/            # Static images
│   └── *.jsp              # JSP pages
├── src/main/resources/    # Language files
├── database/              # SQL scripts
└── lib/                   # External libraries
```

## Setup Instructions
1. Install Java 8+ and Apache Tomcat
2. Setup MySQL database using scripts in `/database/`
3. Place MySQL JDBC driver in `/lib/` folder
4. Deploy to Tomcat server
5. Access application at `http://localhost:8080/smart-calendar`

## Database Setup
Run the SQL scripts in order:
1. `create_database.sql`
2. `create_tables.sql`
3. `insert_sample_data.sql`