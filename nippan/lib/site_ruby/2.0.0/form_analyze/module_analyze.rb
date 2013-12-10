# -*- coding: Windows-31J -*-

=begin
モジュール情報を分析し、出力する

引数: オブジェクト・リスト・レポートファイルのモジュール情報

Version
0.01		2012/01/13		初版

=end

require "np_common"
require "oracle_program_unit"

module OracleObjectReport

=begin
		CLASS ModuleAnalyze
		モジュール分析
=end
	class ModuleAnalyze

		include OracleSQLProgram
		include Nippan::Common
		
		def initialize(pgm_text)
			@module_list = Hash.new
			@pgm_text = pgm_text
		end
	
	
		## 分析実行
		def analyze
			w_text = @pgm_text
			if w_text =~ /^ \* 名前\s*(.*?)\n/i then
				module_name = $1
				@module_list['名前'] = module_name
			end
	
	    if w_text =~ /^ \* ﾄﾘｶﾞｰ\s*\n/ then
		    w_text = $'
				if $' =~ /^ [-\*\^] 警告/mi then
					if $` then
						analyze_triggers($`)
					end
				end
	    end
		
		end
	
		def analyze_triggers(trigger_text)
			@module_list['ﾄﾘｶﾞｰ'] = Hash.new
			w_text = trigger_text
	    while w_text.size > 0 do
				if w_text =~ /^   \* 名前\s*(.*?)\n/i then
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
			@module_list['ﾄﾘｶﾞｰ'][trigger_name] = Hash.new
	
			w_text = trigger_text
	
			if w_text =~ /^   \* ﾄﾘｶﾞｰ･ﾃｷｽﾄ\s*\n\n/mi then
				if $' =~ /^   [-\*\^] 問合せ入力ﾓｰﾄﾞで起動/ then
					@module_list['ﾄﾘｶﾞｰ'][trigger_name]['ﾄﾘｶﾞｰ･ﾃｷｽﾄ'] = $`
				end
		    w_text = $'
	    else
				@module_list['ﾄﾘｶﾞｰ'][trigger_name]['ﾄﾘｶﾞｰ･ﾃｷｽﾄ'] = ''
	    end

			if w_text =~ /^   [-o\*\^] 実行の階層 *(\S*?)\n/i then
				@module_list['ﾄﾘｶﾞｰ'][trigger_name]['実行の階層'] = $1
		    w_text = $'
	    else
				@module_list['ﾄﾘｶﾞｰ'][trigger_name]['実行の階層'] = ''
	    end

		end
	
		## ﾄﾘｶﾞｰ数
		def count_triggers
			0
			if @module_list['ﾄﾘｶﾞｰ'] then
				@module_list['ﾄﾘｶﾞｰ'].size
			end
		end
	
		def module_name
			@module_list['名前']
		end
	
		## ﾄﾘｶﾞｰリストを出力
		def print_trigger_list
			if @module_list['ﾄﾘｶﾞｰ'] then
				@module_list['ﾄﾘｶﾞｰ'].each {|key,value|
					puts "モジュール\t#{module_name}\t#{key}\t#{value['実行の階層']}\t#{OracleSQLProgram::PgmUnit.new(key, value['ﾄﾘｶﾞｰ･ﾃｷｽﾄ']).line_count}"
				}
			end
		end
	
		#ﾄﾘｶﾞｰ ファイル出力
		def output_triggers(out_dir)
			if out_dir then
				make_dir(out_dir)
				make_dir(out_dir + module_name)
		
				if @module_list['ﾄﾘｶﾞｰ'] then
					@module_list['ﾄﾘｶﾞｰ'].each {|key,value|
						$stdout = File.open(out_dir + module_name + '/' + key + '.sql' , "w")
						puts value['ﾄﾘｶﾞｰ･ﾃｷｽﾄ']
					}
				end
			end
		end
	
		## ﾊﾟｯｹｰｼﾞ使用リスト
		def package_use_list
			list_use_package = Hash.new
			if @module_list['ﾄﾘｶﾞｰ'] then
				@module_list['ﾄﾘｶﾞｰ'].each {|key,value|
					lup = PgmUnit.new(key, value['ﾄﾘｶﾞｰ･ﾃｷｽﾄ']).list_use_packages
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
	

		## ﾊﾟﾗﾒｰﾀ使用リスト
		def parameter_use_list
			list_use_parameter = Hash.new
			if @module_list['ﾄﾘｶﾞｰ'] then
				@module_list['ﾄﾘｶﾞｰ'].each {|key,value|
					lup = PgmUnit.new(key, value['ﾄﾘｶﾞｰ･ﾃｷｽﾄ']).list_use_parameters
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
