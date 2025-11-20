# AdMob Integration Setup Guide

This document explains how to set up and configure Google AdMob in your CardMaker app.

## Overview

The app now includes a complete AdMob integration with:
- **Rewarded Ads**: Shown before exporting designs (image/PDF)
- **Interstitial Ads**: Shown after viewing a certain number of templates
- **Banner Ads**: Displayed on the home page

All ad settings are controlled via Firebase Remote Config for easy management.

## Configuration

### 1. Get Your AdMob App ID and Ad Unit IDs

1. Go to [AdMob Console](https://apps.admob.com/)
2. Create a new app or select your existing app
3. Get your **App ID** (format: `ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX`)
4. Create ad units:
   - **Rewarded Ad Unit** (for export)
   - **Interstitial Ad Unit** (for template views)
   - **Banner Ad Unit** (for home page)

### 2. Update Android Configuration

Edit `android/app/src/main/AndroidManifest.xml`:

Replace the test App ID with your actual AdMob App ID:
```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="YOUR_ACTUAL_APP_ID_HERE"/>
```

### 3. Update iOS Configuration

Edit `ios/Runner/Info.plist`:

Replace the test App ID with your actual AdMob App ID:
```xml
<key>GADApplicationIdentifier</key>
<string>YOUR_ACTUAL_APP_ID_HERE</string>
```

### 4. Configure Firebase Remote Config

In your Firebase Console, set up the Remote Config with the following JSON structure:

```json
{
  "update": {
    "current_version": "1.0.0",
    "min_supported_version": "1.0.0",
    "update_url": "https://play.google.com/store/apps/details?id=com.inkkaro.app",
    "isForce_update": false,
    "isUpdate_available": false,
    "update_desc": "",
    "new_features": []
  },
  "ads": {
    "enabled": true,
    "rewarded_ad_unit_id": "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX",
    "interstitial_ad_unit_id": "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX",
    "banner_ad_unit_id": "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX",
    "interstitial_ad_interval": 5,
    "show_rewarded_ad_on_export": true,
    "show_interstitial_ad_on_template_view": true,
    "show_banner_ad": true
  }
}
```

**Remote Config Parameters:**
- `enabled`: Enable/disable all ads (default: `false`)
- `rewarded_ad_unit_id`: Your rewarded ad unit ID
- `interstitial_ad_unit_id`: Your interstitial ad unit ID
- `banner_ad_unit_id`: Your banner ad unit ID
- `interstitial_ad_interval`: Show interstitial ad after N template views (default: `5`)
- `show_rewarded_ad_on_export`: Show rewarded ad before export (default: `true`)
- `show_interstitial_ad_on_template_view`: Show interstitial ad after template views (default: `true`)
- `show_banner_ad`: Show banner ad on home page (default: `true`)

## How It Works

### Rewarded Ads
- Triggered when user tries to export a design (image or PDF)
- User must watch the ad to proceed with export
- If ad fails to load, export is still allowed (user-friendly fallback)

### Interstitial Ads
- Tracked when user views templates
- Shown after viewing N templates (configurable via `interstitial_ad_interval`)
- Counter resets after showing an ad

### Banner Ads
- Displayed on the home page after the Categories section
- Automatically hidden if ads are disabled or fail to load

## Testing

### Test Ad Unit IDs (for development)

The app uses Google's test ad unit IDs by default when actual IDs are not configured:

- **Rewarded**: `ca-app-pub-3940256099942544/5224354917`
- **Interstitial**: `ca-app-pub-3940256099942544/1033173712`
- **Banner**: `ca-app-pub-3940256099942544/6300978111`

⚠️ **Important**: Replace these with your actual ad unit IDs before publishing to production!

## Best Practices

1. **User Experience**: 
   - Ads are shown at natural breakpoints (export, template viewing)
   - Export is still allowed if ads fail to load
   - Banner ad is non-intrusive

2. **Earnings Optimization**:
   - Rewarded ads have higher eCPM (earnings per thousand impressions)
   - Interstitial ads shown at reasonable intervals (not too frequent)
   - Banner ad placed where users naturally pause

3. **Remote Config Benefits**:
   - Enable/disable ads without app update
   - Adjust ad frequency remotely
   - A/B test different ad placements

## Troubleshooting

### Ads not showing?
1. Check if `enabled` is set to `true` in Remote Config
2. Verify ad unit IDs are correct
3. Check AdMob console for ad serving status
4. Ensure app is connected to internet

### Ads showing test ads?
- Replace test ad unit IDs with your actual IDs in Remote Config

### App crashes on ad load?
- Check AndroidManifest.xml and Info.plist have correct App ID
- Verify `google_mobile_ads` package is properly installed
- Check device logs for specific error messages

## Files Modified

- `lib/services/admob_service.dart` - Main ad service
- `lib/models/config_model.dart` - Added AdMobConfig model
- `lib/services/remote_config.dart` - Added ad config to remote config
- `lib/app/features/editor/controller.dart` - Integrated rewarded ads
- `lib/app/features/home/category_templates/controller.dart` - Integrated interstitial ads
- `lib/app/features/home/home.dart` - Added banner ad widget
- `lib/widgets/common/banner_ad_widget.dart` - Banner ad widget
- `lib/main.dart` - Initialize AdMob service
- `android/app/src/main/AndroidManifest.xml` - Added AdMob App ID
- `ios/Runner/Info.plist` - Added AdMob App ID
- `pubspec.yaml` - Added `google_mobile_ads` package

## Next Steps

1. Get your AdMob App ID and ad unit IDs
2. Update AndroidManifest.xml and Info.plist with your App ID
3. Configure Firebase Remote Config with your ad unit IDs
4. Test the integration
5. Publish and monitor earnings in AdMob console

## Support

For AdMob-specific issues, refer to:
- [AdMob Documentation](https://developers.google.com/admob)
- [Flutter AdMob Plugin](https://pub.dev/packages/google_mobile_ads)

