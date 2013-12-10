# -*- coding: Windows-31J -*-
#$LOAD_PATH.push("C:/Documents and Settings/CCF1/My Documents/ruby/lib")
$LOAD_PATH.unshift '../lib'


##require "np_common_dev"
require "np_common"

##�o�͐�������ł��Ă����ꂽ�t�@�C���ɕύX
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

puts "--�\�̓��v���擾"
puts "DECLARE"
puts ""
puts "BEGIN"
puts ""

table_names.each_with_index do |filename, idx|
	wk_subsys = filename.split(/\./)[0]
	wk_table_name = filename.split(/\./)[1]
	puts "	--�y#{idx+1}�z #{wk_table_name} ---"
	puts "	DBMS_OUTPUT.PUT_LINE('�\�̓��v���擾 �J�n(#{wk_table_name})');"
	puts "	DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI:SS'));"
	puts ""
	puts "	FND_STATS.GATHER_TABLE_STATS("
	puts "		 ownname        => '#{wk_subsys}'"
	puts "		,tabname        => '#{wk_table_name}'"
	puts "		,percent        => 10           --�T���v�����O��"
	puts "		,degree         => NULL         --���v�̎��W�Ɏg�p��������x"
	puts "		,partname       => NULL         --�p�[�e�B�V��������"
	puts "		,backup_flag    => 'NOBACKUP'   --���v�̃o�b�N�A�b�v"
	puts "		,cascade        => TRUE         --�w�肳�ꂽ�\���v�ɉ����������v���擾���邩�ǂ���"
	puts "		,granularity    => 'ALL'        --���v�̗��x(�p�[�e�B�V�����\�̏ꍇ�̂�)"
	puts "		,hmode          => 'LASTRUN'    --�������R�[�h�ʂ̐���"
	puts "		,invalidate     => 'Y'"
	puts "	);"
	puts ""
	puts "	DBMS_OUTPUT.PUT_LINE('�\�̓��v���擾 �I��');"
	puts "	DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI:SS'));"
	puts ""
end

puts "END;"
puts "/"
