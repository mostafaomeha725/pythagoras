# Flutter Development Architecture & Coding Rules

This document defines the project's architecture, coding conventions, UI rules,
state-management rules, reusable components, helpers, utilities, navigation,
file organization, and code-quality standards.

These rules apply to new code and to code modified as part of the current task.

For an existing project, the existing working implementation is the source of truth.
Do not refactor unrelated code merely to make it comply with these rules.

---

# 1. General Principles

- Follow the existing project structure when working on an existing project.
- For new projects, establish a clean and consistent structure.
- Reuse existing code before creating new code.
- Avoid duplicate logic.
- Avoid unnecessary abstractions.
- Keep responsibilities separated.
- Preserve existing behavior unless the task explicitly requires changing it.
- Make the smallest reasonable change required to complete the task.

---

# 2. Forbidden Flutter Components

Do NOT introduce the following in new code:

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

For UI text, buttons, images, forms, snackbars, and navigation,
use the project's established custom components.

IMPORTANT:

Existing code containing these components must NOT be rewritten merely
to satisfy this rule.

Only modify existing usage when:
- the current task requires it, or
- the user explicitly requests the migration.

---

# 3. Required Project Components

When these components exist in the project, prefer them over their
standard Flutter equivalents:

- AppText
- AppButton
- AppImage
- AppAsset
- AppSVG
- AppFormField
- CustomSnackBar
- CustomLoading
- BounceIt

Additional existing core widgets may include:

- CustomSearch
- CustomNavBar
- CustomBottomNavBar
- NavBarItem
- GovernorateDropdown
- SwitchOpen
- AppbarSubscriptionWidget
- BouncingSocialButton

Before creating a new component, search the project first.

---

# 4. Reusability Rules

Before creating anything new:

1. Search `lib/core/widgets`.
2. Search the current feature.
3. Search the entire project for similar implementations.
4. Check whether an existing component can be reused.
5. Extend an existing component when appropriate.

Never duplicate UI logic when an existing reusable implementation
can reasonably be used.

Do not force unrelated components into a shared widget simply to
increase reuse.

---

# 5. AppText

When the project provides `AppText`, use it instead of Flutter `Text`.

Example:

AppText(
  text,
  style: font14w500.copyWith(
    color: Colors.grey,
  ),
)

Do not create another text abstraction if `AppText` already provides
the required functionality.

---

# 6. Core Helpers

When the project contains:

`lib/core/helpers/helpers.dart`

Use it for shared helper functionality.

Do not:

- duplicate helper logic
- rewrite existing helper logic
- create another helper for functionality already provided
- place reusable helper logic inside UI files

Common helper responsibilities may include:

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
- Reusable formatting logic
- Date formatting
- Duration formatting
- Time formatting

IMPORTANT:

If an existing project already uses a different helper structure,
follow the existing structure instead of restructuring the project.

---

# 7. Core Utils

Use existing utilities from:

`lib/core/utils`

Possible utilities include:

- app_bloc_observer.dart
- app_date_time.dart
- easy_loading.dart
- safe_print.dart
- spacing.dart
- url_launcher_util.dart
- validators.dart

Rules:

- Do not rewrite existing utilities.
- Do not duplicate utility logic.
- Search before creating a new utility.
- Follow the existing project's utility structure.

---

# 8. Clean Architecture

When the project uses Clean Architecture, follow:

presentation
    ↓
domain
    ↓
data

## Presentation

May contain:

- Screens
- Widgets
- Cubits
- Bloc
- UI state
- UI-specific behavior

## Domain

May contain:

- Entities
- UseCases
- Repository contracts
- Business rules

The domain layer should not depend on Flutter UI.

## Data

May contain:

- Models
- DataSources
- Repository implementations
- API clients
- Local data sources
- Firebase implementations

---

# 9. Existing Architecture Rule

For an existing project:

- Follow the architecture already used.
- Follow patterns used by similar features.
- Do not introduce a competing architecture.
- Do not migrate the project to Clean Architecture unless explicitly requested.
- Do not restructure working features simply for architectural consistency.

For a new project:

- Use a maintainable architecture appropriate to the project's size.
- Avoid unnecessary layers.
- Keep responsibilities clear.

---

# 10. State Management

If the project uses Bloc/Cubit, use:

- Bloc
- Cubit
- BlocBuilder
- BlocListener
- BlocConsumer

Business logic must not be placed unnecessarily inside UI widgets.

Move appropriate logic to Cubits/UseCases according to the project's architecture.

Logic that may belong outside widgets includes:

- API calls
- Validation
- Filtering
- Calculations
- State changes
- Feature logic
- Business rules
- Data transformations

IMPORTANT:

For an existing project, use the state-management solution already
used by the relevant feature.

Do not introduce another state-management library without a clear reason.

---

# 11. setState

Do not use `setState` for:

- Business logic
- Shared state
- API state
- Feature state
- Complex state management

Simple local UI state may use `setState` when appropriate.

