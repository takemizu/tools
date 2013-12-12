# -*- coding: Windows-31J -*-

=begin
Oracle Form �v���O�����̃I�u�W�F�N�g�E���X�g�E���|�[�g��
�쐬����

����: �Ώ�fmb�t�@�C���̑��݂���f�B���N�g��

2011/11/22

=end


class CreateAllObjectReport
	def initialize(dirname)
		@dir = dirname.gsub("\\","/")
		if @dir =~ /\/$/ then		#������/�ŏI����ĂȂ����/��������
		else
			@dir += "/"
		end
	end

	#�Ώۂ�FMB�t�@�C���̃��X�g���쐬����
	def create_fmb_list(dname)
		@fmb_list = Array.new
		Dir.glob(dname + "*.fmb").each do |file|
#			puts file
			obj_file = dname + File.basename(file, ".*") + ".txt"
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

	#�I�u�W�F�N�g���X�g���|�[�g���쐬
	def create_obj_report(dname)
		Dir.chdir(dname)
		create_fmb_list(dname)
		puts "Searching Form files ...." + dname
		if @fmb_list.size > 0 then	
	
			@fmb_list.each do |file|
				puts "  #{file}"
				system("IFCMP60.EXE", "LOGON=NO", "BATCH=YES", "Forms_Doc=YES", "MODULE=#{file}", "window_state=minimize", "script=NO")
				
				if File.exist?(dname + File.basename(file,".*") + ".txt") then
					errfile = dname + File.basename(file,".*") + ".err"
					File.unlink(errfile)
					puts "    Done...."
				end
			end
		end
	end

	def exec
		dir_save = Dir.pwd

		Dir.chdir(@dir)
		Dir.glob("**/").each do |dname|
			create_obj_report(@dir + dname)
		end

		Dir.chdir(dir_save)
	end

end



CreateAllObjectReport.new(ARGV[0]).exec
