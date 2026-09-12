param(
  [string]$DeviceId,
  [switch]$Clean
)

$ErrorActionPreference = "Stop"

if ($Clean) {
  flutter clean
}

flutter test test/widget_test.dart

if ([string]::IsNullOrWhiteSpace($DeviceId)) {
  Write-Host "Aucun device Android fourni. Exemple :"
  Write-Host "  powershell -File scripts/run_android_integration_tests.ps1 -DeviceId emulator-5554"
  exit 0
}

flutter test integration_test -d $DeviceId
