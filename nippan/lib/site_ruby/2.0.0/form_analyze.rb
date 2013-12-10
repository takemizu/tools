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
0.01		2012/01/13		����
0.02		2012/01/18		module OracleObjectReport �쐬
=end

require "np_common"
require "form_analyze/module_analyze"
require "form_analyze/block_analyze"
require "form_analyze/list_value_analyze"
require "form_analyze/pgm_unit_analyze"
require "form_analyze/parameter_analyze"
require "form_analyze/record_group_analyze"

module OracleObjectReport


=begin
	CLASS FormAnalyze
	Forms�v���O�����̕��͂��s��
=end
	class FormAnalyze

		include OracleSQLProgram
		include Nippan::Common
		
		def initialize(fname, out_dir=nil)
			@file_name = fname.gsub("\\","/")
			@output_dir = out_dir
	
		end
	
	
		## ���͎��s
		def execute
		
			@frm_text = File.read(@file_name)
			@trigger_list = Hash.new
			
			if @frm_text =~ /(^ \* ��ۯ�\s*\n)/mi then
				@module_ana = ModuleAnalyze.new($`)
				@module_ana.analyze
			else
				return
			end
	
			if @frm_text =~ /(^ \* ��ۯ�\s*\n)/mi then
				if  $' =~ /^ \* ����޽/mi then
					@blocks_ana = BlockAnalyze.new($`)
					@blocks_ana.analyze
				end
			end
	
			if @frm_text =~ /(^ \* ̫�ѥ���Ұ� *\n)/mi then
				if  $' =~ /^ \* �lؽ�/mi then
					@parameter_ana = ParameterAnalyze.new($`)
					@parameter_ana.analyze
				end
			end
	
			if @frm_text =~ /(^ \* �lؽ�\s*\n)/mi then
				if  $' =~ /^ \* �ƭ�/mi then
					@lv_ana = ListValueAnalyze.new($`)
					@lv_ana.analyze
				end
			end
	
			if @frm_text =~ /(^ \* ��۸��ђP��\s*\n)/mi then
				if  $' =~ /^ \* �����è��׽/mi then
					@pgm_units_ana = PgmUnitAnalyze.new($`)
					@pgm_units_ana.analyze
				end
			end
	
			if @frm_text =~ /(^ \* ں��ޥ��ٰ��\s*\n)/mi then
				if  $' =~ /^ \* ������/mi then
					@rg_ana = RecordGroupAnalyze.new($`)
					@rg_ana.analyze
				end
			end
		end
	
		## ���W���[�����
		def module_info
			if @module_ana then
			else
				return
			end
	
			"#{@module_ana.module_name}\t#{@blocks_ana.count_blocks}\t#{@blocks_ana.count_items}\t#{@lv_ana.count_list}\t#{@module_ana.count_triggers+@blocks_ana.count_triggers}\t#{@pgm_units_ana.count_pgm}\t#{@pgm_units_ana.count_pgm_steps}\t#{@pgm_units_ana.count_comment_steps}"
		end

		## �p�b�P�[�W���
		def package_list
			if @module_ana then
			else
				return
			end
			@pgm_units_ana.package_list
			
		end

		def package_use_list
			pul = @module_ana.package_use_list
			
			@blocks_ana.package_use_list.each { |key,value|
				if pul[key] then
					pul[key] = pul[key] + value
				else
					pul[key] = value
				end
			}

			@pgm_units_ana.package_use_list.each { |key,value|
				if pul[key] then
					pul[key] = pul[key] + value
				else
					pul[key] = value
				end
			}
			pul
		end

		def parameter_use_list
			pul = @module_ana.parameter_use_list
			
			@blocks_ana.parameter_use_list.each { |key,value|
				if pul[key] then
					pul[key] = pul[key] + value
				else
					pul[key] = value
				end
			}

			@pgm_units_ana.parameter_use_list.each { |key,value|
				if pul[key] then
					pul[key] = pul[key] + value
				else
					pul[key] = value
				end
			}
			pul
		end

		## ���͌��ʏo��
		def output
		
			if @module_ana then
			else
				return
			end
			
			if @output_dir then
				out_dir = cnv_unix_filename(@output_dir)
			
				if @output_dir =~ /\/$/ then
				else
					@output_dir += '/'
				end
			
				make_dir(@output_dir)
			end

			##�o�͐�������Ŏw�肳�ꂽ�t�@�C���ɕύX
			if @output_dir then
				$stdout = File.open(@output_dir+'module_info.txt', "w")
			end
			puts "���W���[����\t�u���b�N��\t���ڐ�\t�l���X�g��\t�ضް��\t��۸��ђP�ʐ�\t�ï�ߐ�\t���Đ�"
			puts module_info
			
			if @output_dir then
				$stdout = File.open(@output_dir+'block_info.txt', "w")
			end
			@blocks_ana.print_block_info
	
			if @output_dir then
				$stdout = File.open(@output_dir+'item_info.txt', "w")
			end
			@blocks_ana.print_item_info
	
			if @output_dir then
				$stdout = File.open(@output_dir+'pgm_unit_info.txt', "w")
			end
			@pgm_units_ana.print_info
	
			if @output_dir then
				$stdout = File.open(@output_dir+'list_value_info.txt', "w")
			end
			@lv_ana.print_info
	
			if @output_dir then
				$stdout = File.open(@output_dir+'list_value_col_info.txt', "w")
			end
			@lv_ana.print_col_info
	
			if @output_dir then
				$stdout = File.open(@output_dir+'recordgroup_info.txt', "w")
			end
			@rg_ana.print_info
	
			if @output_dir then
				$stdout = File.open(@output_dir+'parameter_info.txt', "w")
			end
			@parameter_ana.print_info
	
			if @output_dir then
				$stdout = File.open(@output_dir+'trigger_info.txt', "w")
			end
	
			#�ضް���o��
			puts "���x��\t���O\t�ضް��\t���s�̊K�w\t\�X�e�b�v��"
			@module_ana.print_trigger_list
			@blocks_ana.print_trigger_list
	
			if @output_dir then
				#�t�@�C���o��
				@module_ana.output_triggers(@output_dir + '�ضް/')
				@blocks_ana.output_triggers(@output_dir + '�ضް/'+ @module_ana.module_name + '/')
		
				@rg_ana.output_query(@output_dir + '�l���X�g/')
		
				@pgm_units_ana.output_pgm_units(@output_dir + '��۸��ђP��/')
			end

			if @output_dir then
				$stdout = File.open(@output_dir+'parameter_use_info.txt', "w")
			end
			puts "̫�ѥ���Ұ���\t�g�p���Ă�����۸��ђP��"
			parameter_use_list.sort.each {|key,value|
				package_name = key
				value.each {|value|
					puts "#{package_name}\t#{value}"
				}
			}

			if @output_dir then
				$stdout = File.open(@output_dir+'package_use_info.txt', "w")
			end
			puts "�߯���ޖ�\t�g�p���Ă�����۸��ђP��"
			package_use_list.sort.each {|key,value|
				package_name = key
				value.each {|value|
					puts "#{package_name}\t#{value}"
				}
			}

#			package_list.each {|key,value|
#				package_name = key
#				value.each {|key,value|
#					pgm_type = key
#					value.each {|key,value|
#						pgm_name = key
#						value.each {|value|
#							puts "#{package_name}\t#{pgm_type}\t#{pgm_name}\t#{value}"
#						}
#					}
#				}
#			}
#

		end
	
	end #Class
	
end #module
