/// Maximum allowed length for a symptom log's note (after trim).
/// Keep in sync with the `symptom_logs.notes` check constraint in Supabase
/// migrations.
const int kSymptomNotesMaxLength = 300;
