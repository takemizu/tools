# -*- coding: Windows-31J -*-

=begin
プログラム単位を分析し、出力する

引数: オブジェクト・リスト・レポートファイルのプログラム単位情報

Version
0.01		2012/01/13		初版

=end

require "oracle_program_unit"

module OracleObjectReport

=begin
		CLASS PgmUnitAnalyze
		プログラム単位分析
=end
	class PgmUnitAnalyze

		include OracleSQLProgram
		include Nippan::Common
		
		def initialize(pgm_text)
			@pgm_unit_list = Hash.new
			@pgm_text = pgm_text
		end
	
	
		## 分析実行
		def analyze
			w_text = @pgm_text
	    while w_text.size > 0 do
				if w_text =~ /^   \* 名前\s*(.*?)\n/i then
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
	
			if w_text =~ /^   \* ﾌﾟﾛｸﾞﾗﾑ単位のﾃｷｽﾄ\s*\n\n/mi then
				w_temp = $'
				if w_temp =~ /^   \* ﾌﾟﾛｸﾞﾗﾑ単位ﾀｲﾌﾟ\s*(\S*?)\n/mi then
	#puts $1
					@pgm_unit_list[unit_name][$1] = $`
			    w_text = $'
			   end
	    end
		end
	
		def print_info
			puts "ﾌﾟﾛｸﾞﾗﾑ単位名\tﾌﾟﾛｸﾞﾗﾑ単位ﾀｲﾌﾟ\tｽﾃｯﾌﾟ数\tｺﾒﾝﾄ数"
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
				if value['ﾊﾟｯｹｰｼﾞ本体'] then
					pu = PgmUnit.new(key,value['ﾊﾟｯｹｰｼﾞ本体'])
					pu.list_pgm.each {|key,value|
						puts "-- プログラム名:#{key}"
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
		
		#ファイル出力
		def output_pgm_units(out_dir)
			if out_dir then
				make_dir(out_dir)
	
				@pgm_unit_list.each {|key, value|
					pgm_name = key
					if value['ﾊﾟｯｹｰｼﾞ仕様部'] then
						$stdout = File.open(out_dir + key + '.pks' , "w")
						puts value['ﾊﾟｯｹｰｼﾞ仕様部']
					end
	
					if value['ﾊﾟｯｹｰｼﾞ本体'] then
						$stdout = File.open(out_dir + key + '.pkb' , "w")
						puts value['ﾊﾟｯｹｰｼﾞ本体']
					end
	
					if value['ﾌﾟﾛｼｰｼﾞｬ'] then
						$stdout = File.open(out_dir + key + '.sql' , "w")
						puts value['ﾌﾟﾛｼｰｼﾞｬ']
					end
	
				}
			end
		end
	
	
	
	
	end

end
