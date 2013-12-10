# -*- coding: Windows-31J -*-

=begin
�v���O�����P�ʂ𕪐͂��A�o�͂���

����: �I�u�W�F�N�g�E���X�g�E���|�[�g�t�@�C���̃v���O�����P�ʏ��

Version
0.01		2012/01/13		����

=end

require "oracle_program_unit"

module OracleObjectReport

=begin
		CLASS PgmUnitAnalyze
		�v���O�����P�ʕ���
=end
	class PgmUnitAnalyze

		include OracleSQLProgram
		include Nippan::Common
		
		def initialize(pgm_text)
			@pgm_unit_list = Hash.new
			@pgm_text = pgm_text
		end
	
	
		## ���͎��s
		def analyze
			w_text = @pgm_text
	    while w_text.size > 0 do
				if w_text =~ /^   \* ���O\s*(.*?)\n/i then
					unit_name = $1
				
					if $' =~ /^   ----------\n/ then
						analyze_pgm_unit(unit_name, $`)
					end
	        w_text = $'
	      else
	        w_text = ""
	      end
	    end
			
		end
	
		def analyze_pgm_unit(unit_name, unit_text)
			@pgm_unit_list[unit_name] = Hash.new if !@pgm_unit_list[unit_name]
	
			w_text = unit_text
	
			if w_text =~ /^   \* ��۸��ђP�ʂ�÷��\s*\n\n/mi then
				w_temp = $'
				if w_temp =~ /^   \* ��۸��ђP������\s*(\S*?)\n/mi then
	#puts $1
					@pgm_unit_list[unit_name][$1] = $`
			    w_text = $'
			   end
	    end
		end
	
		def print_info
			puts "��۸��ђP�ʖ�\t��۸��ђP������\t�ï�ߐ�\t���Đ�"
			@pgm_unit_list.each {|key, value|
				pgu_name = key
				value.each { |key,value|
					pu = PgmUnit.new(key,value)
					puts "#{pgu_name}\t#{key}\t#{pu.line_count}\t#{pu.comment_count}"
				}
			}
			end
	
		def count_pgm
			ret_val = 0
			@pgm_unit_list.each {|key, value|
				ret_val += value.size
			}
			ret_val
		end
	
	
		def count_pgm_steps
			ret_val = 0
			@pgm_unit_list.each {|key, value|
				pgm_name = key
				value.each {|key,value|
					pu = PgmUnit.new(pgm_name,value)
					ret_val += pu.line_count
				}
			}
			ret_val
		end
	
		def count_comment_steps
			ret_val = 0
			@pgm_unit_list.each {|key, value|
				pgm_name = key
				value.each {|key,value|
					pu = PgmUnit.new(pgm_name,value)
					ret_val += pu.comment_count
				}
			}
			ret_val
		end
	
		def package_list
			list_use_package = Hash.new
			@pgm_unit_list.each {|key, value|
				package_name = key
				list_use_package[package_name] = Hash.new
				value.each {|key, value|
					pgm_type = key
					pu = PgmUnit.new(package_name,value)
					list_use_package[package_name][pgm_type] = pu.list_use_packages
				}
			}
			list_use_package
		end

		def package_use_list
			list_use_package = Hash.new
			@pgm_unit_list.each {|key, value|
				package_name = key
				value.each {|key, value|
					pgm_type = key
					pu = PgmUnit.new(package_name,value)
					pu.list_use_packages.each{|key,value|
						pgm_name = key
						value.each {|value|
							if list_use_package[value] then
							else
								list_use_package[value] = Array.new
							end
							list_use_package[value] << "#{package_name}.#{pgm_name}"
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

		def parameter_use_list
			list_use_parameter = Hash.new
			@pgm_unit_list.each {|key, value|
				package_name = key
				value.each {|key, value|
					pgm_type = key
					pu = PgmUnit.new(package_name,value)
					pu.list_use_parameters.each{|key,value|
						pgm_name = key
						value.each {|value|
							if list_use_parameter[value] then
							else
								list_use_parameter[value] = Array.new
							end
							list_use_parameter[value] << "#{package_name}.#{pgm_name}"
						}
					}
				}
			}
			list_use_parameter.each{|key,value|
				value.uniq!
				value.sort!
			}
			list_use_parameter.sort
		end

		def print_info_detail
			@pgm_unit_list.each {|key, value|
				if value['�߯���ޖ{��'] then
					pu = PgmUnit.new(key,value['�߯���ޖ{��'])
					pu.list_pgm.each {|key,value|
						puts "-- �v���O������:#{key}"
						p1 = PgmUnit.new(key, value)
						plu = p1.list_use_package
						if plu then
							plu.each {|v|
								puts "---- #{v}"
							}
						end
		
						puts "---- ** SQL **"
		
						pls = p1.list_use_sql
						if pls then
							pls.each {|v|
								puts "----"
								puts "#{v}"
							}
						end
					}
				end
			}
		end
		
		#�t�@�C���o��
		def output_pgm_units(out_dir)
			if out_dir then
				make_dir(out_dir)
	
				@pgm_unit_list.each {|key, value|
					pgm_name = key
					if value['�߯���ގd�l��'] then
						$stdout = File.open(out_dir + key + '.pks' , "w")
						puts value['�߯���ގd�l��']
					end
	
					if value['�߯���ޖ{��'] then
						$stdout = File.open(out_dir + key + '.pkb' , "w")
						puts value['�߯���ޖ{��']
					end
	
					if value['��ۼ��ެ'] then
						$stdout = File.open(out_dir + key + '.sql' , "w")
						puts value['��ۼ��ެ']
					end
	
				}
			end
		end
	
	
	
	
	end

end
