# URL Import Feature Guide

## 🎯 Quick Start

### Import a Job in 3 Steps

1. **Click the + button** to add a new job
2. **Click "Import from URL"** in the form header
3. **Paste the job posting URL** and click "Import"

That's it! JobFlow will automatically fill in:
- ✅ Job Title
- ✅ Company Name
- ✅ Location
- ✅ Salary (if available)
- ✅ Description
- ✅ Notes with source URL

## 🌍 Supported Job Boards

### 🇨🇦 Canadian Job Boards
- **Indeed Canada** (indeed.ca)
- **Job Bank Canada** (jobbank.gc.ca) - Government of Canada
- **Workopolis** (workopolis.com)
- **Eluta** (eluta.ca)
- **CharityVillage** (charityvillage.com)
- **CanadaJobs** (canadajobs.com)

### 🌎 International Job Boards
- **LinkedIn** (linkedin.com)
- **Indeed** (indeed.com)
- **Glassdoor** (glassdoor.com / glassdoor.ca)
- **Monster** (monster.com / monster.ca)
- **ZipRecruiter** (ziprecruiter.com)
- **CareerBuilder** (careerbuilder.com)

### 💻 Tech-Focused Boards
- **Stack Overflow Jobs**
- **GitHub Jobs**
- **AngelList / Wellfound**
- **Dice**
- **Hired**
- **Triplebyte**

### 🏢 Applicant Tracking Systems (ATS)
These power many company career pages:
- **Greenhouse** (*.greenhouse.io)
- **Lever** (*.lever.co)
- **Workday** (*.myworkdayjobs.com)
- **Taleo** (*.taleo.net)
- **iCIMS** (*.icims.com)
- **BambooHR** (*.bamboohr.com)
- **SuccessFactors** (*.successfactors.com)
- **Ultipro** (*.ultipro.com)
- **Paylocity** (*.paylocity.com)

### 🌏 Other International Boards
- **SEEK** (seek.com.au / seek.co.nz) - Australia/NZ
- **TotalJobs** (totaljobs.com) - UK
- **Reed** (reed.co.uk) - UK
- **CV-Library** (cv-library.co.uk) - UK

**Total: 30+ supported platforms!**

## 📋 How It Works

### Automatic Detection
When you paste a URL, JobFlow:
1. ✅ Detects if it's from a supported job board
2. ✅ Shows a green checkmark with the board name
3. ✅ Fetches the job posting page
4. ✅ Extracts relevant information
5. ✅ Pre-fills the form fields

### What Gets Extracted

#### From Major Job Boards (LinkedIn, Indeed, Glassdoor)
- Job title
- Company name
- Location (city, country)
- Salary range (if posted)
- Job description (first 500 characters)
- Source URL (saved in notes)

#### From Company Career Pages (Greenhouse, Lever, etc.)
- Job title
- Company name (from subdomain)
- Location
- Source URL

#### From Generic URLs
- Best-effort extraction
- Company name from domain
- Source URL saved

## 💡 Usage Examples

### Example 1: LinkedIn Job
```
URL: https://www.linkedin.com/jobs/view/3234567890
Result:
  ✓ Title: Senior Software Engineer
  ✓ Company: Google
  ✓ Location: Toronto, ON, Canada
  ✓ Description: Join our team to build...
```

### Example 2: Indeed Canada
```
URL: https://ca.indeed.com/viewjob?jk=abc123
Result:
  ✓ Title: Product Manager
  ✓ Company: Shopify
  ✓ Location: Ottawa, ON
  ✓ Salary: $100,000 - $140,000
```

### Example 3: Government Job Bank
```
URL: https://www.jobbank.gc.ca/jobsearch/jobposting/37845678
Result:
  ✓ Title: Policy Analyst
  ✓ Company: [From posting]
  ✓ Location: Canada
  ✓ Notes: Imported from Job Bank Canada
```

### Example 4: Company Greenhouse Page
```
URL: https://boards.greenhouse.io/shopify/jobs/5678901
Result:
  ✓ Title: UX Designer
  ✓ Company: Shopify
  ✓ Location: Remote
  ✓ Notes: Imported from: [URL]
```

## 🎨 Visual Indicators

### Green Checkmark
Appears when JobFlow recognizes the job board:
```
✓ Supported: LinkedIn
✓ Supported: Indeed Canada
✓ Supported: Greenhouse
```

### Info Icon
Appears for unknown URLs:
```
ℹ Will attempt to extract basic info
```

### Loading State
Shows while importing:
```
[Progress Spinner] Importing...
```

