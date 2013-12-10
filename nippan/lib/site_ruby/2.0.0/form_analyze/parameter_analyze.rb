# -*- coding: Windows-31J -*-

=begin
レコードグループを分析し、出力する

引数: オブジェクト・リスト・レポートファイルのレコードグループ情報

Version
0.01		2012/01/19		初版

=end

require "oracle_program_unit"

module OracleObjectReport

=begin
		CLASS ParameterAnalyze
		ﾌｫｰﾑ･ﾊﾟﾗﾒｰﾀ分析
=end
	class ParameterAnalyze

		include Nippan::Common
		
		def initialize(pgm_text)
			@para_list = Hash.new
			@pgm_text = pgm_text
		end
	
	
		## 分析実行
		def analyze
			w_text = @pgm_text
	    while w_text.size > 0 do
				if w_text =~ /^   \* 名前 *(.*?)\n/i then
					para_name = $1
					if $' =~ /^   ----------\n/ then
						analyze_parameter(para_name, $`)
					end
	        w_text = $'
	      else
	        w_text = ""
	      end
	    end
			
		end
	
		def analyze_parameter(para_name, para_text)
			@para_list[para_name] = Hash.new
	
			w_text = para_text
	
			if w_text =~ /^   [-\*\^] ｺﾒﾝﾄ *(.*?)\n/i then
				@para_list[para_name]['ｺﾒﾝﾄ'] = $1
		    w_text = $'
	    else
				@para_list[para_name]['ｺﾒﾝﾄ'] = ''
	    end
	
			if w_text =~ /^   [-\*\^] ﾊﾟﾗﾒｰﾀのﾃﾞｰﾀ型 *(.*?)\n/i then
				@para_list[para_name]['ﾊﾟﾗﾒｰﾀのﾃﾞｰﾀ型'] = $1
		    w_text = $'
	    else
				@para_list[para_name]['ﾊﾟﾗﾒｰﾀのﾃﾞｰﾀ型'] = ''
	    end
	
			if w_text =~ /^   [-\*\^] 最大長 *(.*?)\n/i then
				@para_list[para_name]['最大長'] = $1
		    w_text = $'
	    else
				@para_list[para_name]['最大長'] = ''
	    end
	
			if w_text =~ /^   [-\*\^] ﾊﾟﾗﾒｰﾀの初期値 *(.*?)\n/i then
				@para_list[para_name]['ﾊﾟﾗﾒｰﾀの初期値'] = $1
		    w_text = $'
	    else
				@para_list[para_name]['ﾊﾟﾗﾒｰﾀの初期値'] = ''
	    end
		end
	
	
		## 分析結果(レコードグループ情報)を出力
		def print_info
			puts "ﾊﾟﾗﾒｰﾀ名\tｺﾒﾝﾄ\tﾃﾞｰﾀ型\t最大長\t初期値"
			@para_list.each {|key, value|
				para_name = key
				puts "#{para_name}\t#{value['ｺﾒﾝﾄ']}\t#{value['ﾊﾟﾗﾒｰﾀのﾃﾞｰﾀ型']}\t#{value['最大長']}\t#{value['ﾊﾟﾗﾒｰﾀの初期値']}"
			}
		end
	
	end #class ParameterAnalyze

end #module
