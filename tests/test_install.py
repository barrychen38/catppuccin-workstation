"""Exercise installer behavior without installing into the current account."""

import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


REPO = Path(__file__).resolve().parents[1]
REAL_GIT = shutil.which("git")
START = "# >>> catppuccin-workstation >>>"
END = "# <<< catppuccin-workstation <<<"


class InstallerTests(unittest.TestCase):
    def setUp(self):
        self.sandbox = tempfile.TemporaryDirectory(prefix="catppuccin-install-test-")
        self.addCleanup(self.sandbox.cleanup)
        self.root = Path(self.sandbox.name)
        self.test_home = self.root / "home"
        self.test_home.mkdir()
        self.bin_dir = self.root / "bin"
        self.bin_dir.mkdir()
        self.log = self.root / "commands.log"
        self.env = dict(os.environ)
        self.env.update(
            HOME=str(self.test_home),
            PATH=f"{self.bin_dir}:/usr/bin:/bin:/usr/sbin:/sbin",
            XDG_CONFIG_HOME=str(self.test_home / ".config"),
            GIT_CONFIG_GLOBAL=str(self.test_home / ".gitconfig"),
            GIT_CONFIG_NOSYSTEM="1",
            INSTALL_TEST_LOG=str(self.log),
            INSTALL_TEST_GIT=REAL_GIT,
            INSTALL_TEST_BREW_PREFIX=str(self.root / "Homebrew prefix"),
        )
        self.write("Library/Fonts/SourceHanSansSC-VF.ttf", "existing font")
        self.stub("uname", "printf 'Darwin\\n'\n")
        self.stub("dscl", "printf 'UserShell: /bin/zsh\\n'\n")
        self.stub("brew", '''
if [[ "${1:-}" == --prefix ]]; then
  printf '%s\n' "$INSTALL_TEST_BREW_PREFIX"
else
  printf 'brew %s\n' "$*" >> "$INSTALL_TEST_LOG"
fi
''')
        self.stub("git", '''
printf 'git %s\n' "$*" >> "$INSTALL_TEST_LOG"
if [[ "${1:-}" == clone ]]; then
  for clone_dst; do :; done
  mkdir -p "$clone_dst"
  printf '#!/bin/bash\nprintf "CLONED %%s\\n" "$*"\n' > "$clone_dst/install.sh"
elif [[ "${1:-}" != -C ]]; then
  exec "$INSTALL_TEST_GIT" "$@"
fi
''')
        self.stub("bat", '''
case "${1:-}" in
  --config-dir) printf '%s/.config/bat\n' "$HOME" ;;
  --list-themes) printf 'Catppuccin Latte\nCatppuccin Frappe\nCatppuccin Macchiato\nCatppuccin Mocha\n' ;;
  cache) printf 'bat cache\n' >> "$INSTALL_TEST_LOG" ;;
  *) exit 1 ;;
esac
''')
        self.stub("curl", '''
while [[ $# -gt 0 ]]; do
  if [[ "$1" == -o ]]; then
    printf '<plist/>\n' > "$2"
    exit 0
  fi
  shift
done
exit 1
''')
        self.stub("nvim", "printf 'nvim %s\\n' \"$*\" >> \"$INSTALL_TEST_LOG\"\n")

    def write(self, relative, content):
        path = self.test_home / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content)
        return path

    def stub(self, name, body):
        path = self.bin_dir / name
        path.write_text("#!/bin/bash\nset -eu\n" + body)
        path.chmod(0o755)

    def run_install(self, *args, stdin=False, cwd=None, succeeds=True):
        command = ["/bin/bash"]
        if stdin:
            command += ["-s", "--", *args]
        else:
            command += [str(REPO / "install.sh"), *args]
        result = subprocess.run(
            command,
            input=(REPO / "install.sh").read_text() if stdin else None,
            env=self.env,
            cwd=cwd or self.root,
            capture_output=True,
            text=True,
            timeout=20,
        )
        if succeeds:
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        else:
            self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
        return result

    def git_values(self, key):
        result = subprocess.run(
            [REAL_GIT, "config", "--global", "--includes", "--get-all", key],
            env=self.env, capture_output=True, text=True, check=True,
        )
        return result.stdout.splitlines()

    def test_fresh_install_and_rerun_keep_user_content(self):
        zshrc = self.write(".zshrc", "export PERSONAL_SETTING=kept\n")
        self.run_install()
        first_zshrc = zshrc.read_text()
        first_gitconfig = (self.test_home / ".gitconfig").read_text()
        self.run_install()
        self.assertEqual(zshrc.read_text(), first_zshrc)
        self.assertIn("export PERSONAL_SETTING=kept", first_zshrc)
        self.assertEqual(first_zshrc.count(START), 1)
        self.assertEqual((self.test_home / ".gitconfig").read_text(), first_gitconfig)
        self.assertFalse((self.test_home / ".dotfiles-backup").exists())
        self.assertIn("brew bundle install", self.log.read_text())
        self.assertIn("bat cache", self.log.read_text())
        self.assertIn("nvim --headless", self.log.read_text())

    def test_single_and_multiple_git_includes_survive(self):
        for count in (1, 2):
            with self.subTest(include_count=count):
                includes = []
                for index in range(count):
                    path = self.write(f"personal-{index}.gitconfig", "[alias]\n    personal = status --short\n")
                    includes.append(str(path))
                self.write(".gitconfig", "[include]\n" + "".join(f"    path = {path}\n" for path in includes))
                self.run_install("--no-brew")
                self.run_install("--no-brew")
                self.assertEqual(self.git_values("include.path"), includes + [str(self.test_home / ".config/git/catppuccin.gitconfig")])
                self.assertIn("status --short", self.git_values("alias.personal"))

    def test_ghostty_preserves_both_locations_and_uses_mac_config(self):
        xdg = self.write(".config/ghostty/config", "keybind = ctrl+a=new_tab\n")
        mac = self.write("Library/Application Support/com.mitchellh.ghostty/config", "keybind = ctrl+b=new_window\n")
        self.run_install("--no-brew")
        self.assertEqual(xdg.read_text(), "keybind = ctrl+a=new_tab\n")
        self.assertIn("keybind = ctrl+b=new_window", mac.read_text())
        self.assertIn(START, mac.read_text())
        self.assertIn("theme = Catppuccin Macchiato", mac.read_text())

    def test_modern_ghostty_filename_takes_precedence(self):
        for location in (".config/ghostty", "Library/Application Support/com.mitchellh.ghostty"):
            with self.subTest(location=location):
                legacy = self.write(f"{location}/config", "font-size = 20\n")
                modern = self.write(f"{location}/config.ghostty", "keybind = ctrl+b=new_window\n")
                self.run_install("--no-brew")
                self.assertEqual(legacy.read_text(), "font-size = 20\n")
                self.assertIn(START, modern.read_text())
                self.assertIn("keybind = ctrl+b=new_window", modern.read_text())

    def test_ghostty_respects_xdg_config_home(self):
        self.env["XDG_CONFIG_HOME"] = str(self.root / "custom config")
        config = Path(self.env["XDG_CONFIG_HOME"]) / "ghostty/config.ghostty"
        config.parent.mkdir(parents=True)
        config.write_text("keybind = ctrl+b=new_window\n")
        self.run_install("--no-brew")
        self.assertIn(START, config.read_text())
        self.assertFalse((self.test_home / ".config/ghostty/config").exists())

    def test_managed_symlink_and_permissions_survive(self):
        target = self.write("dotfiles/zshrc", "export PERSONAL_SETTING=kept\n")
        target.chmod(0o640)
        link = self.test_home / ".zshrc"
        link.symlink_to("dotfiles/zshrc")
        self.run_install("--no-brew")
        self.run_install("--no-brew")
        self.assertTrue(link.is_symlink())
        self.assertEqual(os.readlink(link), "dotfiles/zshrc")
        self.assertEqual(target.stat().st_mode & 0o777, 0o640)
        self.assertIn("export PERSONAL_SETTING=kept", target.read_text())
        self.assertEqual(target.read_text().count(START), 1)

    def test_managed_block_refresh_preserves_surrounding_content(self):
        config = self.write(".zshrc", f"personal-before\n{START}\nsource old-settings\n{END}\npersonal-after\n")
        self.run_install("--no-brew")
        self.assertIn("personal-before\npersonal-after\n", config.read_text())
        self.assertNotIn("source old-settings", config.read_text())
        self.assertEqual(config.read_text().count(START), 1)
        self.assertEqual(config.read_text().count(END), 1)

    def test_broken_owned_symlink_is_backed_up_without_writing_target(self):
        link = self.test_home / ".config/starship.toml"
        link.parent.mkdir(parents=True)
        target = self.test_home / "missing-starship.toml"
        link.symlink_to(target)
        self.run_install("--no-brew")
        self.assertFalse(link.is_symlink())
        self.assertFalse(target.exists())
        backups = [path for path in (self.test_home / ".dotfiles-backup").glob("*/.config/*") if path.name == "starship.toml"]
        self.assertEqual(len(backups), 1)
        self.assertTrue(backups[0].is_symlink())
        self.assertEqual(os.readlink(backups[0]), str(target))

    def test_malformed_managed_blocks_leave_file_unchanged(self):
        for content in (f"personal-before\n{START}\nold\npersonal-after\n", f"personal\n{END}\n", f"{START}\n{START}\n{END}\n"):
            with self.subTest(content=content):
                config = self.write(".zshrc", content)
                result = self.run_install("--no-brew", succeeds=False)
                self.assertIn("Malformed managed block", result.stderr)
                self.assertEqual(config.read_text(), content)

    def test_bat_comments_do_not_suppress_defaults(self):
        config = self.write(".config/bat/config", '# --theme="TwoDark"\n  # --style="full"\n')
        self.run_install("--no-brew")
        self.run_install("--no-brew")
        self.assertEqual(config.read_text().count('--theme="Catppuccin Macchiato"'), 1)
        self.assertEqual(config.read_text().count('--style="numbers,changes,header"'), 1)

    def test_active_bat_options_are_kept(self):
        original = '  --theme "TwoDark"\n--style=plain\n'
        config = self.write(".config/bat/config", original)
        self.run_install("--no-brew")
        self.assertEqual(config.read_text(), original)

    def test_stdin_install_clones_even_when_cwd_contains_config(self):
        (self.root / "config").mkdir()
        (self.root / "Brewfile").touch()
        result = self.run_install("--no-brew", stdin=True)
        self.assertIn("CLONED --no-brew", result.stdout)
        self.assertNotIn("unbound variable", result.stderr)
        self.assertIn("git clone --depth 1", self.log.read_text())

    def test_stdin_install_does_not_delete_existing_non_repository(self):
        personal = self.write(".catppuccin-workstation/personal", "keep me")
        result = self.run_install(stdin=True, succeeds=False)
        self.assertIn("existing non-repository path", result.stderr)
        self.assertEqual(personal.read_text(), "keep me")

    def test_shell_plugins_use_actual_homebrew_prefix(self):
        prefix = Path(self.env["INSTALL_TEST_BREW_PREFIX"])
        plugins = {
            "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh": "TEST_HIGHLIGHT",
        }
        for relative, variable in plugins.items():
            plugin = prefix / relative
            plugin.parent.mkdir(parents=True, exist_ok=True)
            plugin.write_text(f"{variable}=loaded\n")
        result = subprocess.run(
            ["/bin/zsh", "-dfi", "-c", 'compdef() { :; }; source "$1/config/zsh/zshrc"; print -r -- "$TEST_HIGHLIGHT"', "test", str(REPO)],
            env=self.env, capture_output=True, text=True, timeout=15,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.strip(), "loaded")


if __name__ == "__main__":
    unittest.main()