## 🔧 Advanced Features

### Supported Boards List
Click "View 30+ supported job boards" to see:
- All Canadian job boards
- International platforms
- ATS systems
- Tech-focused sites

### Manual Override
After importing, you can:
- ✅ Edit any field
- ✅ Add missing information
- ✅ Correct extracted data
- ✅ Add your own notes

### URL Saved in Notes
The source URL is always saved in the Notes field:
```
Imported from: https://linkedin.com/jobs/view/...
```

This lets you:
- Return to the original posting
- Reference job requirements
- Apply if you haven't yet

## 📱 Workflow Integration

### Typical Job Search Flow

#### Traditional Way:
1. Find job posting online
2. Open JobFlow
3. Click +
4. Manually type title
5. Manually type company
6. Manually copy/paste location
7. Manually copy/paste salary
8. Manually copy/paste description
9. Save

**Time: ~3 minutes per job**

#### With URL Import:
1. Find job posting online
2. Copy URL (Cmd+L, Cmd+C)
3. Open JobFlow → Click +
4. Click "Import from URL"
5. Paste (Cmd+V) → Click Import
6. Review and save

**Time: ~20 seconds per job** ⚡

### 90% Faster!

## 🎯 Pro Tips

### Tip 1: Batch Import
1. Browse job boards
2. Open multiple tabs
3. Copy URL from each tab
4. Import them one by one in JobFlow
5. Quick way to build your pipeline

### Tip 2: Verify Information
Always check:
- Job title is correct
- Company name is properly capitalized
- Location is accurate
- Salary matches (some boards hide this)

### Tip 3: Add Context
After importing, add to Notes:
- Why you're interested
- Who referred you
- Application deadline
- Required documents

### Tip 4: Keep the URL
Don't delete the imported URL from notes!
Useful for:
- Re-reading the job description
- Checking application status
- Seeing if the posting is still active

### Tip 5: Works Offline Too
You can still add jobs manually if:
- No internet connection
- Job posting is on paper
- Company uses email applications
- Networking/referral opportunity

## 🔒 Privacy & Security

### What JobFlow Does
- ✅ Fetches public job posting pages
- ✅ Extracts text content only
- ✅ Stores data locally on your Mac
- ✅ No data sent to external servers

### What JobFlow Doesn't Do
- ❌ Doesn't log in to job boards
- ❌ Doesn't apply on your behalf
- ❌ Doesn't store your credentials
- ❌ Doesn't track your activity
- ❌ Doesn't share your data

### All Data Stays Local
- Your job applications: On your Mac
- Your notes: On your Mac
- URLs you import: On your Mac
- Everything: Private and secure

## ⚠️ Limitations

### What Might Not Work
- **Login-Required Pages**: Pages that need an account
- **Dynamic Content**: JavaScript-heavy single-page apps
- **Rate Limiting**: Some sites block automated access
- **Paywalled Jobs**: Premium job listings
- **Regional Restrictions**: Geo-blocked content

### Fallback Behavior
If auto-import fails:
- Form stays open
- You can manually enter details
- Original URL saved in notes
- No data is lost

### Manual Entry Still Available
You never have to use URL import:
- All form fields work independently
- Manual entry is always an option
- URL import is just a convenience

## 🆘 Troubleshooting

### "Invalid URL format"
- Check the URL is complete
- Must start with http:// or https://
- Copy the full URL from browser

### Import Button Disabled
- Make sure URL field isn't empty
- Wait for any previous import to finish

### No Data Extracted
- Some sites block automated access
- Manually enter the information
- URL is still saved in notes

### Wrong Information Extracted
- Edit any field before saving
- Parser might misidentify elements
- Report issues for improvement

## 🚀 Future Enhancements

Coming soon:
- [ ] Better extraction from more sites
- [ ] Browser extension for one-click import
- [ ] Bulk import from bookmarks
- [ ] Application status tracking from URL
- [ ] Duplicate detection
- [ ] Auto-refresh for updated postings

## 📞 Supported Boards by Region

### North America
- Indeed (US/CA)
- LinkedIn
- Monster (US/CA)
- Glassdoor (US/CA)
- ZipRecruiter
- CareerBuilder

### Canada Specific
- Job Bank Canada ⭐
- Workopolis
- Eluta
- CharityVillage

### United Kingdom
- TotalJobs
- Reed
- CV-Library

### Australia / New Zealand
- SEEK

### Global
- LinkedIn (all regions)
- Company ATS platforms (worldwide)

---

**Import jobs faster. Track applications better. Get hired sooner.** 🎯
