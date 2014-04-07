# coding: Windows-31J
=begin
  2014/03/25  Ruby 2.0 対応で新規作成
=end
require "nippan_utils/version"

require "fileutils"

module NippanUtils

  autoload :ReleaseWork,            "nippan_utils/release_work"
  autoload :PostDir,                "nippan_utils/release_work"

  def self.create_dir(dirname)
  # Dir.mkdir(dirname) if not File.exist?(dirname)
    FileUtils.mkdir_p(dirname) if not File.exist?(dirname)
  end
  
  def self.copy_file(filename, dir)
    create_dir(dir)
    FileUtils.cp(filename, dir, :preserve=>true)
    # if filename.size == filename.bytesize then
    #   FileUtils.cp(filename, dir, :preserve=>true)
    # else
    #   #日本語ファイルをうまく扱えないので一時的にファイル名を変え、コピー後に元のファイル名に戻す
    #   FileUtils.cp(filename, dir + "temp" + File.extname(filename), :preserve=>true)
    #   File.rename(dir + "temp" + File.extname(filename), dir + File.basename(filename))
    # end
  end
  
  def self.cnv_dos_filename(filename)
    ##filename.gsub(/\//,"\\")
    filename.gsub(File::SEPARATOR) {File::ALT_SEPARATOR}
  end
  
  def self.cnv_unix_filename(filename)
    ##filename.gsub(/\\/,"/")
    filename.gsub(File::ALT_SEPARATOR) {File::SEPARATOR}
  end
end
