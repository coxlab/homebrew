require 'formula'

class GhostscriptFonts <Formula
  url 'http://downloads.sourceforge.net/project/gs-fonts/gs-fonts/8.11%20%28base%2035%2C%20GPL%29/ghostscript-fonts-std-8.11.tar.gz'
  homepage 'http://sourceforge.net/projects/gs-fonts/'
  md5 '6865682b095f8c4500c54b285ff05ef6'
end

class Ghostscript <Formula
  url 'http://downloads.sourceforge.net/project/ghostscript/GPL%20Ghostscript/8.71/ghostscript-8.71.tar.gz'
  homepage 'http://www.ghostscript.com/'
  md5 '51a522a5b4818bd3dc7c1c0e9dd22bad'

  depends_on 'pkg-config'
  depends_on 'jasper'
  depends_on 'jpeg'

  aka 'gs'

  def move_included_source_copies
    # If the install version of any of these doesn't match
    # the version included in ghostscript, we get errors
    # Taken from the MacPorts portfile - http://bit.ly/ghostscript-portfile
    %w{ jpeg libpng zlib }.each do |lib|
      mv lib, "#{lib}_local"
    end
  end

  def install
    ENV.libpng
    ENV.deparallelize
    # O4 takes an ungodly amount of time
    ENV.O3
    # ghostscript configure ignores LDFLAGs apparently
    ENV['LIBS']="-L/usr/X11/lib"

    move_included_source_copies

    system "./configure", "--prefix=#{prefix}", "--disable-debug",
                          # the cups component adamantly installs to /usr so fuck it
                          "--disable-cups",
                          "--disable-compile-inits",
                          "--disable-gtk"

    # versioned stuff in main tree is pointless for us
    inreplace 'Makefile', '/$(GS_DOT_VERSION)', ''
    system "make install"

    GhostscriptFonts.new.brew do
      Dir.chdir '..'
      (prefix+'share/ghostscript').install 'fonts'
    end
    
    (man+'de').rmtree
  end
  
  def caveats
      <<-EOS.undent
        There have been reports that installing Ghostscript can break printing on OS X:
          http://github.com/mxcl/homebrew/issues/issue/528

        If your printing doesn't break, please comment on the issue! Thanks.
      EOS
  end
end
