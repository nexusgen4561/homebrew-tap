class Aznable < Formula
  desc "Char Aznable-themed Dynamic Island for the MacBook notch"
  homepage "https://github.com/nexusgen4561/aznable"
  url "https://github.com/nexusgen4561/aznable/archive/refs/tags/v1.0.2.tar.gz"
  sha256 "bb963ae797837aaa302c584f86bbd433b6150dc70ff877b7986157172fa8a5f0"
  license "MIT"
  head "https://github.com/nexusgen4561/aznable.git", branch: "main"

  # EKEventStore.requestFullAccessToEvents is Sonoma-and-later.
  depends_on macos: :sonoma

  def install
    # build.sh assembles the bundle wherever APP_DIR points, so aim it at the
    # build directory and hand the finished bundle to the Cellar.
    ENV["APP_DIR"] = buildpath
    # A release tarball carries no .git, so build.sh cannot read a tag itself.
    ENV["VERSION"] = version.to_s
    system "./build.sh"
    prefix.install "Aznable.app"

    # The app is menu-bar-only, so this launcher is how you start it from a shell.
    (bin/"aznable").write <<~SH
      #!/bin/bash
      exec /usr/bin/open -a "#{opt_prefix}/Aznable.app" "$@"
    SH
  end

  def caveats
    <<~EOS
      Start the widget with:
        aznable

      Then rest your pointer on the notch — the panel unfolds on hover.

      It lives in the menu bar — no Dock icon. To also have it in Spotlight and
      Launchpad, link the bundle into your Applications folder:
        ln -sfn "#{opt_prefix}/Aznable.app" ~/Applications/

      Aznable asks for Automation (Spotify/Music), Calendars, and Photos access
      the first time it needs each one. Because the build is signed ad-hoc
      rather than with a Developer ID, macOS treats every upgrade as a new app
      and asks again. For the same reason "Launch at Login" in the app's menu is
      refused by macOS — add it under System Settings > General > Login Items
      instead.
    EOS
  end

  test do
    bundle = prefix/"Aznable.app"
    assert_predicate bundle/"Contents/MacOS/Aznable", :executable?
    assert_match "Aznable", (bundle/"Contents/Info.plist").read

    # Guards against the bundle silently falling back to its dev placeholder,
    # which is what happens when build.sh cannot determine a version.
    plist_cmd = "/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString'"
    assert_equal version.to_s, shell_output("#{plist_cmd} '#{bundle}/Contents/Info.plist'").strip
  end
end
