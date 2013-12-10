# -*- coding: Windows-31J -*-

=begin
ブロックを分析し、出力する

引数: オブジェクト・リスト・レポートファイルのブロック情報

Version
0.01		2012/01/13		初版

=end

require "oracle_program_unit"


module OracleObjectReport
=begin
		CLASS BlockAnalyze
		ブロック分析
=end
	class BlockAnalyze

		include OracleSQLProgram
		include Nippan::Common
		
		def initialize(pgm_text)
			@block_list = Hash.new
			@pgm_text = pgm_text
		end
	
	
		## 分析実行
		def analyze
			w_text = @pgm_text
	    while w_text.size > 0 do
				if w_text =~ /^   \* 名前\s*(.*?)\n/i then
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
			@block_list[block_name]['ﾄﾘｶﾞｰ'] = Hash.new
			@block_list[block_name]['項目'] = Hash.new
	
			w_text = block_text
	
			if w_text =~ /^   [-\*\^] 表示ﾚｺｰﾄﾞ数 *(.*?)\n/i then
				@block_list[block_name]['表示ﾚｺｰﾄﾞ数'] = $1
		    w_text = $'
	    else
				@block_list[block_name]['表示ﾚｺｰﾄﾞ数'] = ''
	    end
	
			if w_text =~ /^   \* 問合せﾃﾞｰﾀ･ｿｰｽの名前 *(.*?)\n/i then
				@block_list[block_name]['問合せﾃﾞｰﾀ･ｿｰｽの名前'] = $1
		    w_text = $'
	    else
				@block_list[block_name]['問合せﾃﾞｰﾀ･ｿｰｽの名前'] = ''
	    end
	
	    
	    if w_text =~ /^   \* ﾄﾘｶﾞｰ\s*\n/ then
		    w_text = $'
				if $' =~ /^   \* 項目/mi then
					if $` then
						analyze_triggers(block_name, $`)
					end
				end
	    end
	
	    if w_text =~ /^   \* 項目\s*\n/ then
		    w_text = $'
				if $' =~ /^   - ﾘﾚｰｼｮﾝ/mi then
					if $` then
						analyze_items(block_name, $`)
					end
				end
	    end
		end
	
		def analyze_triggers(block_name, trigger_text)
			w_text = trigger_text
	    while w_text.size > 0 do
				if w_text =~ /^     \* 名前\s*(.*?)\n/i then
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
			@block_list[block_name]['ﾄﾘｶﾞｰ'][trigger_name] = Hash.new
	
			w_text = trigger_text
	
			if w_text =~ /^     \* ﾄﾘｶﾞｰ･ﾃｷｽﾄ\s*\n\n/mi then
				if $' =~ /^     [-\*\^] 問合せ入力ﾓｰﾄﾞで起動/ then
					@block_list[block_name]['ﾄﾘｶﾞｰ'][trigger_name]['ﾄﾘｶﾞｰ･ﾃｷｽﾄ'] = $`
				end
		    w_text = $'
	    else
				@block_list[block_name]['ﾄﾘｶﾞｰ'][trigger_name]['ﾄﾘｶﾞｰ･ﾃｷｽﾄ'] = ''
	    end
	
			if w_text =~ /^     [-o\*\^] 実行の階層 *(\S*?)\n/i then
				@block_list[block_name]['ﾄﾘｶﾞｰ'][trigger_name]['実行の階層'] = $1
		    w_text = $'
	    else
				@block_list[block_name]['ﾄﾘｶﾞｰ'][trigger_name]['実行の階層'] = ''
	    end
		end
	
	
		def analyze_items(block_name, item_text)
			w_text = item_text
	    while w_text.size > 0 do
				if w_text =~ /^     \* 名前\s*(.*?)\n/i then
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
			@block_list[block_name]['項目'][item_name] = Hash.new
	
			w_text = item_text
	
			if w_text =~ /^     [-o\*\^] 項目ﾀｲﾌﾟ *(.*?)\n/i then
				@block_list[block_name]['項目'][item_name]['項目ﾀｲﾌﾟ'] = $1
		    w_text = $'
	    else
				@block_list[block_name]['項目'][item_name]['項目ﾀｲﾌﾟ'] = ''
	    end
	
			if w_text =~ /^     [-o\*\^] ﾃﾞｰﾀ型 *(.*?)\n/i then
				@block_list[block_name]['項目'][item_name]['ﾃﾞｰﾀ型'] = $1
		    w_text = $'
	    else
				@block_list[block_name]['項目'][item_name]['ﾃﾞｰﾀ型'] = ''
	    end
	
			if w_text =~ /^     [-o\*\^] 最大長 *(.*?)\n/i then
				@block_list[block_name]['項目'][item_name]['最大長'] = $1
		    w_text = $'
	    else
				@block_list[block_name]['項目'][item_name]['最大長'] = ''
	    end
	
			if w_text =~ /^     [-o\*\^] 必須 *(.*?)\n/i then
				@block_list[block_name]['項目'][item_name]['必須'] = $1
		    w_text = $'
	    else
				@block_list[block_name]['項目'][item_name]['必須'] = ''
	    end
	
			if w_text =~ /^     [-o\*\^] 列名 *(\S*?)\n/i then
				@block_list[block_name]['項目'][item_name]['列名'] = $1
		    w_text = $'
	    else
				@block_list[block_name]['項目'][item_name]['列名'] = ''
	    end
	
			if w_text =~ /^     [-o\*\^] 値ﾘｽﾄ *(\S*?)\n/i then
				@block_list[block_name]['項目'][item_name]['値ﾘｽﾄ'] = $1
		    w_text = $'
	    else
				@block_list[block_name]['項目'][item_name]['値ﾘｽﾄ'] = ''
	    end
	
			if w_text =~ /^     [-o\*\^] 可視 *(\S*?)\n/i then
				@block_list[block_name]['項目'][item_name]['可視'] = $1
		    w_text = $'
	    else
				@block_list[block_name]['項目'][item_name]['可視'] = ''
	    end
	
			if w_text =~ /^     [-o\*\^] ｷｬﾝﾊﾞｽ *(\S*?)\n/i then
				@block_list[block_name]['項目'][item_name]['ｷｬﾝﾊﾞｽ'] = $1
		    w_text = $'
	    else
				@block_list[block_name]['項目'][item_name]['ｷｬﾝﾊﾞｽ'] = ''
	    end
	
			if w_text =~ /^     [-o\*\^] ﾀﾌﾞ･ﾍﾟｰｼﾞ *(\S*?)\n/i then
				@block_list[block_name]['項目'][item_name]['ﾀﾌﾞ･ﾍﾟｰｼﾞ'] = $1
		    w_text = $'
	    else
				@block_list[block_name]['項目'][item_name]['ﾀﾌﾞ･ﾍﾟｰｼﾞ'] = ''
	    end
	
			if w_text =~ /^     [-o\*\^] X位置 *(\S*?)\n/i then
				@block_list[block_name]['項目'][item_name]['X位置'] = $1
		    w_text = $'
	    else
				@block_list[block_name]['項目'][item_name]['X位置'] = ''
	    end
	
			if w_text =~ /^     [-o\*\^] Y位置 *(\S*?)\n/i then
				@block_list[block_name]['項目'][item_name]['Y位置'] = $1
		    w_text = $'
	    else
				@block_list[block_name]['項目'][item_name]['Y位置'] = ''
	    end
	
			if w_text =~ /^     [-o\*\^] 幅 *(\S*?)\n/i then
				@block_list[block_name]['項目'][item_name]['幅'] = $1
		    w_text = $'
	    else
				@block_list[block_name]['項目'][item_name]['幅'] = ''
	    end
	
			if w_text =~ /^     [-o\*\^] 高さ *(\S*?)\n/i then
				@block_list[block_name]['項目'][item_name]['高さ'] = $1
		    w_text = $'
	    else
				@block_list[block_name]['項目'][item_name]['高さ'] = ''
	    end
	
	    if w_text =~ /^     [-o\*\^] ﾄﾘｶﾞｰ *\n/ then
		    w_text = $'
				if $' then
					analyze_item_triggers(block_name, item_name, $')
				end
	    end
		end
	
		def analyze_item_triggers(block_name, item_name, trigger_text)
			@block_list[block_name]['項目'][item_name]['ﾄﾘｶﾞｰ'] = Hash.new
			
			w_text = trigger_text
	    while w_text.size > 0 do
				if w_text =~ /^       \* 名前\s*(.*?)\n/i then
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
			@block_list[block_name]['項目'][item_name]['ﾄﾘｶﾞｰ'][trigger_name] = Hash.new
	
			w_text = trigger_text
	
			if w_text =~ /^       \* ﾄﾘｶﾞｰ･ﾃｷｽﾄ\s*\n\n/mi then
				if $' =~ /^       [-\*\^] 問合せ入力ﾓｰﾄﾞで起動/ then
					@block_list[block_name]['項目'][item_name]['ﾄﾘｶﾞｰ'][trigger_name]['ﾄﾘｶﾞｰ･ﾃｷｽﾄ'] = $`
				end
		    w_text = $'
	    else
				@block_list[block_name]['項目'][item_name]['ﾄﾘｶﾞｰ'][trigger_name]['ﾄﾘｶﾞｰ･ﾃｷｽﾄ'] = ''
	    end

			if w_text =~ /^       [-o\*\^] 実行の階層 *(\S*?)\n/i then
				@block_list[block_name]['項目'][item_name]['ﾄﾘｶﾞｰ'][trigger_name]['実行の階層'] = $1
		    w_text = $'
	    else
				@block_list[block_name]['項目'][item_name]['ﾄﾘｶﾞｰ'][trigger_name]['実行の階層'] = ''
	    end
	
		end
		
		## ブロック数
		def count_blocks
			@block_list.size
		end
	
		## 項目数
		def count_items
			ret_val = 0
			@block_list.each {|key, value|
				ret_val += value['項目'].size
			}
			ret_val
		end
		
		## ﾄﾘｶﾞｰ数
		def count_triggers
			ret_val = 0
			@block_list.each {|key, value|
				if value['ﾄﾘｶﾞｰ'] then
					ret_val += value['ﾄﾘｶﾞｰ'].size
				end
				block_name = key
				value['項目'].each {|key,value|
					if value['ﾄﾘｶﾞｰ'] then
						ret_val += value['ﾄﾘｶﾞｰ'].size
					end
				}
			}
			ret_val
		end
	
	
		## 分析結果(ブロック情報)を出力
		def print_block_info
			puts "ブロック名\t表示ﾚｺｰﾄﾞ数\tソース名"
			@block_list.each {|key, value|
				puts "#{key}\t#{value['表示ﾚｺｰﾄﾞ数']}\t#{value['問合せﾃﾞｰﾀ･ｿｰｽの名前']}"
			}
	
		end
	
		## 分析結果(項目情報)を出力
		def print_item_info
			puts "ブロック名\t項目名\t項目ﾀｲﾌﾟ\tﾃﾞｰﾀ型\t最大長\t必須\t列名\t値ﾘｽﾄ\t可視\tｷｬﾝﾊﾞｽ\tﾀﾌﾞ･ﾍﾟｰｼﾞ\tX位置\tY位置\t幅\t高さ"
			@block_list.each {|key, value|
				block_name = key
				value['項目'].each {|key,value|
					puts "#{block_name}\t#{key}\t#{value['項目ﾀｲﾌﾟ']}\t#{value['ﾃﾞｰﾀ型']}\t#{value['最大長']}\t#{value['必須']}\t#{value['列名']}\t#{value['値ﾘｽﾄ']}\t#{value['可視']}\t#{value['ｷｬﾝﾊﾞｽ']}\t#{value['ﾀﾌﾞ･ﾍﾟｰｼﾞ']}\t#{value['X位置']}\t#{value['Y位置']}\t#{value['幅']}\t#{value['高さ']}"
				}
			}
	
		end
	
		def print_trigger_list
			@block_list.each {|key, value|
				block_name = key
				value['ﾄﾘｶﾞｰ'].each {|key,value|
					puts "ブロック\t#{block_name}\t#{key}\t#{value['実行の階層']}\t#{PgmUnit.new(key, value['ﾄﾘｶﾞｰ･ﾃｷｽﾄ']).line_count}"
				}
				value['項目'].each {|key,value|
					item_name = key
					value['ﾄﾘｶﾞｰ'].each  {|key,value|
						puts "項目\t#{block_name}.#{item_name}\t#{key}\t#{value['実行の階層']}\t#{PgmUnit.new(key, value['ﾄﾘｶﾞｰ･ﾃｷｽﾄ']).line_count}"
					}
				}
			}
		end
	
		#ﾄﾘｶﾞｰ ファイル出力
		def output_triggers(out_dir)
			if out_dir then
	
				@block_list.each {|key, value|
					block_name = key
					value['ﾄﾘｶﾞｰ'].each {|key,value|
						make_dir(out_dir + block_name + '/')
						$stdout = File.open(out_dir + block_name + '/' + key + '.sql' , "w")
						puts value['ﾄﾘｶﾞｰ･ﾃｷｽﾄ']
					}
					value['項目'].each {|key,value|
						item_name = key
						value['ﾄﾘｶﾞｰ'].each  {|key,value|
							make_dir(out_dir + block_name + '/' + item_name + '/')
							$stdout = File.open(out_dir + block_name + '/' + item_name + '/' + key + '.sql' , "w")
							puts value['ﾄﾘｶﾞｰ･ﾃｷｽﾄ']
						}
					}
				}
			end
		end
	
		## ﾊﾟｯｹｰｼﾞ使用リスト
		def package_use_list


			list_use_package = Hash.new

			@block_list.each {|key, value|
				block_name = key
				value['ﾄﾘｶﾞｰ'].each {|key,value|
					lup = PgmUnit.new(key, value['ﾄﾘｶﾞｰ･ﾃｷｽﾄ']).list_use_packages
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
				value['項目'].each {|key,value|
					item_name = key
					value['ﾄﾘｶﾞｰ'].each  {|key,value|
						lup = PgmUnit.new(key, value['ﾄﾘｶﾞｰ･ﾃｷｽﾄ']).list_use_packages
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

		## ﾊﾟﾗﾒｰﾀ使用リスト
		def parameter_use_list


			list_use_parameter = Hash.new

			@block_list.each {|key, value|
				block_name = key
				value['ﾄﾘｶﾞｰ'].each {|key,value|
					lup = PgmUnit.new(key, value['ﾄﾘｶﾞｰ･ﾃｷｽﾄ']).list_use_parameters
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
				value['項目'].each {|key,value|
					item_name = key
					value['ﾄﾘｶﾞｰ'].each  {|key,value|
						lup = PgmUnit.new(key, value['ﾄﾘｶﾞｰ･ﾃｷｽﾄ']).list_use_parameters
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
