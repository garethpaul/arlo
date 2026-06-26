import subprocess
import sys
import tempfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
TEMP_ROOT = ROOT / ".test-tmp"
TEMP_ROOT.mkdir(exist_ok=True)

MUTATIONS = (
    ("Arlo/AppDelegate.swift", "configureWit()", "setActive(true)"),
    ("Arlo/ViewController.swift", "strongSelf.talker.stopSpeaking(at: .immediate)\n            strongSelf.applyRecordingState(true)", "strongSelf.applyRecordingState(true)"),
    ("Pods/Wit/Wit/WITRecordingSession.m", "WITIsValidAccessToken(witToken)", "witToken != nil"),
    ("Pods/Wit/Wit/WITRecordingSession.m", "setActive:NO", "setActive:YES"),
    ("Pods/Wit/Wit/Wit.m", "session != self.recordingSession", "session == self.recordingSession"),
    ("Pods/Wit/Wit/WITUploader.m", "WITSanitizedTransportError(connectionError)", "connectionError"),
    ("Pods/Wit/Wit/WITUploader.m", "WITJSONObjectFromResponse(response, data, &responseError)", "[NSJSONSerialization JSONObjectWithData:data options:0 error:&responseError]"),
    ("Pods/Wit/Wit/WITHTTPPolicy.m", 'NSString *rawMediaType = [contentType componentsSeparatedByString:@";"][0];', 'NSString *rawMediaType = [contentType componentsSeparatedByString:@";"][0].lowercaseString;'),
    ("Pods/Wit/Wit/WITHTTPPolicy.m", "if (!WITIsRestrictedName(subtype))", "if (NO)"),
    ("Pods/Wit/Wit/WITHTTPPolicy.m", "name.length > 127", "name.length > 128"),
    ("Pods/Wit/Wit/WITHTTPPolicy.m", "!WITIsASCIIAlphaNumeric([name characterAtIndex:0]) ||", "NO ||"),
    ("Pods/Wit/Wit/WITHTTPPolicy.m", "!WITIsASCIIAlphaNumeric([name characterAtIndex:name.length - 1]))", "NO)"),
    ("Pods/Wit/Wit/WITHTTPPolicy.m", "character == '_' || character == '.' || character == '+';", "character == '_' || character == '.' || character == '+' || character > 0x7f;"),
    ("Pods/Wit/Wit/WITHTTPPolicy.m", "WITASCIILowercase([value characterAtIndex:index])", "[value characterAtIndex:index]"),
    ("Pods/Wit/Wit/WITHTTPPolicy.m", "return WITASCIIStringEquals([value substringFromIndex:value.length - suffix.length], suffix);", "return [value.lowercaseString hasSuffix:suffix];"),
    ("Pods/Wit/Wit/WITUploader.m", "while (offset < chunk.length)", "if (offset < chunk.length)"),
    ("Pods/Wit/Wit/Wit.m", "[self.recordingSession stop];\n}", "[self.recordingSession stop];\n    self.recordingSession = nil;\n}"),
    ("Pods/Wit/Wit/WITContextSetter.m", "[self ensureReferenceTime:context];", "[locationManager requestWhenInUseAuthorization];\n    [self ensureReferenceTime:context];"),
    ("Pods/Wit/Wit/WITRecordingSession.m", "[self stop];\n    }\n\n    [self.delegate recordingSession:self gotResponse", "[self.delegate recordingSession:self gotResponse"),
    ("Pods/Wit/Wit/Wit.m", "WITOutcomesFromJSONObject(resp, &messageId, &responseError)", "resp[kWitKeyOutcome]"),
    ("Pods/Pods.xcodeproj/project.pbxproj", "WITHTTPPolicy.m in Sources", "WITHTTPPolicy.m omitted"),
)

FIXTURE_PATHS = {
    "Arlo/AppDelegate.swift",
    "Arlo/ViewController.swift",
    "Pods/Wit/Wit/WITRecordingSession.m",
    "Pods/Wit/Wit/WITRecordingSession.h",
    "Pods/Wit/Wit/WITUploader.m",
    "Pods/Wit/Wit/WITHTTPPolicy.m",
    "Pods/Wit/Wit/WITHTTPPolicy.h",
    "Pods/Wit/Wit/WITContextSetter.m",
    "Pods/Wit/Wit/Wit.m",
    "Pods/Pods.xcodeproj/project.pbxproj",
    "tests/test-wit-lifecycle.py",
    "tests/test-wit-http-policy.m",
    "scripts/test-wit-http-policy.sh",
}


for relative_path, old, new in MUTATIONS:
    with tempfile.TemporaryDirectory(prefix="arlo-wit-mutation-", dir=TEMP_ROOT) as temporary:
        checkout = Path(temporary) / "repo"
        for fixture_path in FIXTURE_PATHS:
            destination = checkout / fixture_path
            destination.parent.mkdir(parents=True, exist_ok=True)
            destination.write_bytes((ROOT / fixture_path).read_bytes())
        path = checkout / relative_path
        content = path.read_text()
        if old not in content:
            raise AssertionError(f"mutation target missing: {relative_path}: {old}")
        path.write_text(content.replace(old, new, 1))
        lifecycle_result = subprocess.run(
            [sys.executable, "-I", "-B", str(checkout / "tests/test-wit-lifecycle.py")],
            cwd=checkout,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        native_result = subprocess.run(
            ["/bin/sh", str(checkout / "scripts/test-wit-http-policy.sh")],
            cwd=checkout,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        if lifecycle_result.returncode == 0 and native_result.returncode == 0:
            raise AssertionError(f"mutation survived: {relative_path}: {old}")
