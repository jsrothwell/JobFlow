# JobFlow - macOS Job Tracking Application

A beautiful, native macOS application for tracking job applications built with SwiftUI.

## Features

- 🎨 Modern dark theme with liquid glass UI effects
- 📱 Native macOS design with SF Pro typography
- 🔍 Search and filter job applications
- ➕ Add new job applications with comprehensive form
- ✏️ Edit existing applications
- 🗑️ Delete applications
- 🔄 Update application status (Applied, Interviewing, Offer, Rejected, Accepted)
- 📊 Multiple view modes:
  - **List View**: Traditional list with detailed job information
  - **Timeline View**: Chronological timeline of all applications
  - **Kanban Board**: Drag-and-drop board organized by status
- ✨ Smooth animations and transitions
- 💼 Track application status, salary, location, description, and notes
- 🎯 Context menus for quick actions
- 📅 Date tracking for each application

## Requirements

- macOS 14.0 (Sonoma) or later
- Xcode 15.0 or later
- Swift 5.9 or later

## Installation & Build Instructions

### Option 1: Open in Xcode (Recommended)

1. Download and extract the project folder
2. Double-click `JobFlow.xcodeproj` to open it in Xcode
3. Wait for Xcode to index the project
4. Select your development team in the Signing & Capabilities tab (if building for distribution)
5. Press `Cmd + R` to build and run the application

### Option 2: Build from Command Line

```bash
cd /path/to/JobFlow
xcodebuild -project JobFlow.xcodeproj -scheme JobFlow -configuration Debug build
```

The built application will be located in:
`DerivedData/JobFlow/Build/Products/Debug/JobFlow.app`

## Project Structure

```
JobFlow/
├── JobFlow.xcodeproj/
│   └── project.pbxproj          # Xcode project configuration
├── JobFlow/
│   ├── JobFlowApp.swift         # Main app entry point & data store
│   ├── ContentView.swift        # Root view with navigation
│   ├── SidebarView.swift        # Left sidebar with job list
│   ├── DetailView.swift         # Job details view (List mode)
│   ├── TimelineView.swift       # Timeline view of applications
│   ├── KanbanView.swift         # Kanban board view
│   ├── JobFormView.swift        # Add/Edit job form
│   ├── JobApplication.swift     # Data models
│   ├── Assets.xcassets/         # App icons and assets
│   └── JobFlow.entitlements     # App permissions
└── README.md                     # This file
```

## Usage

### Adding a New Job Application

1. Click the **+** button in the sidebar header
2. Fill in the job details:
   - Job Title (required)
   - Company (required)
   - Status (Applied, Interviewing, Offer, Rejected, Accepted)
   - Date Applied
   - Salary Range
   - Location
   - Description
   - Notes
3. Click "Add Application"

### Editing an Application

**Method 1 - Context Menu:**
- Right-click on any job in the list
- Select "Edit"

**Method 2 - Detail View:**
- Select a job from the list
- Click the "Edit" button in the detail view

### Changing Application Status

**Method 1 - Detail View:**
- Select a job
- Click "Update Status" dropdown
- Choose new status

**Method 2 - Kanban Board:**
- Switch to Kanban view
- Click the "..." menu on any card
- Select new status

### Deleting an Application

**Method 1 - Context Menu:**
- Right-click on any job
- Select "Delete"

**Method 2 - Detail View:**
- Select a job
- Click the "Delete" button

### Switching Views

Use the view tabs in the sidebar header:
- **List**: Traditional list view with detailed information panel
- **Timeline**: Chronological timeline of all applications
- **Kanban**: Status-based board with cards

## Customization

### Sample Data

The app comes with 5 sample job applications. You can:
- Edit them to match your real applications
- Delete them and start fresh
- Keep them as examples

### Adding Custom Jobs

Simply click the + button and enter your job details. All fields except Title and Company are optional.

### Status Categories

The app includes 5 status categories:
- **Applied** (Green) - Initial application submitted
- **Interviewing** (Blue) - In the interview process
- **Offer** (Orange) - Offer received
- **Rejected** (Red) - Application rejected
- **Accepted** (Purple) - Offer accepted

## Design Philosophy

JobFlow follows Apple's Human Interface Guidelines with:

- **Native macOS Window**: Standard traffic light controls and title bar
- **SF Pro Typography**: Apple's system font throughout
- **Dark Theme**: Optimized for reduced eye strain
- **Liquid Glass Effects**: Subtle frosted glass backgrounds using backdrop filters
- **Accessibility**: High contrast text and clear visual hierarchy
- **Smooth Interactions**: Native SwiftUI animations and transitions

## Known Limitations

- Data is stored in memory only (resets on app restart)
- No export/import functionality yet
- No iCloud sync
- No notifications or reminders

## Future Enhancements

- [ ] Data persistence with SwiftData or Core Data
- [ ] Export to CSV/PDF
- [ ] Calendar integration for interview scheduling
- [ ] Notifications and reminders
- [ ] iCloud sync across devices
- [ ] Contact management for recruiters
- [ ] Document attachments (resume, cover letter)
- [ ] Interview notes and feedback tracking
- [ ] Salary comparison charts
- [ ] Application statistics dashboard

## License

This project is provided as-is for educational and personal use.

## Support

For issues or questions about building the project, please ensure:
1. You're using Xcode 15.0 or later
2. macOS 14.0 (Sonoma) or later is installed
3. The project files are not corrupted during extraction

---

Built with ❤️ using SwiftUI
