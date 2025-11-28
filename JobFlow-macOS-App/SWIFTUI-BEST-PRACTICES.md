# SwiftUI Best Practices - Avoiding Scope Errors

## The Problem: "Cannot find 'X' in scope"

This error occurs when a view tries to access a property that isn't available in its scope. In SwiftUI, this commonly happens with `@EnvironmentObject` or `@ObservedObject` properties.

## Solution Patterns

### Pattern 1: @EnvironmentObject (Preferred for Deep Hierarchies)

**Use when:** The object needs to be accessed by many child views at different levels.

```swift
// In parent view
struct ParentView: View {
    @EnvironmentObject var store: DataStore
    
    var body: some View {
        ChildView()  // Automatically receives environmentObject
    }
}

// In child view
struct ChildView: View {
    @EnvironmentObject var store: DataStore
    
    var body: some View {
        Text(store.data)
    }
}
```

**Problem:** Context menus, buttons, and other closures DON'T automatically capture @EnvironmentObject.

**Fix:** Explicitly pass the object as a parameter.

### Pattern 2: Explicit Parameter Passing (Safer for Context Menus)

**Use when:** A child view needs to perform actions on the parent's data (especially in context menus).

```swift
// Parent view passes the object
struct ParentView: View {
    @EnvironmentObject var store: DataStore
    
    var body: some View {
        ChildView(store: store)  // Explicit pass
    }
}

// Child view accepts parameter
struct ChildView: View {
    @ObservedObject var store: DataStore  // Use @ObservedObject, not @EnvironmentObject
    
    var body: some View {
        Text(store.data)
            .contextMenu {
                Button("Delete") {
                    store.delete()  // ✅ Works! store is in scope
                }
            }
    }
}
```

### Pattern 3: Hybrid Approach (Best of Both Worlds)

**Use when:** You want environment injection but need guaranteed scope access.

```swift
// Parent
struct ParentView: View {
    @EnvironmentObject var store: DataStore
    
    var body: some View {
        ChildView(store: store)
            .environmentObject(store)  // Still inject for deeper children
    }
}

// Child
struct ChildView: View {
    @ObservedObject var store: DataStore  // Guaranteed in scope
    
    var body: some View {
        VStack {
            Text(store.data)
                .contextMenu {
                    Button("Action") {
                        store.action()  // ✅ Works!
                    }
                }
            
            DeeperChildView()  // Can still use @EnvironmentObject
        }
    }
}
```

## Common Scenarios in JobFlow

### Scenario 1: List Items with Context Menus

**❌ WRONG:**
```swift
struct JobItemView: View {
    let job: JobApplication
    
    var body: some View {
        Text(job.title)
            .contextMenu {
                Button("Edit") {
                    jobStore.editingJob = job  // ❌ ERROR: Cannot find 'jobStore'
                }
            }
    }
}
```

**✅ CORRECT:**
```swift
struct JobItemView: View {
    @ObservedObject var jobStore: JobStore  // Explicit parameter
    let job: JobApplication
    
    var body: some View {
        Text(job.title)
            .contextMenu {
                Button("Edit") {
                    jobStore.editingJob = job  // ✅ Works!
                }
            }
    }
}

// Usage in parent
ForEach(jobs) { job in
    JobItemView(jobStore: jobStore, job: job)
}
```

### Scenario 2: Cards with Menus

**❌ WRONG:**
```swift
struct CardView: View {
    let item: Item
    
    var body: some View {
        Menu("Actions") {
            Button("Delete") {
                store.delete(item)  // ❌ ERROR: Cannot find 'store'
            }
        }
    }
}
```

**✅ CORRECT:**
```swift
struct CardView: View {
    @ObservedObject var store: DataStore
    let item: Item
    
    var body: some View {
        Menu("Actions") {
            Button("Delete") {
                store.delete(item)  // ✅ Works!
            }
        }
    }
}
```

### Scenario 3: Buttons with Actions

**❌ WRONG:**
```swift
struct DetailView: View {
    let item: Item
    
    var body: some View {
        Button("Save") {
            store.save(item)  // ❌ ERROR: Cannot find 'store'
        }
    }
}
```

**✅ CORRECT:**
```swift
struct DetailView: View {
    @EnvironmentObject var store: DataStore  // Access via environment
    let item: Item
    
    var body: some View {
        Button("Save") {
            store.save(item)  // ✅ Works! Button closures CAN capture @EnvironmentObject
        }
    }
}
```

**Note:** Regular button actions CAN capture @EnvironmentObject. Context menus are the main exception.

## Rule of Thumb

1. **Use @EnvironmentObject** for:
   - Simple data display
   - Button actions (not in context menus)
   - Passing data down many levels

2. **Use @ObservedObject with explicit passing** for:
   - Context menus
   - List item actions
   - Any scenario where scope errors occur

3. **Test context menus immediately** - they're the most common source of scope errors

## Checklist for New Views

- [ ] Does this view use context menus? → Use @ObservedObject parameter
- [ ] Does this view need to modify parent data? → Pass the object explicitly
- [ ] Is this a simple display-only view? → @EnvironmentObject is fine
- [ ] Does this view create buttons/menus? → Test scope immediately

## JobFlow-Specific Rules

For JobFlow, we use this pattern:

```swift
// Views that display data only
struct DisplayView: View {
    @EnvironmentObject var jobStore: JobStore  // OK - just displaying
}

// Views with context menus or item actions
struct JobItemView: View {
    @ObservedObject var jobStore: JobStore  // Required - has context menu
    let job: JobApplication
}

// Views that modify state
struct FormView: View {
    @EnvironmentObject var jobStore: JobStore  // OK - buttons work fine
}
```

## Testing

Always test these immediately after creating:
1. Context menus (right-click menus)
2. Inline menus (Menu { } components)
3. Any closure that modifies parent state
4. ForEach with item-specific actions

## Quick Fix

If you see "Cannot find 'X' in scope":

1. Identify where X is defined (usually @EnvironmentObject in parent)
2. Change the child view to accept X as @ObservedObject parameter
3. Pass X explicitly when creating the child view
4. Rebuild and test

This ensures the variable is in scope for all closures and actions.
