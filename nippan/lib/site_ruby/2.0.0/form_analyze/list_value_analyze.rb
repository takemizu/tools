# -*- coding: Windows-31J -*-

=begin
値リストを分析し、出力する

引数: オブジェクト・リスト・レポートファイルの値リスト情報

Version
0.01		2012/01/13		初版

=end

module OracleObjectReport

=begin
		CLASS ListValueAnalyze
		値リスト分析
=end
	class ListValueAnalyze
		
		def initialize(pgm_text)
			@lv_list = Hash.new
			@pgm_text = pgm_text
		end
	
	
		## 分析実行
		def analyze
			w_text = @pgm_text
	    while w_text.size > 0 do
				if w_text =~ /^   \* 名前\s*(.*?)\n/i then
					lv_name = $1
					if $' =~ /^   ----------\n/ then
						analyze_list_value(lv_name, $`)
					end
	        w_text = $'
	      else
	        w_text = ""
	      end
	    end
			
		end
	
		def analyze_list_value(lv_name, lv_text)
			@lv_list[lv_name] = Hash.new
	
			w_text = lv_text
	
			if w_text =~ /^   [-\*\^] ﾚｺｰﾄﾞ･ｸﾞﾙｰﾌﾟ\s*(.*?)\n/i then
				@lv_list[lv_name]['ﾚｺｰﾄﾞ･ｸﾞﾙｰﾌﾟ'] = $1
		    w_text = $'
	    else
				@lv_list[lv_name]['ﾚｺｰﾄﾞ･ｸﾞﾙｰﾌﾟ'] = ''
	    end
	
	    if w_text =~ /^   [-\*\^] 列ﾏｯﾋﾟﾝｸﾞ･ﾌﾟﾛﾊﾟﾃｨ\s*\n/ then
				if $' =~ /^   [-\*\^] 表示前ﾌｨﾙﾀ/ then
					if $` then
						analyze_columns(lv_name, $`)
					end
				end
	    end
	
		end
	
		def analyze_columns(lv_name, col_text)
			@lv_list[lv_name]['列ﾏｯﾋﾟﾝｸﾞ･ﾌﾟﾛﾊﾟﾃｨ'] = Hash.new
			w_text = col_text
	    while w_text.size > 0 do
				if w_text =~ /^     \* 名前\s*(.*?)\n/i then
					col_name = $1
					if $' =~ /^     ----------\n/ then
						analyze_column(lv_name,  col_name, $`)
					end
	        w_text = $'
	      else
	        w_text = ""
	      end
	    end
			
		end
	
		def analyze_column(lv_name, col_name, col_text)
			@lv_list[lv_name]['列ﾏｯﾋﾟﾝｸﾞ･ﾌﾟﾛﾊﾟﾃｨ'][col_name] = Hash.new
	
			w_text = col_text
	
			if w_text =~ /^     [-o\*\^] ﾀｲﾄﾙ *(.*?)\n/i then
				@lv_list[lv_name]['列ﾏｯﾋﾟﾝｸﾞ･ﾌﾟﾛﾊﾟﾃｨ'][col_name]['ﾀｲﾄﾙ'] = $1
		    w_text = $'
	    else
				@lv_list[lv_name]['列ﾏｯﾋﾟﾝｸﾞ･ﾌﾟﾛﾊﾟﾃｨ'][col_name]['ﾀｲﾄﾙ'] = ''
	    end
	
			if w_text =~ /^     [-o\*\^] 戻り項目 *(.*?)\n/i then
				@lv_list[lv_name]['列ﾏｯﾋﾟﾝｸﾞ･ﾌﾟﾛﾊﾟﾃｨ'][col_name]['戻り項目'] = $1
		    w_text = $'
	    else
				@lv_list[lv_name]['列ﾏｯﾋﾟﾝｸﾞ･ﾌﾟﾛﾊﾟﾃｨ'][col_name]['戻り項目'] = ''
	    end
	
			if w_text =~ /^     [-o\*\^] ﾃﾞｨｽﾌﾟﾚｲ幅 *(.*?)\n/i then
				@lv_list[lv_name]['列ﾏｯﾋﾟﾝｸﾞ･ﾌﾟﾛﾊﾟﾃｨ'][col_name]['ﾃﾞｨｽﾌﾟﾚｲ幅'] = $1
		    w_text = $'
	    else
				@lv_list[lv_name]['列ﾏｯﾋﾟﾝｸﾞ･ﾌﾟﾛﾊﾟﾃｨ'][col_name]['ﾃﾞｨｽﾌﾟﾚｲ幅'] = ''
	    end
		end
		
		def count_list
			@lv_list.size
		end
	
		## 分析結果(値リスト情報)を出力
		def print_info
			puts "値リスト\tﾚｺｰﾄﾞ･ｸﾞﾙｰﾌﾟ"
			@lv_list.each {|key, value|
				puts "#{key}\t#{value['ﾚｺｰﾄﾞ･ｸﾞﾙｰﾌﾟ']}"
			}
		end
	
		def print_col_info
			puts "値リスト\t列名\tﾀｲﾄﾙ\t戻り項目\tﾃﾞｨｽﾌﾟﾚｲ幅"
			@lv_list.each {|key, value|
				lv_name = key
				value['列ﾏｯﾋﾟﾝｸﾞ･ﾌﾟﾛﾊﾟﾃｨ'].each {|key,value|
					puts "#{lv_name}\t#{key}\t#{value['ﾀｲﾄﾙ']}\t#{value['戻り項目']}\t#{value['ﾃﾞｨｽﾌﾟﾚｲ幅']}"
				}
			}
		end
	
	end

end
