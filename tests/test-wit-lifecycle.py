from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def source(path: str) -> str:
    return (ROOT / path).read_text()


app_delegate = source("Arlo/AppDelegate.swift")
recording = source("Pods/Wit/Wit/WITRecordingSession.m")
recording_header = source("Pods/Wit/Wit/WITRecordingSession.h")
uploader = source("Pods/Wit/Wit/WITUploader.m")
context_setter = source("Pods/Wit/Wit/WITContextSetter.m")
wit = source("Pods/Wit/Wit/Wit.m")
pod_project = source("Pods/Pods.xcodeproj/project.pbxproj")

assert "setActive(true)" not in app_delegate, "launch must not reserve the microphone session"
assert "witAccessToken.characters.count <= 4096" in app_delegate, "configuration must bound token size"
assert "CharacterSet.whitespacesAndNewlines" in app_delegate, "configuration must reject whitespace-bearing tokens"
assert "CharacterSet.controlCharacters" in app_delegate, "configuration must reject control-bearing tokens"
assert "WITIsValidAccessToken(witToken)" in recording, "capture must reject malformed tokens before audio allocation"
assert "setActive:YES" in recording, "capture must activate audio immediately before recorder allocation"
assert recording.count("setActive:NO") == 2, "start failure and recording stop must deactivate the audio session"
assert "self.stopped" in recording, "recording stop must be idempotent"
assert "-(BOOL)start" in recording, "recording must begin only after its owner stores the session"
assert "if (![self.recordingSession start])" in wit, "Wit must explicitly start its owned session"
assert wit.index("self.recordingSession = [[WITRecordingSession alloc]") < wit.index("[self.recordingSession start]"), "session ownership must precede callbacks"
response_body = recording.split("-(void)gotResponse:(NSDictionary*)resp error:(NSError*)err {", 1)[1].split("#pragma mark", 1)[0]
assert response_body.index("if (err)") < response_body.index("[self stop]") < response_body.index("[self.delegate recordingSession:self gotResponse"), "network failure must emit stop while session ownership is still current"

assert "recordingSession:(WITRecordingSession *)session" in recording_header
assert "guardCurrentRecordingSession" in wit, "stale recording-session callbacks must be rejected"
assert "session != self.recordingSession" in wit

assert "requestGeneration" in uploader, "uploader completions need explicit ownership generations"
assert "while (offset < chunk.length)" in uploader, "audio chunks must handle partial stream writes"
assert "written <= 0" in uploader, "failed or stalled writes must fail closed"
assert "WITURLByAppendingQueryItems" in uploader, "context must be appended as one encoded query item"
assert "WITJSONObjectFromResponse" in uploader, "speech responses need status, size, MIME, and JSON validation"
assert "WITSanitizedTransportError" in uploader, "transport diagnostics must strip nested URLs and payloads"
assert "WITIsValidAccessToken(token)" in uploader, "authorization headers need strict token validation"

assert "requestWhenInUseAuthorization" not in context_setter, "voice capture must not prompt for undeclared location access"
assert "startMonitoringSignificantLocationChanges" not in context_setter, "voice capture must not start background location monitoring"
assert "setObject:locationData" not in context_setter, "voice requests must not silently attach device coordinates"

assert "WITJSONObjectFromResponse" in wit, "text interpretation needs the same response policy"
assert "WITOutcomesFromJSONObject" in wit, "intent delivery must validate semantic JSON shape"
assert wit.count("if (connectionError) {") == 1, "text interpretation must not contain the duplicated broken guard"
stop_body = wit.split("- (void)stop{", 1)[1].split("}", 1)[0]
assert "self.recordingSession = nil" not in stop_body, "stopping capture must retain ownership until the response arrives"
assert "self.recordingSession = nil" in wit.split("gotResponse:(NSDictionary *)resp", 1)[1], "response completion must release the owned session"

assert pod_project.count("WITHTTPPolicy.m in Sources") == 2, "the native app target must compile the policy boundary"
