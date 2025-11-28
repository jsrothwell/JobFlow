# JobFlow - Quick Start Guide

## 🚀 Getting Started (60 seconds)

### Step 1: Open the Project
1. Download and extract `JobFlow-Complete.zip`
2. Double-click `JobFlow.xcodeproj`
3. Wait for Xcode to index (should be quick)

### Step 2: Build & Run
1. Press `Cmd + R` or click the ▶️ Play button
2. The app will launch in a native macOS window
3. You'll see 5 sample job applications already loaded

### Step 3: Try the Features
**Add your first job:**
- Click the **+** button in the top-left
- Fill in "Software Engineer" at "Google"
- Click "Add Application"

**Change a status:**
- Click on any job
- Click "Update Status"
- Choose "Interviewing"

**Switch views:**
- Click "Timeline" or "Kanban" tabs at the top
- See your jobs displayed differently

**Edit a job:**
- Right-click any job
- Select "Edit"
- Modify details and save

## 📱 What You'll See

### Main Interface
```
┌─────────────────────────────────────────────────────────┐
│ ⚫ ⚫ ⚫              JobFlow                              │
├─────────────┬───────────────────────────────────────────┤
│             │                                            │
│ Applications│                                            │
│             │                                            │
│ [+] button  │         Main Content Area                  │
│             │                                            │
│ List|Timeline|Kanban                                     │
│             │     (List View with job details)          │
│ [Search]    │     (Timeline of applications)            │
│             │     (Kanban board by status)              │
│ Job List:   │                                            │
│ • Director  │                                            │
│   Coinbase  │                                            │
│ • Designer  │                                            │
│   Stripe    │                                            │
│ • Lead UX   │                                            │
│   Airbnb    │                                            │
│             │                                            │
└─────────────┴───────────────────────────────────────────┘
```

## ⚡ Quick Actions

| Action | Shortcut/Method |
|--------|----------------|
| Add job | Click + button |
| Edit job | Right-click → Edit |
| Delete job | Right-click → Delete |
| Search | Type in search box |
| Switch view | Click List/Timeline/Kanban |
| Select job | Click on any job |
| Update status | Select job → Update Status |

## 🎯 Common Tasks

### Adding Multiple Jobs
1. Click + button
2. Enter first job details → "Add Application"
3. Repeat for each job
4. Use Tab key to quickly navigate between fields

### Organizing by Status
1. Switch to Kanban view
2. See jobs organized in columns
3. Use card menu (•••) to change status quickly
4. Watch cards move between columns

### Tracking Application Timeline
1. Switch to Timeline view
2. See when you applied for each job
3. Spot gaps in your application activity
4. Plan your next applications

### Searching Applications
1. Type company name or job title in search
2. Results filter instantly
3. Works across all views
4. Clear search to see all jobs

## 💡 Pro Tips

1. **Sample Data**: Feel free to delete the sample jobs or edit them to match your real applications

2. **Status Colors**: 
   - 🟢 Green = Applied (just sent)
   - 🔵 Blue = Interviewing (in process)
   - 🟠 Orange = Offer (received offer)
   - 🔴 Red = Rejected
   - 🟣 Purple = Accepted

3. **Notes Field**: Use this for:
   - Interview dates
   - Recruiter contact info
   - Salary negotiation notes
   - Follow-up reminders

4. **Best Practices**:
   - Update status immediately after changes
   - Add notes after each interview
   - Track salary ranges for comparison
   - Use description for job requirements

## 🛠️ Customization

### Adding More Jobs
The sample data shows you the format. Each job can have:
- **Title** (required) - The position name
- **Company** (required) - Company name
- **Status** - Current stage (5 options)
- **Date** - When you applied
- **Salary** - Expected range
- **Location** - Job location
- **Description** - Job details, requirements
- **Notes** - Your personal notes

### Status Categories
You can use the 5 built-in statuses:
1. **Applied** - Initial application sent
2. **Interviewing** - In interview process  
3. **Offer** - Offer received
4. **Rejected** - Not moving forward
5. **Accepted** - Offer accepted

## ⚠️ Important Notes

- **Data Persistence**: Currently, data only exists while the app is running. Closing the app will reset to sample data. Future version will add persistence.
- **Backups**: Export your data by taking screenshots or manually backing up for now
- **Window Size**: You can resize the window - the interface adapts

## 🎓 Learning More

### File Structure
- `JobFlowApp.swift` - Main app entry and data store
- `ContentView.swift` - Root view coordinator
- `SidebarView.swift` - Left sidebar with job list
- `DetailView.swift` - Job details panel (List view)
- `TimelineView.swift` - Timeline visualization
- `KanbanView.swift` - Kanban board
- `JobFormView.swift` - Add/Edit form
- `JobApplication.swift` - Data models

### Making Changes
Want to customize? All Swift files are well-commented. Start with:
- Colors: Search for "Color(red:" in any view file
- Fonts: Look for ".font(.system" calls
- Layout: Modify VStack/HStack arrangements

## 🐛 Troubleshooting

**App won't build?**
- Ensure you have macOS 14.0+ and Xcode 15.0+
- Clean build folder: Product → Clean Build Folder
- Restart Xcode

**Can't see the project files?**
- Make sure you opened `JobFlow.xcodeproj`, not the folder
- The project navigator should show on the left

**App crashes on launch?**
- Check console for errors
- Verify all files are present in the project

## 📞 Next Steps

1. ✅ Build and run the app
2. ✅ Add your real job applications
3. ✅ Try all three view modes
4. ✅ Customize the sample data
5. ✅ Explore the code
6. ✅ Consider adding features you want!

---

**You're ready to go! Press Cmd+R and start tracking your job applications.** 🚀
