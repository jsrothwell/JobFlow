# JobFlow v5.0 - Sankey Flow Diagram & Conversion Funnel 📊

## 🎉 Major New Feature: Application Flow Visualization

### ✨ What's New in v5.0

**Sankey Diagram / Conversion Funnel:**
- ✅ **New "Path" view** - Visualize how far applications progressed
- ✅ **Flow diagram** - See applications flow from Applied → Interviewing → Offered → Accepted
- ✅ **Conversion rates** - Automatic calculation of interview rate, offer rate, acceptance rate
- ✅ **Export to PNG** - Save your funnel visualization as high-res image
- ✅ **Color-coded flows** - Each stage has its own color
- ✅ **Professional analytics** - Perfect for tracking job search performance

### 📊 Sankey Flow Diagram

**What It Shows:**
```
┌─────────┐
│ Applied │────────────────┐
│   100   │                │
└─────────┘                │
     │                     ▼
     │               ┌──────────┐
     │               │ Rejected │
     │               │    40    │
     │               └──────────┘
     ▼
┌──────────────┐
│ Interviewing │───────────┐
│      60      │           │
└──────────────┘           │
     │                     ▼
     │               ┌──────────┐
     │               │ Rejected │
     │               │    20    │
     │               └──────────┘
     ▼
┌──────────┐
│ Offered  │────────────┐
│    40    │            │
└──────────┘            │
     │                  ▼
     │            ┌──────────┐
     │            │ Rejected │
     │            │    10    │
     │            └──────────┘
     ▼
┌──────────┐
│ Accepted │
│    30    │
└──────────┘
```

**Visual Elements:**
- **Nodes** - Colored rectangles showing stage and count
  - Applied (Blue)
  - Interviewing (Purple)
  - Offered (Green)
  - Accepted (Purple/Blue)
  - Rejected (Red, at bottom)

- **Flows** - Curved colored bands showing application movement
  - Width proportional to number of applications
  - Semi-transparent for layering
  - Color matches destination status
  - Smooth bezier curves

- **Statistics Panel** - Top-left corner shows:
  - Interview Rate: X% (Applied → Interviewing)
  - Offer Rate: X% (Interviewing → Offered)
  - Acceptance Rate: X% (Offered → Accepted)

### 📈 Conversion Metrics

**Automatically Calculated:**

1. **Interview Rate**
   - Formula: (Interviewing + Offered + Accepted) / Total Applications × 100%
   - Shows: How many applications led to interviews
   - Example: 60 out of 100 = 60% interview rate

2. **Offer Rate**
   - Formula: (Offered + Accepted) / Interviewing × 100%
   - Shows: How many interviews resulted in offers
   - Example: 40 out of 60 = 67% offer rate

3. **Acceptance Rate**
   - Formula: Accepted / Offered × 100%
   - Shows: How many offers you accepted
   - Example: 30 out of 40 = 75% acceptance rate

### 📤 Export Functionality

**Export Button:**
- Top-right corner: "Export Image"
- Saves entire diagram as PNG
- High resolution (2x Retina)
- Default filename: `JobFlow-Application-Flow-YYYY-MM-DD.png`

**Export Specifications:**
- **Format:** PNG (lossless)
- **Resolution:** 3200x1800 pixels @ 2x
- **Size:** Professional presentation quality
- **Theme:** Matches current app theme (light/dark)

**Use Cases:**
- 📊 Performance reviews
- 📈 Job search progress reports
- 💼 Career coaching sessions
- 📝 Resume/portfolio enhancement
- 🎯 Strategy planning
- 📱 Social media sharing

### 🎨 Visual Design

**Node Design:**
- Bold count number (28pt)
- Stage label below
- Colored background matching status
- Rounded corners
- Drop shadow for depth
- Height proportional to count

**Flow Design:**
- Curved bezier paths
- 40% opacity for overlapping
- Smooth gradients
- Proportional width (shows volume)
- Edge borders for definition
- Professional appearance

