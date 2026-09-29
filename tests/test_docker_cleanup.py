import os
from pathlib import Path
import subprocess
import unittest


SCRIPT = Path(__file__).resolve().parents[1] / "macos/.local/bin/docker-cleanup"
SOURCE = SCRIPT.read_text()
# Exercise the installed function without executing cleanup or contacting Docker.
ACTIVE_BUILDS = SOURCE[SOURCE.index("active_builds() {"):SOURCE.index("\nrequire_idle_builder() {")]
HARNESS = r'''
pgrep() {
  printf '%s\n' "$TEST_PROCESS" | grep -E -- "$2" >/dev/null
}
docker() {
  [ "$*" = "buildx history ls --filter status=running --format {{.Name}}" ] || exit 99
  printf '%s' "$TEST_HISTORY"
}
'''


class ActiveBuildsTests(unittest.TestCase):
    def detect(self, process="", history=""):
        result = subprocess.run(
            ["/bin/sh", "-c", HARNESS + ACTIVE_BUILDS + "\nactive_builds\n"],
            env={**os.environ, "TEST_PROCESS": process, "TEST_HISTORY": history},
            capture_output=True,
            text=True,
        )
        self.assertIn(result.returncode, (0, 1), result.stderr)
        return result.returncode == 0

    def test_build_commands_are_active(self):
        for process in (
            "docker build .",
            "/usr/local/bin/docker build --tag test .",
            "docker buildx build .",
            "/usr/local/bin/docker-buildx buildx build .",
            "docker\tbuild\t.",
            "docker build",
        ):
            with self.subTest(process=process):
                self.assertTrue(self.detect(process))

    def test_non_build_commands_are_idle(self):
        for process in (
            "",
            "docker buildx prune --all",
            "docker-buildx buildx prune --all",
            "docker buildx history ls",
            "docker builder prune",
            "docker buildx inspect",
            "docker building",
            "notdocker build .",
        ):
            with self.subTest(process=process):
                self.assertFalse(self.detect(process))

    def test_running_history_still_blocks_cleanup(self):
        self.assertTrue(self.detect("docker buildx prune --all", "remote-build"))


if __name__ == "__main__":
    unittest.main()
