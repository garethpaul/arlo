import subprocess
import tempfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
TEMP_ROOT = ROOT / ".test-tmp"
TEMP_ROOT.mkdir(exist_ok=True)

MUTATIONS = (
    ("Arlo/AppDelegate.swift", "configureWit()", "setActive(true)"),
    ("Pods/Wit/Wit/WITRecordingSession.m", "WITIsValidAccessToken(witToken)", "witToken != nil"),
    ("Pods/Wit/Wit/WITRecordingSession.m", "setActive:NO", "setActive:YES"),
    ("Pods/Wit/Wit/Wit.m", "session != self.recordingSession", "session == self.recordingSession"),
    ("Pods/Wit/Wit/WITUploader.m", "WITSanitizedTransportError(connectionError)", "connectionError"),
    ("Pods/Wit/Wit/WITUploader.m", "WITJSONObjectFromResponse(response, data, &responseError)", "[NSJSONSerialization JSONObjectWithData:data options:0 error:&responseError]"),
    ("Pods/Wit/Wit/WITUploader.m", "while (offset < chunk.length)", "if (offset < chunk.length)"),
    ("Pods/Wit/Wit/Wit.m", "[self.recordingSession stop];\n}", "[self.recordingSession stop];\n    self.recordingSession = nil;\n}"),
    ("Pods/Wit/Wit/WITContextSetter.m", "[self ensureReferenceTime:context];", "[locationManager requestWhenInUseAuthorization];\n    [self ensureReferenceTime:context];"),
    ("Pods/Wit/Wit/WITRecordingSession.m", "[self stop];\n    }\n\n    [self.delegate recordingSession:self gotResponse", "[self.delegate recordingSession:self gotResponse"),
    ("Pods/Wit/Wit/Wit.m", "WITOutcomesFromJSONObject(resp, &messageId, &responseError)", "resp[kWitKeyOutcome]"),
    ("Pods/Pods.xcodeproj/project.pbxproj", "WITHTTPPolicy.m in Sources", "WITHTTPPolicy.m omitted"),
)

FIXTURE_PATHS = {
    "Arlo/AppDelegate.swift",
    "Pods/Wit/Wit/WITRecordingSession.m",
    "Pods/Wit/Wit/WITRecordingSession.h",
    "Pods/Wit/Wit/WITUploader.m",
    "Pods/Wit/Wit/WITContextSetter.m",
    "Pods/Wit/Wit/Wit.m",
    "Pods/Pods.xcodeproj/project.pbxproj",
    "tests/test-wit-lifecycle.py",
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
        result = subprocess.run(
            ["python3", str(checkout / "tests/test-wit-lifecycle.py")],
            cwd=checkout,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        if result.returncode == 0:
            raise AssertionError(f"mutation survived: {relative_path}: {old}")
