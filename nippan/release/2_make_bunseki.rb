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

hash_addon_table = create_hash(DDL_TAB_DIR)
hash_addon_index = create_hash(DDL_IDX_DIR)


table_names = Array.new

hash_addon_table.each do |subsys, files|
	files.each do |file|
		File.open(file, "r") do |f|
p file
			f.each_line do |line|
				table_name = line.slice(/\s*CREATE\s+TABLE\s+(\S+)/,1)
				if table_name then
p table_name
p subsys
					table_name = table_name.split(/\./)[1] if /\./ =~ table_name
p table_name
					table_names << subsys + '.' + table_name
				end
			end
		end
	end
end

p table_names
hash_addon_index.each do |subsys, files|
	files.each do |file|
		File.open(file, "r") do |f|
			f.each_line do |line|
				table_name = line.slice(/\s*ON\s+(\S+)/,1)
				if table_name then
					table_name = table_name.split(/\./)[1] if /\./ =~ table_name
					wk_subsys = subsys
					wk_subsys = "INV" if /^MTL_/ =~ table_name
					wk_subsys = "PO" if /^PO_/ =~ table_name
					wk_subsys = "OE" if /^OE_/ =~ table_name
					table_names << wk_subsys + '.' + table_name
				end
			end
		end
	end
end
p table_names


#table_names.each do |table_name|
#	table_name = table_name.split(/\./)[1] if /\./ =~ table_name
#end

##table_names.uniq!.sort!

##puts table_names


puts "SET LINESIZE 256"
puts "SET SERVEROUTPUT ON SIZE 1000000"
puts "ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY/MM/DD HH24:MI:SS';"

puts "--表の統計情報取得"
puts "DECLARE"
puts ""
puts "BEGIN"
puts ""

table_names.each_with_index do |filename, idx|
	wk_subsys = filename.split(/\./)[0]
	wk_table_name = filename.split(/\./)[1]
	puts "	--【#{idx+1}】 #{wk_table_name} ---"
	puts "	DBMS_OUTPUT.PUT_LINE('表の統計情報取得 開始(#{wk_table_name})');"
	puts "	DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI:SS'));"
	puts ""
	puts "	FND_STATS.GATHER_TABLE_STATS("
	puts "		 ownname        => '#{wk_subsys}'"
	puts "		,tabname        => '#{wk_table_name}'"
	puts "		,percent        => 10           --サンプリング率"
	puts "		,degree         => NULL         --統計の収集に使用される並列度"
	puts "		,partname       => NULL         --パーティション名称"
	puts "		,backup_flag    => 'NOBACKUP'   --統計のバックアップ"
	puts "		,cascade        => TRUE         --指定された表統計に加え索引統計も取得するかどうか"
	puts "		,granularity    => 'ALL'        --統計の粒度(パーティション表の場合のみ)"
	puts "		,hmode          => 'LASTRUN'    --履歴レコード量の制御"
	puts "		,invalidate     => 'Y'"
	puts "	);"
	puts ""
	puts "	DBMS_OUTPUT.PUT_LINE('表の統計情報取得 終了');"
	puts "	DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI:SS'));"
	puts ""
end

puts "END;"
puts "/"
