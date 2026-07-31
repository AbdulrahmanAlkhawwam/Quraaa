$ErrorActionPreference = 'Stop'

$files = @(
  @{
    Path = 'assets\translations\en.json'
    Title = '    "title": "Edit Profile",'
    Fields = @'
    "title": "Edit Profile",
    "first_name": "First name",
    "last_name": "Last name",
    "phone_read_only": "The phone number cannot be changed here.",
    "interests": "Interests",
    "required": "This field is required.",
'@
  },
  @{
    Path = 'assets\translations\ar.json'
    Title = '    "title": "\u062a\u0639\u062f\u064a\u0644 \u0627\u0644\u0645\u0644\u0641 \u0627\u0644\u0634\u062e\u0635\u064a",'
    Fields = @'
    "title": "\u062a\u0639\u062f\u064a\u0644 \u0627\u0644\u0645\u0644\u0641 \u0627\u0644\u0634\u062e\u0635\u064a",
    "first_name": "الاسم الأول",
    "last_name": "اسم العائلة",
    "phone_read_only": "لا يمكن تعديل رقم الهاتف من هذه الشاشة.",
    "interests": "الاهتمامات",
    "required": "هذا الحقل مطلوب.",
'@
  }
)

foreach ($item in $files) {
  $json = Get-Content -Raw -LiteralPath $item.Path
  if (-not $json.Contains('"phone_read_only"')) {
    $json = $json.Replace($item.Title, $item.Fields.TrimEnd())
    Set-Content -LiteralPath $item.Path -Value $json -NoNewline
  }
}
