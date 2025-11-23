/**
 * Smart Calendar Notification System
 * Handles web notifications and reminders
 */

class NotificationManager {
    constructor() {
        this.notificationPermission = Notification.permission;
        this.reminderInterval = null;
        this.activeNotifications = new Map();
        this.checkInterval = 60000; // Check every minute
        
        this.init();
    }
    
    /**
     * Initialize the notification system
     */
    init() {
        this.requestPermission();
        this.startReminderCheck();
        this.setupVisibilityListener();
    }
    
    /**
     * Request notification permission from user
     */
    async requestPermission() {
        if ('Notification' in window) {
            if (this.notificationPermission === 'default') {
                this.notificationPermission = await Notification.requestPermission();
            }
        }
    }
    
    /**
     * Start checking for upcoming reminders
     */
    startReminderCheck() {
        // Check immediately on load
        this.checkUpcomingReminders();
        
        // Then check every minute
        this.reminderInterval = setInterval(() => {
            this.checkUpcomingReminders();
        }, this.checkInterval);
    }
    
    /**
     * Stop reminder checking (when user logs out or page unloads)
     */
    stopReminderCheck() {
        if (this.reminderInterval) {
            clearInterval(this.reminderInterval);
            this.reminderInterval = null;
        }
    }
    
    /**
     * Check for upcoming events that need reminders
     */
    async checkUpcomingReminders() {
        try {
            const response = await fetch('api/upcoming-reminders', {
                method: 'GET',
                credentials: 'same-origin'
            });
            
            if (response.ok) {
                const reminders = await response.json();
                this.processReminders(reminders);
            }
        } catch (error) {
            console.error('Error fetching reminders:', error);
        }
    }
    
    /**
     * Process and show reminders
     */
    processReminders(reminders) {
        reminders.forEach(reminder => {
            const reminderKey = `${reminder.eventId}_${reminder.reminderTime}`;
            
            // Avoid duplicate notifications
            if (!this.activeNotifications.has(reminderKey)) {
                this.showReminder(reminder);
                this.activeNotifications.set(reminderKey, Date.now());
            }
        });
        
        // Clean up old notifications (older than 1 hour)
        this.cleanupOldNotifications();
    }
    
    /**
     * Show a reminder notification
     */
    showReminder(reminder) {
        if (this.notificationPermission === 'granted') {
            const options = {
                body: this.formatReminderBody(reminder),
                icon: 'images/calendar-icon.png',
                badge: 'images/calendar-badge.png',
                tag: `reminder_${reminder.eventId}`,
                requireInteraction: true,
                actions: [
                    {
                        action: 'view',
                        title: 'View Event'
                    },
                    {
                        action: 'dismiss',
                        title: 'Dismiss'
                    }
                ],
                data: {
                    eventId: reminder.eventId,
                    url: `event-details.jsp?id=${reminder.eventId}`
                }
            };
            
            const notification = new Notification(reminder.title, options);
            
            // Handle notification click
            notification.onclick = () => {
                window.focus();
                window.location.href = options.data.url;
                notification.close();
            };
            
            // Auto-close after 10 seconds if not interacted with
            setTimeout(() => {
                notification.close();
            }, 10000);
        } else {
            // Fallback to in-browser alert
            this.showInBrowserAlert(reminder);
        }
    }
    
    /**
     * Format reminder notification body
     */
    formatReminderBody(reminder) {
        let body = '';
        
        if (reminder.eventTime) {
            const eventTime = new Date(`1970-01-01T${reminder.eventTime}`);
            body += `Time: ${eventTime.toLocaleTimeString([], {hour: '2-digit', minute: '2-digit'})}\n`;
        }
        
        if (reminder.location) {
            body += `Location: ${reminder.location}\n`;
        }
        
        if (reminder.categoryName) {
            body += `Category: ${reminder.categoryName}\n`;
        }
        
        const minutesBefore = reminder.reminderMinutesBefore;
        if (minutesBefore > 0) {
            if (minutesBefore < 60) {
                body += `Reminder: ${minutesBefore} minutes before`;
            } else {
                const hours = Math.floor(minutesBefore / 60);
                const minutes = minutesBefore % 60;
                body += `Reminder: ${hours}h ${minutes}m before`;
            }
        }
        
        return body.trim();
    }
    
