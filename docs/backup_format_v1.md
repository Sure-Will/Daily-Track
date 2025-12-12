# Daily Routine Backup Format V1

This document defines the JSON backup format for Daily Routine app data.

## Version

Current version: **1**

## Format Specification

### Top-level Structure

```json
{
  "version": 1,
  "exportedAt": "2025-12-12T10:30:00.000Z",
  "habits": [...]
}
```

### Fields

#### `version` (integer, required)
- Format version number
- Current: `1`
- Used for future compatibility checks

#### `exportedAt` (string, required)
- ISO 8601 timestamp of when the backup was created
- Format: `YYYY-MM-DDTHH:mm:ss.sssZ`
- Example: `"2025-12-12T10:30:00.000Z"`

#### `habits` (array, required)
- List of all habit objects
- Can be empty array `[]`

### Habit Object Structure

```json
{
  "id": "habit_1234567890",
  "title": "洗澡",
  "icon": "shower_rounded",
  "color": "#FFD700",
  "records": {
    "2025-12-01": true,
    "2025-12-02": true,
    "2025-12-05": true
  }
}
```

#### Habit Fields

##### `id` (string, required)
- Unique identifier for the habit
- Must be stable across exports/imports
- Format: `habit_` + timestamp or UUID
- Example: `"habit_1234567890"`

##### `title` (string, required)
- Display name of the habit
- User-visible text
- Example: `"洗澡"`, `"给猫咪铲屎"`

##### `icon` (string, optional)
- Material Icons identifier
- Maps to Flutter `Icons` class
- Example: `"shower_rounded"`, `"pets_rounded"`
- Default: `"check_circle_rounded"` if not specified

##### `color` (string, optional)
- Hex color code for habit theme
- Format: `#RRGGBB` or `#AARRGGBB`
- Example: `"#FFD700"`, `"#FF8C00"`
- Default: `"#FFD700"` (gold) if not specified

##### `records` (object, required)
- Map of check-in dates
- Key: date in `YYYY-MM-DD` format
- Value: `true` (checked) or `false` (unchecked)
- Only `true` values need to be stored for efficiency
- Example:
  ```json
  {
    "2025-12-01": true,
    "2025-12-02": true,
    "2025-12-05": true
  }
  ```

## Complete Example

```json
{
  "version": 1,
  "exportedAt": "2025-12-12T10:30:00.000Z",
  "habits": [
    {
      "id": "habit_1701234567890",
      "title": "洗澡",
      "icon": "shower_rounded",
      "color": "#FFD700",
      "records": {
        "2025-12-01": true,
        "2025-12-02": true,
        "2025-12-05": true,
        "2025-12-10": true
      }
    },
    {
      "id": "habit_1701234567891",
      "title": "给猫咪铲屎",
      "icon": "pets_rounded",
      "color": "#FF8C00",
      "records": {
        "2025-12-01": true,
        "2025-12-03": true,
        "2025-12-04": true,
        "2025-12-08": true,
        "2025-12-11": true
      }
    },
    {
      "id": "habit_1701234567892",
      "title": "阅读 30 分钟",
      "icon": "menu_book_rounded",
      "color": "#4CAF50",
      "records": {
        "2025-12-02": true,
        "2025-12-06": true
      }
    }
  ]
}
```

## Version Compatibility Strategy

### Current Version (V1)
- Apps should validate `version === 1` before importing
- Reject files with `version > 1` or missing version field
- Show clear error messages for incompatible versions

### Future Versions (V2+)
When introducing breaking changes:
1. Increment version number
2. Maintain backward compatibility where possible
3. Provide migration path in documentation
4. Consider dual-format export for transition period

### Backward Compatibility Rules
- New optional fields can be added without version bump
- Required fields cannot be removed or renamed
- Field types cannot change
- Breaking changes require version increment

## Import Behavior

### Merge Strategy
Current implementation uses **replace** strategy:
- All existing habits are removed
- Imported habits become the new dataset
- Previous data is lost unless backed up

### Alternative: Merge by ID
Future versions may support:
- Keep existing habits not in import file
- Update habits with matching IDs
- Add new habits from import file
- Conflict resolution UI for duplicate titles

## File Naming Convention

Recommended filename format:
```
daily_routine_backup_YYYYMMDD_HHmmss.json
```

Example:
```
daily_routine_backup_20251212_103000.json
```

## Security Considerations

- Backup files contain plaintext habit data
- No encryption in V1
- Users should store backups securely
- Consider adding encryption in V2 if needed

## Usage

### Export
1. User clicks "Export Backup" in settings
2. App generates JSON according to this format
3. File downloads to user's device

### Import
1. User clicks "Import Backup" in settings
2. User selects a `.json` file
3. App validates version and format
4. Data replaces current habits
5. UI refreshes to show imported data

## Error Handling

The app should handle these cases:
- **Invalid JSON**: Show "Invalid backup file format"
- **Missing version**: Show "Unsupported backup format"
- **Wrong version**: Show "Backup version {X} not supported. Please update the app."
- **Missing required fields**: Show "Backup file is corrupted or incomplete"
- **Invalid date format**: Skip invalid records, show warning
