# -*- coding: Windows-31J -*-

=begin
Oracle Form �v���O�����̃I�u�W�F�N�g�E���X�g�E���|�[�g�𕪐͂��A�o�͂���

����: ��1�������t�@�C�����̏ꍇ
		1.�I�u�W�F�N�g�E���X�g�E���|�[�g�t�@�C����
		2.�o�͐�f�B���N�g����(�ȗ���:�W���o��)
		
	�I�u�W�F�N�g�E���X�g�E���|�[�g�𕪐͂��A�e�핪�͌��ʂ��o�͂���B

	  ��1�������t�H���_�[���̏ꍇ
	 	1.���͑Ώۃt�H���_�[��

	�I�u�W�F�N�g�E���X�g�E���|�[�g�𕪐͂��A���W���[�������o�͂���B

Version
0.01		2012/01/13		

=end

require "form_analyze"

include OracleObjectReport
include Nippan::Common

if ARGV[0] then
	if File.exist?(ARGV[0]) then
		if File.file?(ARGV[0]) then
			form_analyze = FormAnalyze.new(ARGV[0], ARGV[1])
			form_analyze.execute
			form_analyze.output
		else
			puts "���W���[����\t�u���b�N��\t���ڐ�\t�l���X�g��\t�ضް��\t��۸��ђP�ʐ�\t�ï�ߐ�\t���Đ�"
			ARGV.each {|dir|
				if File.exist?(dir) then
					if File.file?(dir) then
					else
						input_dir = cnv_unix_filename(dir)
						if input_dir then
							if input_dir =~ /\/$/ then
							else
								input_dir += '/'
							end
						end
						wk_files = Dir.glob(input_dir + "**/*.txt") #�����[�X�Ώۂ̃t�@�C�������擾
							
						wk_files.each { |source_file|
							form_analyze = FormAnalyze.new(source_file)
							form_analyze.execute
							puts form_analyze.module_info
						}
					end
				end
			}
		end
	end
else
end
