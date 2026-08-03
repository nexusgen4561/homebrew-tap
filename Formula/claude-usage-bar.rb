class ClaudeUsageBar < Formula
  desc "Menu bar widget for Claude usage limits"
  homepage "https://github.com/nexusgen4561/claude-usage-bar"
  url "https://github.com/nexusgen4561/claude-usage-bar/archive/refs/tags/v1.0.2.tar.gz"
  sha256 "63e00f48386b6bcb987caf8d1f68fa84dbb9b636c9825126d541d99eda852620"
  license "MIT"
  head "https://github.com/nexusgen4561/claude-usage-bar.git", branch: "main"

  depends_on macos: :ventura

  def install
    # build.sh assembles the bundle wherever APP_DIR points, so aim it at the
    # build directory and hand the finished bundle to the Cellar.
    ENV["APP_DIR"] = buildpath
    system "./build.sh"
    prefix.install "Claude Usage.app"

    # The app is menu-bar-only, so this launcher is how you start it from a shell.
    (bin/"claude-usage-bar").write <<~SH
      #!/bin/bash
      exec /usr/bin/open -a "#{opt_prefix}/Claude Usage.app" "$@"
    SH
  end

  def caveats
    <<~EOS
      Start the widget with:
        claude-usage-bar

      It lives in the menu bar — no Dock icon. To also have it in Spotlight and
      Launchpad, link the bundle into your Applications folder:
        ln -sfn "#{opt_prefix}/Claude Usage.app" ~/Applications/

      It reads your existing Claude Code session. If you have not signed in yet,
      run `claude` in a terminal and then `/login` — starting `claude` on its own
      does not sign you in.

      Use "Launch at login" in the widget's menu to start it automatically.
    EOS
  end

  test do
    assert_predicate prefix/"Claude Usage.app/Contents/MacOS/ClaudeUsageBar", :executable?
    assert_match "Claude Usage", (prefix/"Claude Usage.app/Contents/Info.plist").read
  end
end
