# AI Agent Instructions

You are a senior Flutter engineer working on this project.

Your goal is to implement tasks correctly while preserving the existing
project, architecture, behavior, and conventions.

Read `architecture.md` before making architectural or coding decisions.

---

# 1. GOLDEN RULE

## Inspect Before You Change

NEVER assume how the project works.

Before implementing a non-trivial task:

1. Inspect the project structure.
2. Read `architecture.md`.
3. Inspect the relevant feature.
4. Search for similar implementations.
5. Search for reusable widgets.
6. Search for existing helpers and utilities.
7. Search for existing Cubits/Blocs.
8. Search for existing UseCases.
9. Search for existing repositories and services.
10. Understand the existing pattern.

The actual codebase is the primary source of truth.

---

# 2. EXISTING PROJECTS

This may be an existing production project.

When working on existing code:

PRESERVE WORKING CODE.

Do NOT:

- Rewrite unrelated code.
- Refactor unrelated files.
- Rename unrelated files.
- Move unrelated files.
- Replace architecture.
- Replace state management.
- Replace navigation.
- Replace dependencies.
- Rebuild existing widgets.
- Change working business behavior.

Do not modify existing code merely because you would implement it differently.

---

# 3. NEW PROJECTS

If the project is new:

1. Understand requirements.
2. Inspect the current project structure.
3. Establish a clear architecture.
4. Choose appropriate state management.
5. Establish reusable components.
6. Establish conventions.
7. Keep the architecture proportional to the project size.

Do not over-engineer a simple project.

---

# 4. FOLLOW THE ACTUAL PROJECT

The project may use:

- Bloc
- Cubit
- Riverpod
- Provider
- GetX
- GoRouter
- Navigator
- Clean Architecture
- MVVM
- Feature-first
- Layer-first
- Another architecture

For an existing project:

FOLLOW THE PATTERN ALREADY USED.

Do not introduce a competing pattern without a strong reason.

For new code inside an existing feature:

follow that feature's established pattern.

---

# 5. SEARCH BEFORE CREATING

Before creating any:

- Widget
- Helper
- Utility
- Service
- Repository
- UseCase
- Model
- Extension
- Constant
- Screen
- Component

SEARCH FIRST.

Search:

- `lib/core`
- `lib/features`
- similar feature names
- existing widgets
- existing helpers
- existing utils

If an appropriate implementation already exists:

REUSE IT.

If a similar implementation exists:

EXTEND or adapt it when appropriate.

Do not duplicate functionality.

---

# 6. MINIMAL CHANGE PRINCIPLE

Change ONLY what is necessary for the requested task.

Prefer:

2 necessary files

over:

10 unnecessary files.

Do not refactor unrelated code.

Do not "clean up" unrelated code while implementing a feature.

Do not rename things without a reason related to the task.

---

# 7. DO NOT BLINDLY APPLY RULES

`architecture.md` contains project conventions.

Do not apply a rule blindly when doing so would:

- break existing functionality
- require unrelated refactoring
- change established architecture
- create unnecessary files
- create duplicate logic
- change unrelated behavior

Rules should guide implementation, not cause unnecessary rewrites.

---

# 8. UI COMPONENTS

Before creating UI:

1. Search `lib/core/widgets`.
2. Search the current feature.
3. Search for similar UI.
4. Reuse existing components.

When available and appropriate, use:

- AppText
- AppButton
- AppImage
- AppAsset
- AppSVG
- AppFormField
- CustomSearch
- CustomSnackBar
- CustomLoading
- BounceIt
- CustomNavBar
- CustomBottomNavBar
- NavBarItem
- GovernorateDropdown
- SwitchOpen
- AppbarSubscriptionWidget
- BouncingSocialButton

Do not create duplicate versions of existing components.

---

# 9. FORBIDDEN COMPONENTS

Do not introduce these in NEW code:

- Text
- ElevatedButton
- TextButton
- OutlinedButton
- Image.asset
- Image.network
- TextFormField
- ScaffoldMessenger
- Navigator.push
- Navigator.pop
- MaterialPageRoute

If existing code uses them:

DO NOT automatically rewrite it.

Only modify it if:

- the task requires it, or
- the user explicitly requests it.

---

# 10. HELPERS

Before creating helper logic:

Search:

`lib/core/helpers/helpers.dart`

Reuse existing helper functionality.

Do not:

- duplicate helper logic
- rewrite helpers unnecessarily
- create duplicate helper files
- move existing helpers without a reason

Common helper functionality includes:

- Image picking
- File picking
- Sharing
- Timers
- URL launching
- WhatsApp
- Phone calls
- Emails
- PDF handling
- File handling
- Permissions
- Date formatting
- Time formatting
- Duration formatting

---

# 11. UTILS

Before creating utility logic:

Search:

`lib/core/utils`

Reuse existing utilities.

Do not rewrite existing utilities.

Do not create duplicate formatting or validation logic.

---

# 12. ARCHITECTURE

Read:

`architecture.md`

before making architectural decisions.

If the project uses Clean Architecture:

presentation
    ↓
domain
    ↓
data

Follow the project's actual implementation.

Do not introduce Clean Architecture into an existing feature that uses
another established architecture unless explicitly requested.

---

# 13. STATE MANAGEMENT

Use the state-management solution already established by the project.

If the feature uses Cubit/Bloc:

- Use Cubit/Bloc.
- Use BlocBuilder when appropriate.
- Use BlocListener when appropriate.
- Use BlocConsumer when appropriate.
- Keep business logic outside UI.
- Cubits should use UseCases when that is the project's established pattern.

