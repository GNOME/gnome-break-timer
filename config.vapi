/* This is a hand-written vapi file containing constants from config.h that
 * should be exposed to the Vala program */

[CCode (cprefix = "", lower_case_cprefix = "", cheader_filename = "config.h")]
namespace Config {
	public const string GETTEXT_PACKAGE;
	public const string PACKAGE_NAME;
	public const string PACKAGE_VERSION;
	public const string PACKAGE_URL;
	public const string VERSION;
	public const string HELPER_DESKTOP_ID;
	public const string SETTINGS_DESKTOP_ID;
}
