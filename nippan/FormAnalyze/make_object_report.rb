# -*- coding: Windows-31J -*-

=begin
Oracle Form プログラムのオブジェクト・リスト・レポートを
作成する

引数: 対象fmbファイルの存在するディレクトリ

2011/11/22

=end


class MakeObjectReport
	def initialize(dirname)
		@dir = dirname.gsub("\\","/")
		if @dir =~ /\/$/ then		#文字列が/で終わってなければ/を加える
		else
			@dir += "/"
		end
		@fmb_list = Array.new
	end

	#対象のFMBファイルのリストを作成する
	def create_fmb_list
		Dir.glob(@dir + "*.fmb").each do |file|
#			puts file
			obj_file = @dir + File.basename(file, ".*") + ".txt"
#			puts "obj_file:#{obj_file}"
			if File.exist?(obj_file) then
				if File.stat(file).mtime <= File.stat(obj_file).mtime then
					next
				end
#				puts "#{file} f:#{File.stat(file).mtime} o:#{File.stat(obj_file).mtime}"
			else
			end
			@fmb_list << File.basename(file)
		end
	end
	
	def fmb_list
		@fmb_list
	end

	#オブジェクトリストレポートを作成
	def exec
		create_fmb_list if @fmb_list.size == 0
		puts "Making Object Report...."

		dir_save = Dir.pwd
		Dir.chdir(@dir)

		@fmb_list.each do |file|
			puts "  #{file}"
			system("IFCMP60.EXE", "LOGON=NO", "BATCH=YES", "Forms_Doc=YES", "MODULE=#{file}", "window_state=minimize", "script=NO")
			
			if File.exist?(@dir + File.basename(file,".*") + ".txt") then
				errfile = @dir + File.basename(file,".*") + ".err"
				File.unlink(errfile)
				puts "    Done...."
			end
		end

		Dir.chdir(dir_save)
	end
end


MakeObjectReport.new(ARGV[0]).exec
