# Smart Calendar & Reminder Application

A cross-platform web app for smart scheduling, reminders, and campus management, supporting Arabic (RTL), English, Chinese, and French.

## Features

- User registration, login, and profile management
- Multi-language support (Arabic, English, Chinese, French)
- Create, edit, and view calendar events and reminders
- Push notifications and web alerts
- Search and filter events
- Responsive web interface (mobile-friendly)
- Admin dashboard for managing users, locations, face recognition, volunteers, colleges, and more

## Technology Stack

- **Backend:** Java Servlets, JSP, Jetty/Tomcat
- **Frontend:** JSP, CSS, JavaScript
- **Database:** MySQL (H2 for testing)
- **Languages:** Arabic (RTL), English, Chinese, French

## Project Structure

```
Smart calendar/
├── src/main/java/com/smartcalendar/
│   ├── servlets/          # Servlet controllers
│   ├── models/            # Data models
│   ├── utils/             # Utility classes
│   └── filters/           # Language/session filters
├── src/main/webapp/
│   ├── WEB-INF/           # Web config, JSP fragments
│   ├── css/               # Stylesheets
│   ├── js/                # JavaScript files
│   ├── images/            # Static images
│   └── *.jsp              # JSP pages (public/admin)
├── src/main/resources/    # Language properties files
├── database/              # SQL scripts
├── lib/                   # External libraries
└── pom.xml                # Maven build file
```

## Setup Instructions

1. Install Java 11+ and Maven
2. Setup MySQL and run scripts in `/database/`:
		- `create_database.sql`
		- `create_tables.sql`
		- `insert_sample_data.sql`
3. Update database connection settings in `src/main/resources` if needed
4. Place MySQL JDBC driver in `/lib/` (or use Maven dependency)
5. Build and run with Jetty:
		```sh
		mvn jetty:run -Djetty.port=8082
		```
6. Access the app at [http://localhost:8082/smart-calendar](http://localhost:8082/smart-calendar)

## Admin Features

- Face ID enrollments and recognition windows
- Manage users, volunteers, colleges, departments, and locations
- CST Shining Team management
- Event and reminder creation
- Multi-language admin tools

## Language Support

- Switch language via dropdown or URL parameter, e.g.:
	```
	http://localhost:8082/smart-calendar/important-locations.jsp?lang=ar
	```

## Development Notes

- JSTL scope is set to `provided` for Jetty; Tomcat uses `compile`
- Responsive design for desktop and mobile
- All major admin pages are internationalized

## License

MIT (or specify your license)