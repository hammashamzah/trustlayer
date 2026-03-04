---
name: morning
description: Morning check-in — fetch priorities from ClickUp and recommend what to work on
keywords: [morning, checkin, priorities, tasks, clickup, trustlayer]
---

# /morning — Morning Check-in

Fetch your tasks from ClickUp (Workspace: Kudcrafts, Space: Apps) and present a prioritized action plan.

## When to Use
- Start of day: "What should I work on?"
- "Morning check-in"
- "What's my priority?"

## Behavior

### Step 1: Fetch Tasks
Use `clickup_search` to find tasks:
- Filter: assigned to me, status is active/open/in progress/to do
- Sort by: priority (urgent first), then due date (overdue first)
- Space: Apps

### Step 2: Categorize
Group tasks into:
1. **OVERDUE** — past due date (show days overdue)
2. **DUE TODAY** — due today
3. **HIGH PRIORITY** — urgent or high priority, no due date pressure
4. **IN PROGRESS** — already started, should continue
5. **BACKLOG** — everything else

### Step 3: Present Dashboard
```
## Good morning! Here's your day.

### OVERDUE (fix these first)
- [ ] Task name [Project] — 3 days overdue

### DUE TODAY
- [ ] Task name [Project] — due today

### HIGH PRIORITY
- [ ] Task name [Project] — urgent

### IN PROGRESS (continue these)
- [ ] Task name [Project] — started yesterday

### Recommended Focus
1. First: [task] — because [reason]
2. Then: [task] — because [reason]
3. If time: [task]
```

### Step 4: Offer to Start
"Which task do you want to work on? I can start a worktree and begin."

If user picks a task:
1. Note which ClickUp task was chosen
2. Suggest: "Want me to start time tracking on this?"
