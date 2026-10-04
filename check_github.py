#!/usr/bin/env python3
"""
Python helper to check GitHub Actions workflow status and Releases for athar.app
"""
import urllib.request
import json
import sys

REPO = "abdessamie70-dotcom/athar"

def check_actions():
    url = f"https://api.github.com/repos/{REPO}/actions/runs"
    req = urllib.request.Request(url, headers={"User-Agent": "AtharApp/1.0"})
    try:
        with urllib.request.urlopen(req) as resp:
            data = json.loads(resp.read().decode())
            runs = data.get("workflow_runs", [])
            if not runs:
                print("No workflow runs found yet.")
                return
            print(f"Found {len(runs)} workflow run(s):")
            for r in runs[:5]:
                print(f"- Run #{r.get('run_number')}: {r.get('name')} | Status: {r.get('status')} | Conclusion: {r.get('conclusion')}")
    except urllib.error.HTTPError as e:
        print(f"HTTP Error {e.code}: {e.reason}")
        if e.code == 404:
            print("Note: The repository is private. To view runs via API, provide a GitHub Personal Access Token.")
            print("Or view them directly in your browser: https://github.com/abdessamie70-dotcom/athar.app/actions")
    except Exception as e:
        print(f"Error: {e}")

def check_releases():
    url = f"https://api.github.com/repos/{REPO}/releases"
    req = urllib.request.Request(url, headers={"User-Agent": "AtharApp/1.0"})
    try:
        with urllib.request.urlopen(req) as resp:
            data = json.loads(resp.read().decode())
            if not data:
                print("No releases published yet.")
                return
            print(f"Found {len(data)} release(s):")
            for rel in data:
                print(f"- Release: {rel.get('name')} ({rel.get('tag_name')})")
                for asset in rel.get('assets', []):
                    print(f"  * Download: {asset.get('name')} ({asset.get('browser_download_url')})")
    except urllib.error.HTTPError as e:
        print(f"HTTP Error {e.code}: {e.reason}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    print(f"=== Checking Athar App ({REPO}) ===")
    print("\n[1] Workflow Runs:")
    check_actions()
    print("\n[2] Releases:")
    check_releases()
