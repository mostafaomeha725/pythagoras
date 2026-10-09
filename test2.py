from pathlib import Path
import re

path = Path("ios/Runner.xcodeproj/project.pbxproj")
text = path.read_text(encoding="utf-8")
settings = {
    "CODE_SIGN_STYLE": "Manual",
    "DEVELOPMENT_TEAM": "1234567890",
    "PROVISIONING_PROFILE_SPECIFIER": "My Profile",
    "CODE_SIGN_IDENTITY": "Apple Distribution",
}

pattern = re.compile(r"(buildSettings = \{)(.*?)(\n\s*\};)", re.S)

def update_block(match):
    body = match.group(2)
    if "RunnerTests" in body:
        return match.group(0)
    for key, value in settings.items():
        val_str = f'"{value}"' if ' ' in value else value
        line = f"{key} = {val_str};"
        setting_pattern = re.compile(r"(?m)^\s*" + re.escape(key) + r"\s*=.*?;")
        if setting_pattern.search(body):
            body = setting_pattern.sub(f"\n\t\t\t\t{line}", body)
        else:
            body += f"\n\t\t\t\t{line}"
    return match.group(1) + body + match.group(3)

updated, count = pattern.subn(update_block, text)
print("Updated blocks:", count)
Path("test_updated2.pbxproj").write_text(updated, encoding="utf-8")