    /**
     * Show in-browser alert as fallback
     */
    showInBrowserAlert(reminder) {
        const alertDiv = document.createElement('div');
        alertDiv.className = 'notification-alert';
        alertDiv.innerHTML = `
            <div class="notification-content">
                <div class="notification-header">
                    <strong>${reminder.title}</strong>
                    <button class="notification-close" onclick="this.parentElement.parentElement.parentElement.remove()">×</button>
                </div>
                <div class="notification-body">
                    ${this.formatReminderBody(reminder).replace(/\n/g, '<br>')}
                </div>
                <div class="notification-actions">
                    <a href="event-details.jsp?id=${reminder.eventId}" class="btn btn-small btn-primary">View Event</a>
                    <button class="btn btn-small btn-secondary" onclick="this.parentElement.parentElement.parentElement.remove()">Dismiss</button>
                </div>
            </div>
        `;
        
        // Add to page
        document.body.appendChild(alertDiv);
        
        // Auto-remove after 10 seconds
        setTimeout(() => {
            if (alertDiv.parentElement) {
                alertDiv.remove();
            }
        }, 10000);
    }
    
    /**
     * Clean up old notifications from memory
     */
    cleanupOldNotifications() {
        const oneHourAgo = Date.now() - (60 * 60 * 1000);
        
        for (const [key, timestamp] of this.activeNotifications.entries()) {
            if (timestamp < oneHourAgo) {
                this.activeNotifications.delete(key);
            }
        }
    }
    
    /**
     * Setup page visibility listener to pause/resume notifications
     */
    setupVisibilityListener() {
        document.addEventListener('visibilitychange', () => {
            if (document.hidden) {
                // Page is hidden, notifications will still work
                console.log('Page hidden - notifications continue in background');
            } else {
                // Page is visible, check for any missed reminders
                console.log('Page visible - checking for missed reminders');
                this.checkUpcomingReminders();
            }
        });
        
        // Stop checking when page unloads
        window.addEventListener('beforeunload', () => {
            this.stopReminderCheck();
        });
    }
    
    /**
     * Show immediate notification (for testing or manual triggers)
     */
    showTestNotification() {
        if (this.notificationPermission === 'granted') {
            new Notification('Smart Calendar Test', {
                body: 'This is a test notification from Smart Calendar',
                icon: 'images/calendar-icon.png'
            });
        } else {
            alert('Test notification: Smart Calendar is working!');
        }
    }
    
    /**
     * Get notification permission status
     */
    getPermissionStatus() {
        return this.notificationPermission;
    }
}

// Utility functions for date/time handling
const NotificationUtils = {
    /**
     * Check if a reminder should be shown now
     */
    shouldShowReminder(eventDateTime, reminderMinutesBefore) {
        const now = new Date();
        const eventTime = new Date(eventDateTime);
        const reminderTime = new Date(eventTime.getTime() - (reminderMinutesBefore * 60 * 1000));
        
        // Show if reminder time is within the last minute
        const timeDiff = Math.abs(now.getTime() - reminderTime.getTime());
        return timeDiff <= 60000; // Within 1 minute
    },
    
    /**
     * Format event date/time for notifications
     */
    formatEventDateTime(eventDate, eventTime) {
        const dateObj = new Date(`${eventDate}T${eventTime}`);
        return dateObj.toLocaleString();
    },
    
    /**
     * Calculate minutes until event
     */
    getMinutesUntilEvent(eventDate, eventTime) {
        const now = new Date();
        const eventDateTime = new Date(`${eventDate}T${eventTime}`);
        return Math.floor((eventDateTime.getTime() - now.getTime()) / (1000 * 60));
    }
};

// Initialize notification manager when DOM is loaded
let notificationManager;

document.addEventListener('DOMContentLoaded', function() {
    // Only initialize if user is logged in (check for user data in session)
    if (document.body.dataset.userId) {
        notificationManager = new NotificationManager();
        
        // Add test notification button if in debug mode
        if (window.location.search.includes('debug=true')) {
            const testButton = document.createElement('button');
            testButton.textContent = 'Test Notification';
            testButton.className = 'btn btn-small';
            testButton.onclick = () => notificationManager.showTestNotification();
            testButton.style.position = 'fixed';
            testButton.style.top = '10px';
            testButton.style.right = '10px';
            testButton.style.zIndex = '9999';
            document.body.appendChild(testButton);
        }
    }
});

// Export for use in other scripts
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { NotificationManager, NotificationUtils };
}