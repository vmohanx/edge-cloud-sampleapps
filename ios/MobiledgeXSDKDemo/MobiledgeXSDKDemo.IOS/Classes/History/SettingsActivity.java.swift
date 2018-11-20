//package com.mobiledgex.sdkdemo;
//
//import android.annotation.TargetApi;
//import android.content.Context;
//import android.content.Intent;
//import android.content.res.Configuration;
//import android.os.Build;
//import android.os.Bundle;
//import android.preference.ListPreference;
//import android.preference.Preference;
//import android.preference.PreferenceActivity;
//import android.preference.PreferenceFragment;
//import android.preference.PreferenceManager;
//import android.support.v7.app.ActionBar;
//import android.view.MenuItem;
//
//import java.util.List;

/**
 * A {@link PreferenceActivity} that presents a set of application settings. On
 * handset devices, settings are presented as a single list. On tablets,
 * settings are split by category, with category headers shown to the left of
 * the list of settings.
 * <p>
 * See <a href="http://developer.android.com/design/patterns/settings.html">
 * Android Design: Settings</a> for design guidelines and the <a
 * href="http://developer.android.com/guide/topics/ui/settings.html">Settings
 * API Guide</a> for more information on developing a Settings UI.
 */
public class SettingsActivity
    // JT 18.10.23 todo
