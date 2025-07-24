class DirTimeDowndate < Formula
  desc "Utility to recursively update directory timestamps to match their newest content files"
  homepage "https://github.com/llorracc/dir_time_downdate"
  url "https://github.com/llorracc/dir_time_downdate/archive/v0.2.0.tar.gz"
  sha256 "" # Will be filled when creating actual release
  license "MIT"
  
  depends_on "zsh"
  
  def install
    # Install the main script
    bin.install "bin/dir-time-downdate"
    
    # Install man page
    man1.install "man/man1/dir-time-downdate.1"
    
    # Install documentation
    (share/"doc/dir-time-downdate").install "README.md", "LICENSE", "VERSION"
    (share/"doc/dir-time-downdate/doc").install Dir["doc/*"]
    
    # Note: .DS_Store templates are no longer installed - users provide their own
    # See doc/DSSTORE_TEMPLATE_GUIDE.md for instructions
  end

  test do
    # Test basic functionality
    system "#{bin}/dir-time-downdate", "--help"
    system "#{bin}/dir-time-downdate", "--version"
    
    # Test on a simple directory structure
    testdir = testpath/"test_dir"
    testdir.mkpath
    (testdir/"file.txt").write "test content"
    system "#{bin}/dir-time-downdate", "--verbose", "--non-interactive", testdir
    assert testdir.exist?
  end
end 