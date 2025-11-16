# Timetable-to-Calendar (reference)

This folder is reserved for the upstream Python project "Timetable-to-Calendar" you shared.

How it fits here
- The web app now supports uploading either CSV or ICS files via the Upload Schedule page (`schedule-upload.jsp`).
- If you use the Python tool to convert your timetable into an `.ics` file, you can upload that `.ics` here and it will be imported into My Events (title, date/time, duration, location).

Notes
- The application includes a lightweight ICS importer tailored to common VEVENT fields: SUMMARY, DTSTART, DTEND, LOCATION.
- Recurrence rules (RRULE), exceptions, attendees, etc., are currently ignored.
- All‑day events (date only) are imported at 09:00 with a default 60‑minute duration.
- Default category for imported items is `Schedule`, reminder is 15 minutes before.

Optional (advanced)
- If you want to run the Python tool within this repository, place its source files under this folder and run it locally to generate `.ics`, then upload that `.ics` from the web UI.
- Python execution is not wired into the Java webapp runtime (to keep the server portable). The recommended flow is: run the Python converter locally → upload the resulting `.ics`.
