# -*- coding: Windows-31J -*-

=begin
レコードグループを分析し、出力する

引数: オブジェクト・リスト・レポートファイルのレコードグループ情報

Version
0.01		2012/01/13		初版

=end

require "oracle_program_unit"

module OracleObjectReport

=begin
		CLASS RecordGroupAnalyze
		レコードグループ分析
=end
	class RecordGroupAnalyze

		include Nippan::Common
		
		def initialize(pgm_text)
			@rg_list = Hash.new
			@pgm_text = pgm_text
		end
	
	
		## 分析実行
		def analyze
			w_text = @pgm_text
	    while w_text.size > 0 do
				if w_text =~ /^   \* 名前 *(.*?)\n/i then
					rg_name = $1
					if $' =~ /^   ----------\n/ then
						analyze_record_group(rg_name, $`)
					end
	        w_text = $'
	      else
	        w_text = ""
	      end
	    end
			
		end
	
		def analyze_record_group(rg_name, rg_text)
			@rg_list[rg_name] = Hash.new
			@rg_list[rg_name]['列仕様'] = Hash.new
	
			w_text = rg_text
	
			if w_text =~ /^   [-\*\^] ﾚｺｰﾄﾞ･ｸﾞﾙｰﾌﾟ･ﾀｲﾌﾟ *(.*?)\n/i then
				@rg_list[rg_name]['ﾚｺｰﾄﾞ･ｸﾞﾙｰﾌﾟ･ﾀｲﾌﾟ'] = $1
		    w_text = $'
	    else
				@rg_list[rg_name]['ﾚｺｰﾄﾞ･ｸﾞﾙｰﾌﾟ･ﾀｲﾌﾟ'] = ''
	    end
	
			if w_text =~ /^   [-\*\^] ﾚｺｰﾄﾞ･ｸﾞﾙｰﾌﾟ問合せ\s*/i then
		    w_text = $'
				if $'=~ /   [-\*\^] ﾚｺｰﾄﾞ･ｸﾞﾙｰﾌﾟの取出しｻｲｽﾞ/mi then
					@rg_list[rg_name]['ﾚｺｰﾄﾞ･ｸﾞﾙｰﾌﾟ問合せ'] = $`
			    w_text = $'
				end
	#    else
	#			@rg_list[rg_name]['ﾚｺｰﾄﾞ･ｸﾞﾙｰﾌﾟ問合せ'] = ''
	    end
	
	    if w_text =~ /^   [-\*\^] 列仕様 *\n/ then
					analyze_columns(rg_name, $')
	    end
	
		end
	
	
		def analyze_columns(rg_name, col_text)
			w_text = col_text
	    while w_text.size > 0 do
				if w_text =~ /^     \* 名前 *(.*?)\n/i then
					col_name = $1
					if $' =~ /^     ----------\n/ then
						analyze_column(rg_name,  col_name, $`)
					end
	        w_text = $'
	      else
	        w_text = ""
	      end
	    end
			
		end
	
		def analyze_column(rg_name, col_name, col_text)
			@rg_list[rg_name]['列仕様'][col_name] = Hash.new
	
			w_text = col_text
	
			if w_text =~ /^     [-o\*\^] 最大長\s*(.*?)\n/i then
				@rg_list[rg_name]['列仕様'][col_name]['最大長'] = $1
		    w_text = $'
	    else
				@rg_list[rg_name]['列仕様'][col_name]['最大長'] = ''
	    end
	
			if w_text =~ /^     [-o\*\^] 列のﾃﾞｰﾀ型\s*(.*?)\n/i then
				@rg_list[rg_name]['列仕様'][col_name]['列のﾃﾞｰﾀ型'] = $1
		    w_text = $'
	    else
				@rg_list[rg_name]['列仕様'][col_name]['列のﾃﾞｰﾀ型'] = ''
	    end
	
	    if w_text =~ /^     [-o\*\^] 列値ﾘｽﾄ\s*\n/ then
				analyze_col_values(rg_name, col_name, $')
	    end
	
		end
	
		def analyze_col_values(rg_name, col_name, col_text)
			@rg_list[rg_name]['列仕様'][col_name]['列値ﾘｽﾄ'] = Hash.new
	
			w_text = col_text
	    while w_text.size > 0 do
				if w_text =~ /^       \* 名前\s*(.*?)\n/i then
					val_name = $1
					if $' =~ /^       ----------\n/ then
						analyze_col_value(rg_name,  col_name, val_name, $`)
					end
	        w_text = $'
	      else
	        w_text = ""
	      end
	    end
			
		end
	
		def analyze_col_value(rg_name, col_name, val_name, col_text)
			@rg_list[rg_name]['列仕様'][col_name]['列値ﾘｽﾄ'][val_name] = Hash.new
	
			w_text = col_text
	
			if w_text =~ /^       [-o\*\^] ﾘｽﾄ項目値\s*(.*?)\n/i then
				@rg_list[rg_name]['列仕様'][col_name]['列値ﾘｽﾄ'][val_name]['ﾘｽﾄ項目値'] = $1
		    w_text = $'
	    else
				@rg_list[rg_name]['列仕様'][col_name]['列値ﾘｽﾄ'][val_name]['ﾘｽﾄ項目値'] = ''
	    end
		end
	
		## 分析結果(レコードグループ情報)を出力
		def print_info
			puts "ﾚｺｰﾄﾞ･ｸﾞﾙｰﾌﾟ名\tﾚｺｰﾄﾞ･ｸﾞﾙｰﾌﾟ･ﾀｲﾌﾟ\t列名\t最大長\t列のﾃﾞｰﾀ型\tﾘｽﾄ項目値"
			@rg_list.each {|key, value|
				rg_name = key
				rg_type = value['ﾚｺｰﾄﾞ･ｸﾞﾙｰﾌﾟ･ﾀｲﾌﾟ']
				if value['列仕様'] then
					value['列仕様'].each {|key, value|
						list_val = nil
						if value['列値ﾘｽﾄ'] then
							list_val = Array.new
							value['列値ﾘｽﾄ'].each {|key, value|
								list_val << value['ﾘｽﾄ項目値']
							}
							if list_val.size == 0 then
								list_val = nil
							end
						end
						
						puts "#{rg_name}\t#{rg_type}\t#{key}\t#{value['最大長']}\t#{value['列のﾃﾞｰﾀ型']}\t#{list_val.join(",") if list_val}"
					}
	
				end
			}
		end
	
		#問い合わせ ファイル出力
		def output_query(out_dir)
			if out_dir then
				make_dir(out_dir)
				@rg_list.each {|key, value|
					rg_name = key
					if value['ﾚｺｰﾄﾞ･ｸﾞﾙｰﾌﾟ問合せ'] then
						$stdout = File.open(out_dir + key + '.sql' , "w")
						puts value['ﾚｺｰﾄﾞ･ｸﾞﾙｰﾌﾟ問合せ']
					end
				}
			end
		end
	
	end

end
