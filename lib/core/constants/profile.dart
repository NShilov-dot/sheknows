/// Maximum length of a display name (after trim), enforced by the editor.
/// `profiles.display_name` has no check constraint yet; add one in a migration
/// and keep the two in sync.
const int kDisplayNameMaxLength = 50;
