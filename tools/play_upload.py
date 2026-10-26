#!/usr/bin/env python3
"""Upload an Android App Bundle to Google Play via the Play Developer API.

One-time setup
--------------
1. Create a Google Cloud project and enable "Google Play Android Developer API".
2. Create a service account and download its JSON key.
3. In Play Console -> Users and permissions -> API access, link the project and
   give the service account "Release to testing tracks" (or Admin) for the app.
4. Save the JSON key to secrets/play-service-account.json

Usage
-----
    python tools/play_upload.py --check
    python tools/play_upload.py --aab build/DALBEAR.aab --track internal \
        --notes "v1.25.1 - chapter expansion"

The script creates an edit, uploads the bundle, attaches it to the track with
status "completed", and commits the edit.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

from google.oauth2 import service_account
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError
from googleapiclient.http import MediaFileUpload

SCOPES = ["https://www.googleapis.com/auth/androidpublisher"]
DEFAULT_PACKAGE = "com.dalbear.earthdefense"
DEFAULT_CREDENTIALS = Path("secrets/play-service-account.json")

DEFAULT_NOTES = {
    "ko-KR": (
        "v1.25.4 업데이트\n"
        "- 장비 인벤토리가 넘칠 때 터치 스와이프로 스크롤할 수 있도록 수정\n"
        "- 아이템을 슬롯 위로 끌면 기존처럼 드래그 장착\n"
        "- 챕터 전장 선택 창의 닫기 버튼이 잘리던 문제 수정"
    ),
    "en-US": (
        "v1.25.4 update\n"
        "- Inventory can now be scrolled with a touch swipe when it overflows\n"
        "- Dragging an item onto a slot still equips it\n"
        "- Fixed the chapter stage picker close button being clipped"
    ),
}


def fail(message: str, code: int = 1) -> "NoReturn":
    print(f"ERROR: {message}", file=sys.stderr)
    raise SystemExit(code)


def load_service(credentials_path: Path, package: str):
    if not credentials_path.is_file():
        fail(
            f"credentials not found: {credentials_path}\n"
            "Create a service account key and save it there (see the docstring)."
        )
    try:
        creds = service_account.Credentials.from_service_account_file(
            str(credentials_path), scopes=SCOPES
        )
        return build("androidpublisher", "v3", credentials=creds, cache_discovery=False)
    except Exception as exc:  # noqa: BLE001 - surface a readable setup error
        fail(f"could not authenticate with {credentials_path}: {exc}")


def explain_http_error(exc: HttpError, package: str) -> str:
    status = getattr(exc.resp, "status", "?")
    detail = exc.content.decode("utf-8", "replace") if exc.content else ""
    hints = {
        401: "The service account key is invalid or the API is not enabled.",
        403: (
            "The service account has no access to this app. In Play Console -> "
            "Users and permissions -> Invite new users, invite the service account "
            "email and grant 'Release to testing tracks' for this app."
        ),
        404: f"App '{package}' was not found or is not accessible to this account.",
    }
    hint = hints.get(status, "")
    return f"HTTP {status}: {hint}\n{detail}".strip()


def new_edit(service, package: str) -> str:
    return service.edits().insert(packageName=package, body={}).execute()["id"]


def cmd_check(service, package: str) -> None:
    edit_id = new_edit(service, package)
    try:
        tracks = service.edits().tracks().list(
            packageName=package, editId=edit_id
        ).execute().get("tracks", [])
        bundles = service.edits().bundles().list(
            packageName=package, editId=edit_id
        ).execute().get("bundles", [])
        print(f"OK  package={package}")
        print(f"    accessible tracks: {', '.join(t['track'] for t in tracks) or '(none)'}")
        versions = sorted({b["versionCode"] for b in bundles})
        print(f"    bundles in library: {versions or '(none)'}")
    finally:
        service.edits().delete(packageName=package, editId=edit_id).execute()


def cmd_upload(
    service,
    package: str,
    aab: Path,
    track: str,
    status: str,
    notes: dict[str, str] | None,
    release_name: str | None,
) -> None:
    if not aab.is_file():
        fail(f"AAB not found: {aab}")

    print(f"-> creating edit for {package}")
    edit_id = new_edit(service, package)
    committed = False
    try:
        print(f"-> uploading {aab.name} ({aab.stat().st_size / 1024 / 1024:.1f} MiB)")
        media = MediaFileUpload(
            str(aab), mimetype="application/octet-stream", resumable=True
        )
        bundle = service.edits().bundles().upload(
            packageName=package, editId=edit_id, media_body=media
        ).execute()
        version_code = str(bundle["versionCode"])
        print(f"   uploaded versionCode={version_code}")

        release = {
            "versionCodes": [version_code],
            "status": status,
        }
        if release_name:
            release["name"] = release_name
        if notes:
            release["releaseNotes"] = [
                {"language": lang, "text": text} for lang, text in notes.items()
            ]

        print(f"-> assigning versionCode {version_code} to track '{track}' ({status})")
        service.edits().tracks().update(
            packageName=package,
            editId=edit_id,
            track=track,
            body={"releases": [release]},
        ).execute()

        print("-> committing edit")
        service.edits().commit(packageName=package, editId=edit_id).execute()
        committed = True
        print(f"DONE  {package} versionCode {version_code} -> {track} ({status})")
    finally:
        if not committed:
            try:
                service.edits().delete(packageName=package, editId=edit_id).execute()
                print("   rolled back uncommitted edit")
            except Exception:  # noqa: BLE001 - best effort cleanup
                pass


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--package", default=DEFAULT_PACKAGE)
    parser.add_argument("--credentials", type=Path, default=DEFAULT_CREDENTIALS)
    parser.add_argument("--check", action="store_true", help="only verify access and list tracks")
    parser.add_argument("--aab", type=Path, default=Path("build/DALBEAR.aab"))
    parser.add_argument("--track", default="internal", help="track id (default: internal)")
    parser.add_argument(
        "--status",
        default="completed",
        choices=["draft", "inProgress", "halted", "completed"],
        help="release status (default: completed)",
    )
    parser.add_argument("--name", default=None, help="optional release name")
    parser.add_argument("--notes", default=None, help="single release note (ko-KR)")
    parser.add_argument("--notes-file", type=Path, default=None, help="JSON file of {lang: text}")
    args = parser.parse_args()

    service = load_service(args.credentials, args.package)
    try:
        if args.check:
            cmd_check(service, args.package)
            return

        if args.notes_file:
            notes = json.loads(args.notes_file.read_text(encoding="utf-8"))
        elif args.notes:
            notes = {"ko-KR": args.notes}
        else:
            notes = DEFAULT_NOTES

        cmd_upload(
            service,
            args.package,
            args.aab,
            args.track,
            args.status,
            notes,
            args.name,
        )
    except HttpError as exc:
        fail(explain_http_error(exc, args.package))


if __name__ == "__main__":
    main()
