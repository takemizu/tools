# -*- coding: Windows-31J -*-
##$LOAD_PATH.push("C:/Documents and Settings/CCF1/My Documents/ruby/lib")
$LOAD_PATH.unshift '../lib'

require "np_common"

puts "コピー元:#{POST_DIR}"
puts ""

make_dir(WRK_DIR)
make_dir(CMD_DIR)
make_dir(SQL_DIR)
make_dir(ETC_DIR)

make_dir(DDL_DIR)
make_dir(DDL_TAB_DIR)
make_dir(DDL_VEW_DIR)
make_dir(DDL_SEQ_DIR)
make_dir(DDL_IDX_DIR)


wk_dir = Dir.glob(POST_DIR) #リリース対象のファイル名を取得

#拡張子順にSORT
wk_dir.sort!{|a, b| File.extname(a) <=> File.extname(b)}

#拡張子によってコピー先を振り分け
wk_dir.each do |source_file|
	##puts source_file
	to_dir = ''
	case File.extname(source_file).downcase
	when '.sql' then
		to_dir = SQL_DIR
		copy_file(source_file, to_dir);
	when '.fmb' then
		to_dir = FMB_DIR
		copy_file(source_file, to_dir);
	when '.eex' then
		to_dir = EEX_DIR
		copy_file(source_file, to_dir);
	when '.bmp' then
		to_dir = BMP_DIR
		copy_file(source_file, to_dir);
	when '.frm' then
		to_dir = FRM_DIR
		copy_file(source_file, to_dir);
	when '.vrq' then
		to_dir = VRQ_DIR
		copy_file(source_file, to_dir);
	when '.wft' then
		to_dir = WFT_DIR
		copy_file(source_file, to_dir);
	end

	stat = File.stat(source_file)
	
	puts "#{to_dir.ljust(24)} <- #{File.basename(source_file)}" + " "*(54-File.basename(source_file).bytesize) + "\t#{stat.mtime}\t#{stat.size.to_s.rjust(10)}"
end

puts ""
puts "End Copy_from_pub."
