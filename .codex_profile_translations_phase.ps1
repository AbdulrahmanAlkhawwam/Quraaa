$ErrorActionPreference = 'Stop'

$constantsPath = 'lib\core\localization\localization_constants.dart'
$constants = Get-Content -Raw -LiteralPath $constantsPath
if (-not $constants.Contains('profileEditFirstNameKey')) {
  $needle = "  static const String profileEditFullNameKey = 'edit_profile.full_name';"
  $addition = $needle + @'

  static const String profileEditFirstNameKey = 'edit_profile.first_name';
  static const String profileEditLastNameKey = 'edit_profile.last_name';
  static const String profileEditPhoneReadOnlyKey =
      'edit_profile.phone_read_only';
  static const String profileEditInterestsKey = 'edit_profile.interests';
  static const String profileEditRequiredKey = 'edit_profile.required';
'@
  $constants = $constants.Replace($needle, $addition)
}
if (-not $constants.Contains('profileLocationsTitleKey')) {
  $needle = "  static const String profileMenuLocationsKey = 'profile.menu.my_locations';"
  $addition = $needle + @'

  static const String profileLocationsTitleKey = 'profile_location.title';
  static const String profileLocationAddKey = 'profile_location.add';
  static const String profileLocationNewKey = 'profile_location.new';
  static const String profileLocationCurrentKey = 'profile_location.current';
  static const String profileLocationEmptyKey = 'profile_location.empty';
  static const String profileLocationUseCurrentKey =
      'profile_location.use_current';
  static const String profileLocationSavedKey = 'profile_location.saved';
  static const String profileLocationDeleteKey = 'profile_location.delete';
  static const String profileLocationDeleteTitleKey =
      'profile_location.delete_title';
  static const String profileLocationDeleteMessageKey =
      'profile_location.delete_message';
  static const String profileLocationServiceDisabledKey =
      'profile_location.service_disabled';
  static const String profileLocationPermissionDeniedKey =
      'profile_location.permission_denied';
  static const String profileLocationUnavailableKey =
      'profile_location.unavailable';
'@
  $constants = $constants.Replace($needle, $addition)
}
Set-Content -LiteralPath $constantsPath -Value $constants -NoNewline

function Update-Translation {
  param(
    [string]$Path,
    [string]$EditFields,
    [string]$LocationBlock
  )
  $json = Get-Content -Raw -LiteralPath $Path
  if (-not $json.Contains('"first_name"')) {
    $json = $json.Replace(
      '    "personal_data":',
      $EditFields + "`r`n    " + '"personal_data":'
    )
  }
  if (-not $json.Contains('"profile_location"')) {
    $json = $json.Replace(
      '  "assistant": {',
      $LocationBlock + "`r`n  " + '"assistant": {'
    )
  }
  Set-Content -LiteralPath $Path -Value $json -NoNewline
}

$enEdit = @'
    "first_name": "First name",
    "last_name": "Last name",
    "phone_read_only": "The phone number cannot be changed here.",
    "interests": "Interests",
    "required": "This field is required.",
'@
$enLocation = @'
  "profile_location": {
    "title": "My Location",
    "add": "Add location",
    "new": "New Location",
    "current": "My current location",
    "empty": "No location is saved yet.",
    "use_current": "Use my current location",
    "saved": "Your location was saved.",
    "delete": "Delete",
    "delete_title": "Delete location?",
    "delete_message": "This will remove your saved location from your account.",
    "service_disabled": "Location services are disabled.",
    "permission_denied": "Location permission was denied.",
    "unavailable": "Your current location could not be determined."
  },
'@

$arEdit = @'
    "first_name": "الاسم الأول",
    "last_name": "اسم العائلة",
    "phone_read_only": "لا يمكن تعديل رقم الهاتف من هذه الشاشة.",
    "interests": "الاهتمامات",
    "required": "هذا الحقل مطلوب.",
'@
$arLocation = @'
  "profile_location": {
    "title": "موقعي",
    "add": "إضافة الموقع",
    "new": "موقع جديد",
    "current": "موقعي الحالي",
    "empty": "لا يوجد موقع محفوظ حتى الآن.",
    "use_current": "استخدام موقعي الحالي",
    "saved": "تم حفظ موقعك.",
    "delete": "حذف",
    "delete_title": "حذف الموقع؟",
    "delete_message": "سيتم حذف الموقع المحفوظ من حسابك.",
    "service_disabled": "خدمة الموقع غير مفعلة.",
    "permission_denied": "تم رفض إذن الوصول إلى الموقع.",
    "unavailable": "تعذر تحديد موقعك الحالي."
  },
'@

Update-Translation -Path 'assets\translations\en.json' -EditFields $enEdit -LocationBlock $enLocation
Update-Translation -Path 'assets\translations\ar.json' -EditFields $arEdit -LocationBlock $arLocation
