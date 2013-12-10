# -*- coding: Windows-31J -*-

=begin
�u���b�N�𕪐͂��A�o�͂���

����: �I�u�W�F�N�g�E���X�g�E���|�[�g�t�@�C���̃u���b�N���

Version
0.01		2012/01/13		����

=end

require "oracle_program_unit"


module OracleObjectReport
=begin
		CLASS BlockAnalyze
		�u���b�N����
=end
	class BlockAnalyze

		include OracleSQLProgram
		include Nippan::Common
		
		def initialize(pgm_text)
			@block_list = Hash.new
			@pgm_text = pgm_text
		end
	
	
		## ���͎��s
		def analyze
			w_text = @pgm_text
	    while w_text.size > 0 do
				if w_text =~ /^   \* ���O\s*(.*?)\n/i then
					block_name = $1
					if $' =~ /^   ----------\n/ then
						analyze_block(block_name, $`)
					end
	        w_text = $'
	      else
	        w_text = ""
	      end
	    end
			
		end
	
		def analyze_block(block_name, block_text)
			@block_list[block_name] = Hash.new
			@block_list[block_name]['�ضް'] = Hash.new
			@block_list[block_name]['����'] = Hash.new
	
			w_text = block_text
	
			if w_text =~ /^   [-\*\^] �\��ں��ސ� *(.*?)\n/i then
				@block_list[block_name]['�\��ں��ސ�'] = $1
		    w_text = $'
	    else
				@block_list[block_name]['�\��ں��ސ�'] = ''
	    end
	
			if w_text =~ /^   \* �⍇���ް������̖��O *(.*?)\n/i then
				@block_list[block_name]['�⍇���ް������̖��O'] = $1
		    w_text = $'
	    else
				@block_list[block_name]['�⍇���ް������̖��O'] = ''
	    end
	
	    
	    if w_text =~ /^   \* �ضް\s*\n/ then
		    w_text = $'
				if $' =~ /^   \* ����/mi then
					if $` then
						analyze_triggers(block_name, $`)
					end
				end
	    end
	
	    if w_text =~ /^   \* ����\s*\n/ then
		    w_text = $'
				if $' =~ /^   - �ڰ���/mi then
					if $` then
						analyze_items(block_name, $`)
					end
				end
	    end
		end
	
		def analyze_triggers(block_name, trigger_text)
			w_text = trigger_text
	    while w_text.size > 0 do
				if w_text =~ /^     \* ���O\s*(.*?)\n/i then
					trigger_name = $1
					if $' =~ /^     ----------\n/ then
						analyze_trigger(block_name, trigger_name, $`)
					end
	        w_text = $'
	      else
	        w_text = ""
	      end
	    end
		end
	
		def analyze_trigger(block_name, trigger_name, trigger_text)
			@block_list[block_name]['�ضް'][trigger_name] = Hash.new
	
			w_text = trigger_text
	
			if w_text =~ /^     \* �ضް�÷��\s*\n\n/mi then
				if $' =~ /^     [-\*\^] �⍇������Ӱ�ނŋN��/ then
					@block_list[block_name]['�ضް'][trigger_name]['�ضް�÷��'] = $`
				end
		    w_text = $'
	    else
				@block_list[block_name]['�ضް'][trigger_name]['�ضް�÷��'] = ''
	    end
	
			if w_text =~ /^     [-o\*\^] ���s�̊K�w *(\S*?)\n/i then
				@block_list[block_name]['�ضް'][trigger_name]['���s�̊K�w'] = $1
		    w_text = $'
	    else
				@block_list[block_name]['�ضް'][trigger_name]['���s�̊K�w'] = ''
	    end
		end
	
	
		def analyze_items(block_name, item_text)
			w_text = item_text
	    while w_text.size > 0 do
				if w_text =~ /^     \* ���O\s*(.*?)\n/i then
					item_name = $1
					if $' =~ /^     ----------\n/ then
						analyze_item(block_name, item_name, $`)
					end
	        w_text = $'
	      else
	        w_text = ""
	      end
	    end
			
		end
	
		def analyze_item(block_name, item_name, item_text)
			@block_list[block_name]['����'][item_name] = Hash.new
	
			w_text = item_text
	
			if w_text =~ /^     [-o\*\^] �������� *(.*?)\n/i then
				@block_list[block_name]['����'][item_name]['��������'] = $1
		    w_text = $'
	    else
				@block_list[block_name]['����'][item_name]['��������'] = ''
	    end
	
			if w_text =~ /^     [-o\*\^] �ް��^ *(.*?)\n/i then
				@block_list[block_name]['����'][item_name]['�ް��^'] = $1
		    w_text = $'
	    else
				@block_list[block_name]['����'][item_name]['�ް��^'] = ''
	    end
	
			if w_text =~ /^     [-o\*\^] �ő咷 *(.*?)\n/i then
				@block_list[block_name]['����'][item_name]['�ő咷'] = $1
		    w_text = $'
	    else
				@block_list[block_name]['����'][item_name]['�ő咷'] = ''
	    end
	
			if w_text =~ /^     [-o\*\^] �K�{ *(.*?)\n/i then
				@block_list[block_name]['����'][item_name]['�K�{'] = $1
		    w_text = $'
	    else
				@block_list[block_name]['����'][item_name]['�K�{'] = ''
	    end
	
			if w_text =~ /^     [-o\*\^] �� *(\S*?)\n/i then
				@block_list[block_name]['����'][item_name]['��'] = $1
		    w_text = $'
	    else
				@block_list[block_name]['����'][item_name]['��'] = ''
	    end
	
			if w_text =~ /^     [-o\*\^] �lؽ� *(\S*?)\n/i then
				@block_list[block_name]['����'][item_name]['�lؽ�'] = $1
		    w_text = $'
	    else
				@block_list[block_name]['����'][item_name]['�lؽ�'] = ''
	    end
	
			if w_text =~ /^     [-o\*\^] �� *(\S*?)\n/i then
				@block_list[block_name]['����'][item_name]['��'] = $1
		    w_text = $'
	    else
				@block_list[block_name]['����'][item_name]['��'] = ''
	    end
	
			if w_text =~ /^     [-o\*\^] ����޽ *(\S*?)\n/i then
				@block_list[block_name]['����'][item_name]['����޽'] = $1
		    w_text = $'
	    else
				@block_list[block_name]['����'][item_name]['����޽'] = ''
	    end
	
			if w_text =~ /^     [-o\*\^] ��ޥ�߰�� *(\S*?)\n/i then
				@block_list[block_name]['����'][item_name]['��ޥ�߰��'] = $1
		    w_text = $'
	    else
				@block_list[block_name]['����'][item_name]['��ޥ�߰��'] = ''
	    end
	
			if w_text =~ /^     [-o\*\^] X�ʒu *(\S*?)\n/i then
				@block_list[block_name]['����'][item_name]['X�ʒu'] = $1
		    w_text = $'
	    else
				@block_list[block_name]['����'][item_name]['X�ʒu'] = ''
	    end
	
			if w_text =~ /^     [-o\*\^] Y�ʒu *(\S*?)\n/i then
				@block_list[block_name]['����'][item_name]['Y�ʒu'] = $1
		    w_text = $'
	    else
				@block_list[block_name]['����'][item_name]['Y�ʒu'] = ''
	    end
	
			if w_text =~ /^     [-o\*\^] �� *(\S*?)\n/i then
				@block_list[block_name]['����'][item_name]['��'] = $1
		    w_text = $'
	    else
				@block_list[block_name]['����'][item_name]['��'] = ''
	    end
	
			if w_text =~ /^     [-o\*\^] ���� *(\S*?)\n/i then
				@block_list[block_name]['����'][item_name]['����'] = $1
		    w_text = $'
	    else
				@block_list[block_name]['����'][item_name]['����'] = ''
	    end
	
	    if w_text =~ /^     [-o\*\^] �ضް *\n/ then
		    w_text = $'
				if $' then
					analyze_item_triggers(block_name, item_name, $')
				end
	    end
		end
	
		def analyze_item_triggers(block_name, item_name, trigger_text)
			@block_list[block_name]['����'][item_name]['�ضް'] = Hash.new
			
			w_text = trigger_text
	    while w_text.size > 0 do
				if w_text =~ /^       \* ���O\s*(.*?)\n/i then
					trigger_name = $1
					if $' =~ /^       ----------\n/ then
						analyze_item_trigger(block_name, item_name, trigger_name, $`)
					end
	        w_text = $'
	      else
	        w_text = ""
	      end
	    end
		end
	
		def analyze_item_trigger(block_name, item_name, trigger_name, trigger_text)
			@block_list[block_name]['����'][item_name]['�ضް'][trigger_name] = Hash.new
	
			w_text = trigger_text
	
			if w_text =~ /^       \* �ضް�÷��\s*\n\n/mi then
				if $' =~ /^       [-\*\^] �⍇������Ӱ�ނŋN��/ then
					@block_list[block_name]['����'][item_name]['�ضް'][trigger_name]['�ضް�÷��'] = $`
				end
		    w_text = $'
	    else
				@block_list[block_name]['����'][item_name]['�ضް'][trigger_name]['�ضް�÷��'] = ''
	    end

			if w_text =~ /^       [-o\*\^] ���s�̊K�w *(\S*?)\n/i then
				@block_list[block_name]['����'][item_name]['�ضް'][trigger_name]['���s�̊K�w'] = $1
		    w_text = $'
	    else
				@block_list[block_name]['����'][item_name]['�ضް'][trigger_name]['���s�̊K�w'] = ''
	    end
	
		end
		
		## �u���b�N��
		def count_blocks
			@block_list.size
		end
	
		## ���ڐ�
		def count_items
			ret_val = 0
			@block_list.each {|key, value|
				ret_val += value['����'].size
			}
			ret_val
		end
		
		## �ضް��
		def count_triggers
			ret_val = 0
			@block_list.each {|key, value|
				if value['�ضް'] then
					ret_val += value['�ضް'].size
				end
				block_name = key
				value['����'].each {|key,value|
					if value['�ضް'] then
						ret_val += value['�ضް'].size
					end
				}
			}
			ret_val
		end
	
	
		## ���͌���(�u���b�N���)���o��
		def print_block_info
			puts "�u���b�N��\t�\��ں��ސ�\t�\�[�X��"
			@block_list.each {|key, value|
				puts "#{key}\t#{value['�\��ں��ސ�']}\t#{value['�⍇���ް������̖��O']}"
			}
	
		end
	
		## ���͌���(���ڏ��)���o��
		def print_item_info
			puts "�u���b�N��\t���ږ�\t��������\t�ް��^\t�ő咷\t�K�{\t��\t�lؽ�\t��\t����޽\t��ޥ�߰��\tX�ʒu\tY�ʒu\t��\t����"
			@block_list.each {|key, value|
				block_name = key
				value['����'].each {|key,value|
					puts "#{block_name}\t#{key}\t#{value['��������']}\t#{value['�ް��^']}\t#{value['�ő咷']}\t#{value['�K�{']}\t#{value['��']}\t#{value['�lؽ�']}\t#{value['��']}\t#{value['����޽']}\t#{value['��ޥ�߰��']}\t#{value['X�ʒu']}\t#{value['Y�ʒu']}\t#{value['��']}\t#{value['����']}"
				}
			}
	
		end
	
		def print_trigger_list
			@block_list.each {|key, value|
				block_name = key
				value['�ضް'].each {|key,value|
					puts "�u���b�N\t#{block_name}\t#{key}\t#{value['���s�̊K�w']}\t#{PgmUnit.new(key, value['�ضް�÷��']).line_count}"
				}
				value['����'].each {|key,value|
					item_name = key
					value['�ضް'].each  {|key,value|
						puts "����\t#{block_name}.#{item_name}\t#{key}\t#{value['���s�̊K�w']}\t#{PgmUnit.new(key, value['�ضް�÷��']).line_count}"
					}
				}
			}
		end
	
		#�ضް �t�@�C���o��
		def output_triggers(out_dir)
			if out_dir then
	
				@block_list.each {|key, value|
					block_name = key
					value['�ضް'].each {|key,value|
						make_dir(out_dir + block_name + '/')
						$stdout = File.open(out_dir + block_name + '/' + key + '.sql' , "w")
						puts value['�ضް�÷��']
					}
					value['����'].each {|key,value|
						item_name = key
						value['�ضް'].each  {|key,value|
							make_dir(out_dir + block_name + '/' + item_name + '/')
							$stdout = File.open(out_dir + block_name + '/' + item_name + '/' + key + '.sql' , "w")
							puts value['�ضް�÷��']
						}
					}
				}
			end
		end
	
		## �߯���ގg�p���X�g
		def package_use_list


			list_use_package = Hash.new

			@block_list.each {|key, value|
				block_name = key
				value['�ضް'].each {|key,value|
					lup = PgmUnit.new(key, value['�ضް�÷��']).list_use_packages
					lup.each {|key,value|
						pgm_name = key
						value.each {|value|
							if list_use_package[value] then
							else
								list_use_package[value] = Array.new
							end
							list_use_package[value] << "#{block_name}.#{pgm_name}"
						}
					}
				}
				value['����'].each {|key,value|
					item_name = key
					value['�ضް'].each  {|key,value|
						lup = PgmUnit.new(key, value['�ضް�÷��']).list_use_packages
						lup.each {|key,value|
							pgm_name = key
							value.each {|value|
								if list_use_package[value] then
								else
									list_use_package[value] = Array.new
								end
								list_use_package[value] << "#{block_name}.#{item_name}.#{pgm_name}"
							}
						}
					}
				}
			}
			list_use_package.each{|key,value|
				value.uniq!
				value.sort!
			}
			list_use_package
		end

		## ���Ұ��g�p���X�g
		def parameter_use_list


			list_use_parameter = Hash.new

			@block_list.each {|key, value|
				block_name = key
				value['�ضް'].each {|key,value|
					lup = PgmUnit.new(key, value['�ضް�÷��']).list_use_parameters
					lup.each {|key,value|
						pgm_name = key
						value.each {|value|
							if list_use_parameter[value] then
							else
								list_use_parameter[value] = Array.new
							end
							list_use_parameter[value] << "#{block_name}.#{pgm_name}"
						}
					}
				}
				value['����'].each {|key,value|
					item_name = key
					value['�ضް'].each  {|key,value|
						lup = PgmUnit.new(key, value['�ضް�÷��']).list_use_parameters
						lup.each {|key,value|
							pgm_name = key
							value.each {|value|
								if list_use_parameter[value] then
								else
									list_use_parameter[value] = Array.new
								end
								list_use_parameter[value] << "#{block_name}.#{item_name}.#{pgm_name}"
							}
						}
					}
				}
			}
			list_use_parameter.each{|key,value|
				value.uniq!
				value.sort!
			}
			list_use_parameter
		end


	
	end

end
