# -*- coding: Windows-31J -*-
#$LOAD_PATH.push("C:/Documents and Settings/CCF1/My Documents/ruby/lib")
$LOAD_PATH.unshift '../lib'


##require "np_common_dev"
require "np_common"

##出力先を引数でしていされたファイルに変更
if ARGV[0] then
	$stdout = File.open(ARGV[0], "w")
end

def create_hash(dir)
	hash = Hash.new
	Dir.glob(dir + "*.*").each do |file|
		wk_subsys = File.basename(file, ".*")[0,4]
		if hash.key?(wk_subsys) then
			hash[wk_subsys] << file
		else
			hash.store(wk_subsys, [file])
		end
	end
	hash
end

def create_array(dir)
	ary = Array.new
	Dir.glob(dir + "*.*").each do |file|
		ary << file
	end
	ary.sort!
	ary
end

def count_file(dir, filename)
	cnt_file = 0
	Dir.glob(dir + filename).each do |file|
		cnt_file = cnt_file + 1
	end
	cnt_file
end


hash_addon_table = create_hash(DDL_TAB_DIR)
hash_addon_index = create_hash(DDL_IDX_DIR)
hash_addon_sequence = create_hash(DDL_SEQ_DIR)
hash_addon_view = create_hash(DDL_VEW_DIR)

hash_addon_form = create_hash(FMB_DIR)

cnt_XXCMC_区分内容 = count_file(CMD_DIR + "SQL/", '1-XXCMC_区分内容.sql')

array_package_sql = create_array(SQL_DIR).sort! do |a, b| 
	def change_filename(f)
		w_f = File.basename(f, ".*")

		if w_f[-4,1].upcase == 'Z' then
			w_f[0,1] = 'A'
		end
	
		if w_f[-1,1].upcase == 'S' then
			w_f[-1,1] = 'A'
		end
		w_f
	end

	change_filename(a) <=> change_filename(b)
end

array_frm = create_array(FRM_DIR)
array_vrq = create_array(VRQ_DIR)
array_eex = create_array(EEX_DIR)


## <<-----------------------------------------------------------------
puts "host mkdir c:\\sqllog		--←事前にフォルダを作成しておく"
puts "column log_date new_value log_date_text noprint"
puts "select to_char(sysdate,'yyyymmddhh24mi') log_date from dual;"
puts "spool c:\\sqllog\\&log_date_text._log.txt"
puts ""
puts "set def off"
puts "set line 1000"


def count_files(hash)
	cnt_files = 0
	hash.each do |subsys, files|
		files.each do |f|
			cnt_files = cnt_files + 1
		end
	end
	cnt_files
end

if hash_addon_table.size > 0 then
	## <<-----------------------------------------------------------------
	puts "/*****  AddonDb  ***********************************/"
	puts "/*----------------------------------------"
	puts "【１】新規テーブル追加（#{count_files(hash_addon_table)}件）（SQL Plus）"
	puts "------------------------------------------*/"

	hash_addon_table.each do |subsys, files|
		puts "/*----------"
		puts "	#{subsys}（#{files.size}件）"
		puts "------------*/"
		puts "conn #{subsys}/#{subsys}@QA1"
		puts ""
		files.each do |filename|
			puts "@#{cnv_dos_filename(filename)}"
		end
	end
	puts ""
end


if hash_addon_index.size > 0 then
	puts "/*****  AddonDb  ***********************************/"
	puts "/*----------------------------------------"
	puts "【３】インデックス追加（#{count_files(hash_addon_index)}件）（SQL Plus）"
	puts "------------------------------------------*/"

	hash_addon_index.each do |subsys, files|
		puts "/*----------"
		puts "	#{subsys}（#{files.size}件）"
		puts "------------*/"
		puts "conn #{subsys}/#{subsys}@QA1"
		puts ""
		files.each do |filename|
			puts "@#{cnv_dos_filename(filename)}"
		end
	end
	puts ""
end

if hash_addon_sequence.size > 0 then
	puts "/*****  AddonDb  ***********************************/"
	puts "/*----------------------------------------"
	puts "【４】シーケンス追加（#{count_files(hash_addon_sequence)}件）（SQL Plus）"
	puts "------------------------------------------*/"

	hash_addon_sequence.each do |subsys, files|
		puts "/*----------"
		puts "	#{subsys}（#{files.size}件）"
		puts "------------*/"
		puts "conn #{subsys}/#{subsys}@QA1"
		puts ""
		files.each do |filename|
			puts "@#{cnv_dos_filename(filename)}"
		end
	end
	puts ""
end

if hash_addon_table.size + hash_addon_sequence.size > 0 then
	puts "/*****  AddonDb  ***********************************/"
	puts "/*----------------------------------------"
	puts "【５】シノニム追加（#{count_files(hash_addon_table)+count_files(hash_addon_sequence)}件）（SQL Plus）"
	puts "------------------------------------------*/"
	puts "conn apps/apps@QA1"
	puts ""
	hash_addon_table.each do |subsys, files|
		files.each do |filename|
			puts "create synonym #{File.basename(filename, ".*")} for #{subsys}.#{File.basename(filename, ".*")};"
		end
	end
	puts ""
	hash_addon_sequence.each do |subsys, files|
		files.each do |filename|
			puts "create synonym #{File.basename(filename, ".*")} for #{subsys}.#{File.basename(filename, ".*")};"
		end
	end
	puts ""
end