//extends AppCompatPreferenceActivity
{


    /**
     * A preference value change listener that updates the preference's summary
     * to reflect its new value.
     */
//    private static  let Preference.OnPreferenceChangeListener: BindPreferenceSummaryToValueListener =  Preference.OnPreferenceChangeListener()

    public func onPreferenceChange(_ preference: Preference, _ value: Object) ->Bool
    {
    let stringValue:String = value.toString();

            if (preference instanceof ListPreference) {
                // For list preferences, look up the correct display value in
                // the preference's 'entries' list.
                ListPreference listPreference = (ListPreference) preference;
                int index = listPreference.findIndexOfValue(stringValue);

                // Set the summary to reflect the new value.
                preference.setSummary(
                        index >= 0
                                ? listPreference.getEntries()[index]
                                : null);
            } else {
                // For all other preferences, set the summary to the value's
                // simple string representation.
                preference.setSummary(stringValue);
            }
            return true;
        }
    

    /**
     * Helper method to determine if the device has an extra-large screen. For
     * example, 10" tablets are extra-large.
     */
    private static func isXLargeTablet(_ context: Context) ->Bool {
        return (context.getResources().getConfiguration().screenLayout
                & Configuration.SCREENLAYOUT_SIZE_MASK) >= Configuration.SCREENLAYOUT_SIZE_XLARGE;
    }

    /**
     * Binds a preference's summary to its value. More specifically, when the
     * preference's value is changed, its summary (line of text below the
     * preference title) is updated to reflect the value. The summary is also
     * immediately updated upon calling this method. The exact display format is
     * dependent on the type of preference.
     *
     * @see #sBindPreferenceSummaryToValueListener
     */
    private static func bindPreferenceSummaryToValue(_ preference: Preference) {
        // Set the listener to watch for value changes.
        preference.setOnPreferenceChangeListener(sBindPreferenceSummaryToValueListener);

        // Trigger the listener immediately with the preference's
        // current value.
        sBindPreferenceSummaryToValueListener.onPreferenceChange(preference,
                PreferenceManager
                        .getDefaultSharedPreferences(preference.getContext())
                        .getString(preference.getKey(), ""));
    }

    
    func  onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setupActionBar();
    }

    /**
     * Set up the {@link android.app.ActionBar}, if the API is available.
     */
    private func setupActionBar() {
        let actionBar: ActionBar = getSupportActionBar();
        if (actionBar != null) {
            // Show the Up button in the action bar.
            actionBar.setDisplayHomeAsUpEnabled(true);
        }
    }

    /**
     * This is needed for the Back Arrow button to work on Android version 6.
     * @param item
     * @return
     */
    
    public func onOptionsItemSelected(_ item: MenuItem) ->Bool {
        let id:Int = item.getItemId();
        if (id == android.R.id.home) {
            finish();
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    /**
     * {@inheritDoc}
     */
    
    public func onIsMultiPane() ->Bool {
        return isXLargeTablet(self);
    }

    /**
     * {@inheritDoc}
     */
    
   // @TargetApi(Build.VERSION_CODES.HONEYCOMB)
    public func onBuildHeaders(_ target: [PreferenceActivity.Header])  // List<PreferenceActivity.Header>
    {
        loadHeadersFromResource(R.xml.pref_headers, target);
    }

    /**
     * This method stops fragment injection in malicious applications.
     * Make sure to deny any unknown fragments here.
     */
    func  isValidFragment(_ fragmentName: String) ->Bool {
        return PreferenceFragment.class.getName().equals(fragmentName)
                || LocationSettingsFragment.class.getName().equals(fragmentName)
                || GeneralSettingsFragment.class.getName().equals(fragmentName)
                || FaceDetectionSettingsFragment.class.getName().equals(fragmentName)
                || SpeedTestSettingsFragment.class.getName().equals(fragmentName);
    }

    // Mex Enhanced Location Preference.
    public  class LocationSettingsFragment
            // JT 18.10.23 todo
    //extends PreferenceFragment
{
    
        public func onCreate(_ savedInstanceState: Bundle)
        {
            super.onCreate(savedInstanceState);
            addPreferencesFromResource(R.xml.location_preferences);
            setHasOptionsMenu(true);
        }

    
        public func onOptionsItemSelected( item: MenuItem) -> Bool
    {
        let id: Int = item.getItemId();
            if (id == android.R.id.home) {
                startActivity( Intent(getActivity(), SettingsActivity.class));
                return true;
            }
            return super.onOptionsItemSelected(item);
        }
    }

    // Speed Test Preferences.
    public  class SpeedTestSettingsFragment
            // JT 18.10.23 todo
    //extends PreferenceFragment
{
    
        public  func onCreate( savedInstanceState: Bundle) {
            super.onCreate(savedInstanceState);
            addPreferencesFromResource(R.xml.pref_speed_test);
            setHasOptionsMenu(true);
        }

    
        public func onOptionsItemSelected(_ item: MenuItem) ->Bool
    {
            let id = item.getItemId();
            if (id == android.R.id.home) {
                startActivity( Intent(getActivity(), SettingsActivity.class));
                return true;
            }
            return super.onOptionsItemSelected(item);
        }
    }

    // General Preferences.
    public  class GeneralSettingsFragment
            // JT 18.10.23 todo
    // extends PreferenceFragment
{
    
        public func onCreate(_ savedInstanceState: Bundle)
        {
            super.onCreate(savedInstanceState);
            addPreferencesFromResource(R.xml.pref_general);
            setHasOptionsMenu(true);
        }

    
        public func onOptionsItemSelected(_ item: MenuItem) ->Bool {
            let id = item.getItemId();
            if (id == android.R.id.home) {
                startActivity( Intent(getActivity(), SettingsActivity.class));
                return true;
            }
            return super.onOptionsItemSelected(item);
        }
    }

    // Face Detection Preferences.
    public  class FaceDetectionSettingsFragment
            // JT 18.10.23 todo
    //extends PreferenceFragment
{
    
        public func onCreate(Bundle savedInstanceState)
    {
            super.onCreate(savedInstanceState);
            addPreferencesFromResource(R.xml.pref_face_detection);
            setHasOptionsMenu(true);
        }

    
        public func onOptionsItemSelected( item: MenuItem) ->Bool
        {
            let id:Int = item.getItemId();
            if (id == android.R.id.home) {
                startActivity( Intent(getActivity(), SettingsActivity.class));
                return true;
            }
            return super.onOptionsItemSelected(item);
        }
    }

    // TODO: Implement this
    // About Preferences.
    public  class AboutFragment
            // JT 18.10.23 todo
    //extends PreferenceFragment
    {
    
        public func  onCreate(_ savedInstanceState: Bundle) {
            super.onCreate(savedInstanceState);
            addPreferencesFromResource(R.xml.pref_speed_test);
            setHasOptionsMenu(true);
        }

    
        public func onOptionsItemSelected(_ item: MenuItem) ->Bool
        {
            let id:Int = item.getItemId();
            if (id == android.R.id.home) {
                startActivity( Intent(getActivity(), SettingsActivity.class));
                return true;
            }
            return super.onOptionsItemSelected(item);
        }
    }
}