Do not rewrite existing `setState` usage unless required by the task.

---

# 12. Cubit Rules

When using Cubit:

- Cubits should handle feature state and orchestration.
- Cubits should call UseCases when UseCases are part of the architecture.
- Do not access repositories directly from UI.
- Keep business rules out of UI widgets.

If an existing project uses a different established pattern,
follow that pattern rather than forcing Cubit architecture onto it.

---

# 13. Navigation

If the project uses GoRouter, use:

- `context.push()`
- `context.go()`
- `context.pop()`

Do not introduce:

- `Navigator.push`
- `Navigator.pop`
- `MaterialPageRoute`

For an existing project using another routing system,
follow the existing system.

Do not migrate routing infrastructure for a normal feature task.

---

# 14. Screen Structure

When the project follows Screen + Body separation:

## Screen File

Example:

`login_screen.dart`

Should primarily contain:

- Scaffold
- Screen-level configuration
- Required providers/listeners when appropriate

## Body File

Example:

`login_screen_body.dart`

Contains the main UI.

IMPORTANT:

Do not restructure existing screens merely to satisfy this rule.

For new screens, follow this pattern when it matches the project architecture.

---

# 15. File Splitting

Preferred maximum for NEW files:

120 lines when practical.

This is a guideline, not a reason to perform unrelated refactoring.

If a NEW file exceeds approximately 120 lines:

1. Identify logical responsibilities.
2. Split only where separation improves maintainability.
3. Create appropriate widgets/files.
4. Keep dependencies clear.

For EXISTING files:

Do NOT split or restructure them merely because they exceed 120 lines.

If splitting an existing file is required by the current task:

- Explain the reason.
- Preserve behavior.
- Make the smallest reasonable change.

---

# 16. Large UI

When UI becomes genuinely large or complex,
split it into meaningful components such as:

- Header
- Form
- Section
- Card
- List
- Dialog

Do not create tiny files without a meaningful responsibility.

---

# 17. Widget Rules

For NEW reusable widgets:

- Prefer a separate file.
- Give the widget a clear responsibility.
- Make it reusable when reuse is actually expected.

Private widgets inside a file are discouraged for NEW complex/reusable widgets.

Existing private widgets do not need to be moved unless required.

Do not create a separate file for every tiny UI fragment when doing so
would reduce readability.

---

# 18. Widget Logic Separation

Do not place complex business logic inside widget files.

Avoid putting these inside widgets:

- API calls
- Business rules
- Complex validation
- Complex calculations
- Complex transformations
- Mapping logic
- Reusable business methods
- Data processing

Prefer:

UI
 ↓
Cubit / UseCase / Helper / Domain
 ↓
Data

Simple UI callbacks are allowed inside widgets.

Examples of acceptable UI callbacks:

- Opening a dialog
- Changing a local visual state
- Triggering a Cubit event
- Calling navigation
- Handling a simple button interaction

---

# 19. Helper Methods Inside Widgets

Do not create helper methods inside widgets when the logic is reusable,
business-related, or complex.

Examples to avoid:

String _formatDate() {}

String _formatTime() {}

String _formatDuration() {}

For reusable logic, use the appropriate existing helper, utility,
extension, Cubit, UseCase, or domain component.

Simple UI-only methods may remain in the widget when they improve
readability and are not reusable/business logic.

---

# 20. Naming

Follow existing project naming conventions.

For new code:

- Use standard Dart naming conventions.
- Use descriptive names.
- Avoid unnecessary abbreviations.
- Keep names consistent with neighboring code.

Do not rename existing code unnecessarily.

---

# 21. Dependencies

Before adding a dependency:

1. Check whether the project already has a package that solves the problem.
2. Check whether the functionality already exists internally.
3. Add a new dependency only when necessary.
4. Avoid unnecessary packages.

Do not replace existing dependencies without a specific reason.

---

# 22. Testing

Important business logic should be testable independently from UI
when practical.

Use the project's established testing approach.

Possible tests:

- Unit tests
- Widget tests
- Integration tests

Do not delete tests simply because they fail.

Investigate and fix the underlying issue.

---

# 23. Code Quality

Prefer:

- Clear code
- Small responsibilities
- Reusable components
- Consistent architecture
- Minimal duplication
- Explicit dependencies
- Maintainable abstractions

Avoid:

- Over-engineering
- Premature abstraction
- Duplicate logic
- Giant files
- Giant widgets
- Unnecessary packages
- Unrelated refactoring

---

# 24. Architecture Changes

Architecture changes are high-impact.

Do not perform:

- Architecture migrations
- State-management migrations
- Routing migrations
- Large refactors
- Major folder restructuring

as a side effect of a normal feature request.

Such changes require explicit approval.

---

# 25. Source of Truth

When there is a conflict:

1. Current working code
2. Explicit user request
3. Project documentation
4. These general conventions

The current codebase should be inspected before making assumptions.

The AI must never assume that a component, helper, utility,
service, or feature does not exist without searching first.