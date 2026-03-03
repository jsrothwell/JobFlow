# Build Instructions for JobFlow v7.3

## If You Get Build Errors

### Error: "Cannot find 'ToastManager' in scope"
### Error: "Cannot find type 'EmptyStateType' in scope"

**Solution**: Clean build folder

1. In Xcode: **Product** → **Clean Build Folder** (or Cmd+Shift+K)
2. Close Xcode completely
3. Delete derived data:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData
   ```
4. Reopen project in Xcode
5. Build again (Cmd+B)

### Alternative: Manual Verification

Verify all new files are added to target:

1. Select each file in Xcode navigator:
   - OnboardingView.swift
   - EmptyStateView.swift  
   - ConfirmationDialog.swift
   - ToastNotification.swift

2. Check right panel: "Target Membership" → JobFlow should be checked

3. If unchecked, check the box

### Still Having Issues?

The types are defined in these files:
- `ToastManager` → ToastNotification.swift (line 41)
- `EmptyStateType` → EmptyStateView.swift (line 50)

If Xcode can't see them, it's a cache issue. The code is correct.

## Quick Fix Script

```bash
# Run this from the JobFlow-UX-Refined directory
cd JobFlow-UX-Refined

# Remove any .DS_Store files
find . -name ".DS_Store" -delete

# Open the project fresh
open JobFlow.xcodeproj
```

Then in Xcode:
1. Clean Build Folder (Cmd+Shift+K)
2. Build (Cmd+B)

## Verification

All 4 new files should be visible in the Xcode project navigator:
- ✅ OnboardingView.swift
- ✅ EmptyStateView.swift
- ✅ ConfirmationDialog.swift
- ✅ ToastNotification.swift

All should have the JobFlow target checked.