**Color Scheme:**
- Applied: Blue (#007AFF)
- Interviewing: Purple (#9F3FE0)
- Offered: Green (#34C759)
- Rejected: Red (#FF3B30)
- Accepted: Purple (#9F3FE0)

### 🎯 How to Use

**Viewing the Flow:**
1. Click "Path" tab in sidebar (4th tab)
2. See your application funnel
3. Review conversion statistics
4. Identify bottlenecks

**Understanding the Data:**
- **Wide flows** = Many applications
- **Narrow flows** = Fewer applications
- **Short nodes** = Low count at that stage
- **Tall nodes** = High count at that stage

**Improving Your Process:**
- Low interview rate? → Improve applications
- Low offer rate? → Better interview prep
- Low acceptance rate? → Be more selective

### 📊 Example Insights

**Scenario 1: High Volume, Low Conversion**
```
Applied: 200 → Interviewing: 20 (10% interview rate)
Problem: Not getting interviews
Solution: Improve resume, target better matches
```

**Scenario 2: Good Interviews, No Offers**
```
Interviewing: 50 → Offered: 5 (10% offer rate)
Problem: Interview performance
Solution: Practice interviews, research companies
```

**Scenario 3: Many Offers, Few Accepts**
```
Offered: 30 → Accepted: 3 (10% acceptance rate)
Problem: Fit or compensation
Solution: Be more selective upfront
```

### ✨ Complete Feature List

**Views:**
- ✅ List view
- ✅ Timeline view
- ✅ Kanban view (default)
- ✅ **Path/Flow view** ⭐ NEW - Sankey diagram
- ✅ Detail view

**Path View Features:**
- ✅ **Sankey diagram** ⭐
- ✅ **Conversion funnel** ⭐
- ✅ **Flow visualization** ⭐
- ✅ **Automatic metrics** ⭐
- ✅ **PNG export** ⭐
- ✅ Status color coding
- ✅ Proportional sizing
- ✅ Statistics panel
- ✅ Theme support

**Core Functionality:**
- ✅ Full CRUD operations
- ✅ 5 view modes
- ✅ Double-click to edit
- ✅ Drag-and-drop
- ✅ URL save
- ✅ Search & filter

**Visual & Branding:**
- ✅ JobFlow branding
- ✅ Custom app icon
- ✅ Perfect themes
- ✅ Professional design

### 🔧 Technical Implementation

**Flow Algorithm:**
```swift
struct FlowStatistics {
    let applied: Int           // Total applications
    let interviewing: Int      // Currently interviewing
    let offered: Int           // Current offers
    let rejected: Int          // Total rejected
    let accepted: Int          // Accepted offers
    
    // Derived flows
    let appliedToInterviewing: Int
    let appliedToRejected: Int
    let interviewingToOffered: Int
    let interviewingToRejected: Int
    let offeredToAccepted: Int
}
```

**Sankey Path Drawing:**
- Bezier curves for smooth transitions
- Proportional width based on flow volume
- Layered rendering (flows behind nodes)
- Gradient fills with transparency
- Edge strokes for definition

**Node Positioning:**
- Column-based layout
- Vertical centering
- Height scales with count
- Minimum height: 60px
- Maximum height: 60% of canvas

**Export Rendering:**
- ImageRenderer with 2x scale
- 1600x900 base canvas
- PNG compression
- NSSavePanel for save dialog

### 📈 Benefits

**For Job Seekers:**
- **See patterns** - Where applications drop off
- **Track improvement** - Compare week over week
- **Data-driven decisions** - Focus efforts wisely
- **Motivation** - Visualize progress

**For Career Coaches:**
- **Client analytics** - Show performance metrics
- **Strategy planning** - Identify areas to improve
- **Progress tracking** - Document improvements
- **Professional reports** - Export for sessions

**For Recruiters (personal tracking):**
- **Pipeline visibility** - See candidate flow
- **Conversion tracking** - Measure effectiveness
- **Performance metrics** - Interview/offer rates
- **Process optimization** - Find bottlenecks

### 🎯 Real-World Example

**Sample Data:**
- Total Applications: 100
- Currently Interviewing: 25
- Currently Offered: 10
- Currently Rejected: 40
- Currently Accepted: 5

**Flow Breakdown:**
```
Applied (100)
├─→ Interviewing (40 moved forward)
│   ├─→ Offered (15 got offers)
│   │   ├─→ Accepted (5 accepted)
│   │   └─→ Rejected (3 declined)
│   └─→ Rejected (15 after interview)
└─→ Rejected (40 early rejection)

Metrics:
- Interview Rate: 40%
- Offer Rate: 38%
- Acceptance Rate: 33%
```

### 📊 Visual Quality

**Professional Grade:**
- Clean, modern design
- Data visualization best practices
- Color psychology (green = success, red = rejection)
- Proportional representation
- White space for readability
- Typography hierarchy
- Export-ready quality

**Theme Support:**
- Light theme: Clean white background
- Dark theme: Professional dark background
- All colors adapt appropriately
- Statistics panel matches theme
- High contrast for readability

### ✅ Quality Checklist

**Flow Diagram:**
- [x] Nodes render correctly
- [x] Flows curve smoothly
- [x] Colors match statuses
- [x] Proportions accurate
- [x] Statistics calculate correctly
- [x] Empty state helpful

**Export:**
- [x] PNG generation works
- [x] High resolution (2x)
- [x] Save dialog functional
- [x] Filename auto-suggested
- [x] Theme respected
- [x] Professional quality

**Integration:**
- [x] Path tab accessible
- [x] Switches to Sankey view
- [x] All data displayed
- [x] No build errors
- [x] Smooth performance

### 🔄 Version History

- **v5.0** - Sankey flow diagram & conversion funnel ⭐ CURRENT
- **v4.1** - In-app branding
- **v4.0** - App icon
- **v3.3** - Fixed sidebar theme
- **v3.0** - Kanban default, themes
- **v2.x** - URL save
- **v1.0** - Initial release

---

**JobFlow v5.0 - Data-Driven Job Search Success** 📊✨

Track. Analyze. Optimize. Win. 🚀