if hash_addon_view.size > 0 then
	puts "/*****  AddonDb  ***********************************/"
	puts "/*----------------------------------------"
	puts "【６】ビュー変更＆追加（#{count_files(hash_addon_view)}件）（SQL Plus）"
	puts "------------------------------------------*/"
	puts "conn apps/apps@QA1"
	puts ""
	hash_addon_view.each do |subsys, files|
		files.each do |filename|
			puts "@#{cnv_dos_filename(filename)}"
		end
	end
	puts ""
end

if cnt_XXCMC_区分内容 > 0 then
	puts "/*----------------------------------------"
	puts "【７】区分内容・データ追加（ObjectBrowser）"
	puts "------------------------------------------*/"
	puts ""
	puts "conn xxcm/xxcm@QA1"
	puts ""
	puts "--バックアップ作成（引継ぎデータ件数出力）"
	puts "@#{cnv_dos_filename(CMD_DIR)}SQL\\1-XXCMC_区分内容.sql"
	puts ""
	puts "--テーブル「XXCMC_区分内容」にデータを貼り付ける（x件）"
	puts "-- C:\\w1\\区分内容_貼り付け用.xlsx"
	puts ""
	puts "--登録前＆登録後のデータ件数を確認(ObjectBrowser)"
	puts "SELECT COUNT(*) FROM XXCMC_区分内容;"
	puts "SELECT COUNT(*) FROM XXCMC_区分内容xxxxBK ;"
	puts ""
	puts "--＜コミットを行う＞"
	puts "--COMMIT;"
	puts ""
end

if hash_addon_table.size > 0 then
	puts "/*-------------------------"
	puts "	統計情報取得(テーブル）"
	puts "-------------------------*/"
	puts "conn apps/apps@QA1"
	puts ""
	puts "@#{cnv_dos_filename(CMD_DIR)}表の統計情報取得.sql"
	puts ""
end

if array_package_sql.size > 0 then
	puts "/*****  PLSQL （#{array_package_sql.size}件）  --SQL plus  ***********************************/"
	puts "conn apps/apps@QA1"
	puts ""
	puts "select owner,object_name,object_type from all_objects where status='INVALID';"
	puts ""
	puts "set def off"
	puts "set line 1000"
	puts ""

	array_package_sql.each do |filename|
		puts "@#{cnv_dos_filename(filename)}"
	end

	puts ""
	puts "select owner,object_name,object_type from all_objects where status='INVALID';"
	puts ""
end

if hash_addon_form.size > 0 then
	puts "/***  fmb  ********************************"
	puts "※１．他のコマンドに興味があれば、ネットでUNIXコマンドを調べてください。"
	puts "※２．FTP,telnetの接続ユーザー、パスワードは、EBS接続情報の一覧を参照"
	puts "****** ①FTP    でファイルを転送 *************************************"
	puts "****** ②telnet でコンパイル ****************************************/"
	puts ""
	puts "cd /appl/post/fmb"
	puts "ls -ltr"
	puts ""

	string_connect = ">"
	string_compile_cmd = "fcomp "
	hash_addon_form.each do |subsys, files|
		files.each do |filename|
			puts "#{string_compile_cmd}#{File.basename(filename, ".*")} #{string_connect} /tmp/fcomp.txt"
			string_connect = ">>"
		end
	end
	puts "cat /tmp/fcomp.txt | grep 生成"

	puts ""
	puts "cd /appl/post/fmx"
	puts "ls -ltr"
	puts ""

	puts "/*----- <開発環境では> ------"
	hash_addon_form.each do |subsys, files|
		files.each do |filename|
			puts "chmod 666 #{File.basename(filename, ".*")}.fmx"
		end
	end
	puts "------------------------------*/"

	hash_addon_form.each do |subsys, files|
		files.each do |filename|
			puts "chmod 644 #{File.basename(filename, ".*")}.fmx"
		end
	end
	puts ""

	hash_addon_form.each do |subsys, files|
		files.each do |filename|
			puts "cp -p /appl/post/fmx/#{File.basename(filename, ".*")}.fmx $#{subsys.upcase}_TOP/forms/JA"
			puts "cp -p /appl/post/fmx/#{File.basename(filename, ".*")}.fmx /appl/pub/fmx"
		end
		puts ""
	end
	puts "ls -ltr"
	puts ""

	hash_addon_form.each do |subsys, files|
		files.each do |filename|
			puts "rm /appl/post/fmx/#{File.basename(filename, ".*")}.fmx"
		end
	end
	puts "ls -ltr"
	puts ""

	hash_addon_form.each do |subsys, files|
		puts "-- #{subsys}（#{files.size}本）"
		puts "cd $#{subsys.upcase}_TOP/forms/JA"
		puts "ls -ltr"
		puts ""
	end

	puts "--全#{count_files(hash_addon_form)}本"
	puts "cd /appl/pub/fmx"
	puts "ls -ltr"
	puts ""
end


def put_file_list(array)
	w = ""
	array.each do |filename|
		w = w + File.basename(filename) + "\n"
	end
	w
end

puts "/*----------------------------------------"
puts "ＳＶＦ帳票（FRM：#{array_frm.size}件／VRQ：#{array_vrq.size}本）"
puts "------------------------------------------*/"
puts "#{put_file_list(array_frm)}" if array_frm.size > 0
puts "#{put_file_list(array_vrq)}" if array_vrq.size > 0
puts ""
puts "/*----------------------------------------"
puts "Discoverer（EEX：#{array_eex.size}件）"
puts "------------------------------------------*/"
puts "#{put_file_list(array_eex)}" if array_eex.size > 0
puts ""
puts "/*----------------------------------------"
puts "ＲＤ帳票（MRD：x件）"
puts "------------------------------------------*/"
