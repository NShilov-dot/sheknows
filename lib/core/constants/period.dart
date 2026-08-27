/// Maximum allowed length for period notes (after trim).
/// Keep in sync with the `period_logs.notes` check constraint in Supabase
/// migrations.
const int kPeriodNotesMaxLength = 500;

/// Maximum allowed length for a day log's note (after trim).
/// Keep in sync with the `day_logs.notes` check constraint in Supabase
/// migrations.
const int kDayNotesMaxLength = 300;
