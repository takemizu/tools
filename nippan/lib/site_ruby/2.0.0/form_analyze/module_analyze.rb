# -*- coding: Windows-31J -*-

=begin
���W���[�����𕪐͂��A�o�͂���

����: �I�u�W�F�N�g�E���X�g�E���|�[�g�t�@�C���̃��W���[�����

Version
0.01		2012/01/13		����

=end

require "np_common"
require "oracle_program_unit"

module OracleObjectReport

=begin
		CLASS ModuleAnalyze
		���W���[������
=end
	class ModuleAnalyze

		include OracleSQLProgram
		include Nippan::Common
		
		def initialize(pgm_text)
			@module_list = Hash.new
			@pgm_text = pgm_text
		end
	
	
		## ���͎��s
		def analyze
			w_text = @pgm_text
			if w_text =~ /^ \* ���O\s*(.*?)\n/i then
				module_name = $1
				@module_list['���O'] = module_name
			end
	
	    if w_text =~ /^ \* �ضް\s*\n/ then
		    w_text = $'
				if $' =~ /^ [-\*\^] �x��/mi then
					if $` then
						analyze_triggers($`)
					end
				end
	    end
		
		end
	
		def analyze_triggers(trigger_text)
			@module_list['�ضް'] = Hash.new
			w_text = trigger_text
	    while w_text.size > 0 do
				if w_text =~ /^   \* ���O\s*(.*?)\n/i then
					trigger_name = $1
					if $' =~ /^   ----------\n/ then
						analyze_trigger(trigger_name, $`)
					end
	        w_text = $'
	      else
	        w_text = ""
	      end
	    end
		end
	
		def analyze_trigger(trigger_name, trigger_text)
			@module_list['�ضް'][trigger_name] = Hash.new
	
			w_text = trigger_text
	
			if w_text =~ /^   \* �ضް�÷��\s*\n\n/mi then
				if $' =~ /^   [-\*\^] �⍇������Ӱ�ނŋN��/ then
					@module_list['�ضް'][trigger_name]['�ضް�÷��'] = $`
				end
		    w_text = $'
	    else
				@module_list['�ضް'][trigger_name]['�ضް�÷��'] = ''
	    end

			if w_text =~ /^   [-o\*\^] ���s�̊K�w *(\S*?)\n/i then
				@module_list['�ضް'][trigger_name]['���s�̊K�w'] = $1
		    w_text = $'
	    else
				@module_list['�ضް'][trigger_name]['���s�̊K�w'] = ''
	    end

		end
	
		## �ضް��
		def count_triggers
			0
			if @module_list['�ضް'] then
				@module_list['�ضް'].size
			end
		end
	
		def module_name
			@module_list['���O']
		end
	
		## �ضް���X�g���o��
		def print_trigger_list
			if @module_list['�ضް'] then
				@module_list['�ضް'].each {|key,value|
					puts "���W���[��\t#{module_name}\t#{key}\t#{value['���s�̊K�w']}\t#{OracleSQLProgram::PgmUnit.new(key, value['�ضް�÷��']).line_count}"
				}
			end
		end
	
		#�ضް �t�@�C���o��
		def output_triggers(out_dir)
			if out_dir then
				make_dir(out_dir)
				make_dir(out_dir + module_name)
		
				if @module_list['�ضް'] then
					@module_list['�ضް'].each {|key,value|
						$stdout = File.open(out_dir + module_name + '/' + key + '.sql' , "w")
						puts value['�ضް�÷��']
					}
				end
			end
		end
	
		## �߯���ގg�p���X�g
		def package_use_list
			list_use_package = Hash.new
			if @module_list['�ضް'] then
				@module_list['�ضް'].each {|key,value|
					lup = PgmUnit.new(key, value['�ضް�÷��']).list_use_packages
					lup.each {|key,value|
						pgm_name = key
						value.each {|value|
							if list_use_package[value] then
							else
								list_use_package[value] = Array.new
							end
							list_use_package[value] << "#{pgm_name}"
						}
					}
				}
			end
			list_use_package.each{|key,value|
				value.uniq!
				value.sort!
			}
			list_use_package
		end
	

		## ���Ұ��g�p���X�g
		def parameter_use_list
			list_use_parameter = Hash.new
			if @module_list['�ضް'] then
				@module_list['�ضް'].each {|key,value|
					lup = PgmUnit.new(key, value['�ضް�÷��']).list_use_parameters
					lup.each {|key,value|
						pgm_name = key
						value.each {|value|
							if list_use_parameter[value] then
							else
								list_use_parameter[value] = Array.new
							end
							list_use_parameter[value] << "#{pgm_name}"
						}
					}
				}
			end
			list_use_parameter.each{|key,value|
				value.uniq!
				value.sort!
			}
			list_use_parameter
		end
	
	end
end
