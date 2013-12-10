# -*- coding: Windows-31J -*-
=begin
2011/10/20
=end
require "fileutils"

#POST_DIR = "//tera03/share/ライブラリ/Library/Post_backup/20111007/Post/**/*.*"
POST_DIR = "//tera03/share/ライブラリ/Library/Post/**/*.*"

#WRK_DIR = "C:/"
WRK_DIR = "C:/release_wk/"
CMD_DIR = WRK_DIR + "w1/"
SQL_DIR = WRK_DIR + "w2/"
ETC_DIR = WRK_DIR + "w3/"
FMB_DIR = ETC_DIR + "fmb/"
EEX_DIR = ETC_DIR + "eex/"
BMP_DIR = ETC_DIR + "bmp/"
FRM_DIR = ETC_DIR + "frm/"
VRQ_DIR = ETC_DIR + "vrq/"
WFT_DIR = ETC_DIR + "wft/"

DDL_DIR = CMD_DIR + "ddl/"
DDL_TAB_DIR = DDL_DIR + "table/"
DDL_VEW_DIR = DDL_DIR + "view/"
DDL_SEQ_DIR = DDL_DIR + "seq/"
DDL_IDX_DIR = DDL_DIR + "index/"

def make_dir(dirname)
#	Dir.mkdir(dirname) if not File.exist?(dirname)
	FileUtils.mkdir_p(dirname) if not File.exist?(dirname)
end

def copy_file(filename, dir)
	make_dir(dir)
	if filename.size == filename.bytesize then
		FileUtils.cp(filename, dir, :preserve=>true)
	else
		#日本語ファイルをうまく扱えないので一時的にファイル名を変え、コピー後に元のファイル名に戻す
		FileUtils.cp(filename, dir + "temp" + File.extname(filename), :preserve=>true)
		File.rename(dir + "temp" + File.extname(filename), dir + File.basename(filename))
	end
end

def cnv_dos_filename(filename)
	filename.gsub(/\//,"\\")
end

def cnv_unix_filename(filename)
	filename.gsub(/\\/,"/")
end
