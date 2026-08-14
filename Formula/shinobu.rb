class Shinobu < Formula
  desc "Wisteria-violet Dynamic Island for the MacBook notch"
  homepage "https://github.com/nexusgen4561/shinobu"
  url "https://github.com/nexusgen4561/shinobu/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "95e7c7e3837168e863342d5028d3c85f6c5bc328379f24c23e49d3a13fefeec3"
  license "MIT"
  head "https://github.com/nexusgen4561/shinobu.git", branch: "main"

  # EKEventStore.requestFullAccessToEvents is Sonoma-and-later.
  depends_on macos: :sonoma

  def install
    # build.sh assembles the bundle wherever APP_DIR points, so aim it at the
    # build directory and hand the finished bundle to the Cellar.
    ENV["APP_DIR"] = buildpath
    # A release tarball carries no .git, so build.sh cannot read a tag itself.
    ENV["VERSION"] = version.to_s
    system "./build.sh"
    prefix.install "Shinobu.app"

    # The app is menu-bar-only, so this launcher is how you start it from a shell.
    (bin/"shinobu").write <<~SH
      #!/bin/bash
      exec /usr/bin/open -a "#{opt_prefix}/Shinobu.app" "$@"
    SH
  end

  def caveats
    <<~EOS
      Start the widget with:
        shinobu

      Then rest your pointer on the notch — the panel unfolds on hover.

      It lives in the menu bar — no Dock icon. To also have it in Spotlight and
      Launchpad, link the bundle into your Applications folder:
        ln -sfn "#{opt_prefix}/Shinobu.app" ~/Applications/

      Shinobu asks for Automation (Spotify/Music), Calendars, and Photos access
      the first time it needs each one. Because the build is signed ad-hoc
      rather than with a Developer ID, macOS treats every upgrade as a new app
      and asks again. For the same reason "Launch at Login" in the app's menu is
      refused by macOS — add it under System Settings > General > Login Items
      instead.
    EOS
  end

  test do
    bundle = prefix/"Shinobu.app"
    assert_predicate bundle/"Contents/MacOS/Shinobu", :executable?
    assert_match "Shinobu", (bundle/"Contents/Info.plist").read

    # Guards against the bundle silently falling back to its dev placeholder,
    # which is what happens when build.sh cannot determine a version.
    plist_cmd = "/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString'"
    assert_equal version.to_s, shell_output("#{plist_cmd} '#{bundle}/Contents/Info.plist'").strip
  end
end