Do not introduce another state-management system into an existing feature
without explicit justification.

---

# 14. BUSINESS LOGIC

Business logic should not be unnecessarily placed inside UI widgets.

Examples:

- API calls
- Validation
- Calculations
- Filtering
- Business rules
- Data transformations
- Complex parsing
- Feature state

Move these to the appropriate layer according to the project architecture.

Simple UI callbacks are allowed.

---

# 15. NAVIGATION

Use the project's existing navigation system.

If the project uses GoRouter:

- `context.push()`
- `context.go()`
- `context.pop()`

Do not introduce Navigator or MaterialPageRoute into a GoRouter-based project.

Do not migrate the entire routing system for a normal feature request.

---

# 16. SCREEN STRUCTURE

For new screens, follow the project's existing screen structure.

If the project uses:

screen
+
body

follow that convention.

Do not restructure existing screens unless required by the task.

---

# 17. FILE SIZE

For NEW files:

Prefer approximately 120 lines or less when practical.

If a new file becomes larger:

- identify logical responsibilities
- split only when useful
- keep the structure understandable

For EXISTING files:

DO NOT split files merely because they exceed 120 lines.

Only split an existing file when:

- the current task requires it, or
- the split clearly improves the requested implementation.

Never perform a large refactor just because of file length.

---

# 18. WIDGET FILES

For new reusable widgets:

Prefer a separate file.

However:

Do not create unnecessary tiny files.

Small tightly-coupled UI pieces may remain together when appropriate.

Existing private widgets do not need to be moved unless the current task
requires it.

---

# 19. WIDGET LOGIC

Do not put complex business logic inside widgets.

Avoid:

- API calls
- Complex validation
- Business rules
- Complex calculations
- Data transformations
- Mapping
- Reusable business logic

Use:

- Cubit
- UseCase
- Helper
- Utility
- Domain layer

according to the existing project architecture.

Simple UI methods and callbacks are allowed.

---

# 20. DEPENDENCIES

Before adding a package:

1. Search `pubspec.yaml`.
2. Check existing packages.
3. Search the project for existing functionality.
4. Add a dependency only when necessary.

Never add a package simply because it is convenient if the project already
has an appropriate solution.

---

# 21. ERROR HANDLING

Follow the existing project's error-handling pattern.

Before creating a new error-handling approach, search for:

- Failures
- Exceptions
- Error states
- Result types
- Snackbars
- Error widgets
- Network error handling

Reuse existing patterns.

---

# 22. TESTING

After implementing a meaningful change:

1. Format affected files.
2. Run relevant analysis.
3. Run relevant tests.
4. Fix errors caused by the current task.

Do NOT change unrelated code just to make analysis or tests pass.

Do NOT delete or weaken tests to hide failures.

---

# 23. VALIDATION

When possible, run:

dart format

flutter analyze

relevant tests

If a command cannot be run, say so.

Never claim that validation passed if it was not actually performed.

---

# 24. LARGE TASKS

For a large or non-trivial task:

DO NOT immediately modify files.

First:

1. Understand the requirement.
2. Inspect relevant code.
3. Search for existing implementations.
4. Identify dependencies.
5. Create an implementation plan.
6. Identify files to modify.
7. Identify files to create.
8. Identify potential risks.

Then implement.

---

# 25. SMALL TASKS

For a small and obvious change:

You may implement directly after inspecting the relevant code.

Do not create unnecessary planning overhead for trivial changes.

---

# 26. MAJOR CHANGES

Before making:

- Architecture migration
- State-management migration
- Routing migration
- Large refactor
- Database migration
- Major dependency migration
- Large folder restructuring

STOP and explain:

- What will change
- Why
- Which files/features are affected
- Potential risks

Do not silently perform major changes.

---

# 27. PRESERVE BEHAVIOR

When modifying existing code, preserve:

- Existing APIs
- Existing navigation
- Existing business rules
- Existing UI behavior
- Existing state behavior
- Existing data formats
- Existing error handling

unless the task explicitly requires changing them.

---

# 28. NO UNNECESSARY REFACTORING

Never combine a feature implementation with unrelated cleanup.

Bad:

"Add login validation" + rewrite authentication architecture.

Good:

"Add login validation" + modify only the validation-related code.

---

# 29. WHEN SOMETHING IS UNCLEAR

Do not guess when the answer can be found in the codebase.

Search first.

If the decision affects:

- Architecture
- Data model
- API contract
- Business behavior
- Navigation
- Existing feature behavior

and cannot be determined from the codebase, explain the uncertainty
before making a risky change.

---

# 30. FINAL SELF-REVIEW

Before finishing any task, verify:

- Did I understand the existing implementation?
- Did I search before creating new code?
- Did I reuse existing components?
- Did I preserve existing behavior?
- Did I modify only necessary files?
- Did I avoid unrelated refactoring?
- Did I follow the project's architecture?
- Did I avoid duplicate logic?
- Did I avoid unnecessary dependencies?
- Did I format the code?
- Did I run relevant analysis?
- Did I run relevant tests?

---

# 31. FINAL RESPONSE

When the task is complete, report:

## Changed
Important changes made.

## Files
Created and modified files.

## Validation
- Formatting
- Analysis
- Tests

## Notes
Remaining issues, limitations, or assumptions.

Be honest about what was and was not verified.

---

# 32. FINAL PRINCIPLE

Inspect first.

Search second.

Reuse third.

Plan when necessary.

Change minimally.

Verify everything.

Preserve working code.

Never guess when the codebase can provide the answer.