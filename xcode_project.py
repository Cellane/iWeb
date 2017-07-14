#!/usr/bin/env python
from pbxproj import XcodeProject, PBXShellScriptBuildPhase
import subprocess
import sys
import os

process = subprocess.Popen("vapor xcode -n", shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)

while True:
	nextline = process.stdout.readline()

	if nextline == '' and process.poll() is not None:
		break

	sys.stdout.write(nextline)
	sys.stdout.flush()

output = process.communicate()[0]
exitCode = process.returncode

if exitCode != 0:
	raise RuntimeError("Vapor/SPM was unable to regenerate Xcode project.")

possible_projects = [f for f in os.listdir(".") if os.path.isdir(f) and f.endswith("xcodeproj")]

if len(possible_projects) == 0:
	raise RuntimeError("Unable to find Xcode project to add build phase to.")

if len(possible_projects) > 1:
	raise RuntimeError("Multiple Xcode projects found in current directory, unsure which one to modify.")

project_full_path = os.path.join(os.getcwd(), possible_projects[0], 'project.pbxproj')
project = XcodeProject.load(project_full_path)
script = """if which swiftlint >/dev/null; then
  swiftlint
else
  echo "Error: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
  exit 1
fi
"""

project.add_run_script(script, "App")
project.save()
subprocess.call(["open", os.path.split(project_full_path)[0]])
