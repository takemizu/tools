# -*- coding: Windows-31J -*-

=begin
Oracle Form プログラムのオブジェクト・リスト・レポートを分析し、出力する

引数: 第1引数がファイル名の場合
		1.オブジェクト・リスト・レポートファイル名
		2.出力先ディレクトリ名(省略時:標準出力)
		
	オブジェクト・リスト・レポートを分析し、各種分析結果を出力する。

	  第1引数がフォルダー名の場合
	 	1.分析対象フォルダー名

	オブジェクト・リスト・レポートを分析し、モジュール情報を出力する。

Version
0.01		2012/01/13		初版
0.02		2012/01/18		module OracleObjectReport 作成
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
	Formsプログラムの分析を行う
=end
	class FormAnalyze

		include OracleSQLProgram
		include Nippan::Common
		
		def initialize(fname, out_dir=nil)
			@file_name = fname.gsub("\\","/")
			@output_dir = out_dir
	
		end
	
	
		## 分析実行
		def execute
		
			@frm_text = File.read(@file_name)
			@trigger_list = Hash.new
			
			if @frm_text =~ /(^ \* ﾌﾞﾛｯｸ\s*\n)/mi then
				@module_ana = ModuleAnalyze.new($`)
				@module_ana.analyze
			else
				return
			end
	
			if @frm_text =~ /(^ \* ﾌﾞﾛｯｸ\s*\n)/mi then
				if  $' =~ /^ \* ｷｬﾝﾊﾞｽ/mi then
					@blocks_ana = BlockAnalyze.new($`)
					@blocks_ana.analyze
				end
			end
	
			if @frm_text =~ /(^ \* ﾌｫｰﾑ･ﾊﾟﾗﾒｰﾀ *\n)/mi then
				if  $' =~ /^ \* 値ﾘｽﾄ/mi then
					@parameter_ana = ParameterAnalyze.new($`)
					@parameter_ana.analyze
				end
			end
	
			if @frm_text =~ /(^ \* 値ﾘｽﾄ\s*\n)/mi then
				if  $' =~ /^ \* ﾒﾆｭｰ/mi then
					@lv_ana = ListValueAnalyze.new($`)
					@lv_ana.analyze
				end
			end
	
			if @frm_text =~ /(^ \* ﾌﾟﾛｸﾞﾗﾑ単位\s*\n)/mi then
				if  $' =~ /^ \* ﾌﾟﾛﾊﾟﾃｨ･ｸﾗｽ/mi then
					@pgm_units_ana = PgmUnitAnalyze.new($`)
					@pgm_units_ana.analyze
				end
			end
	
			if @frm_text =~ /(^ \* ﾚｺｰﾄﾞ･ｸﾞﾙｰﾌﾟ\s*\n)/mi then
				if  $' =~ /^ \* 可視属性/mi then
					@rg_ana = RecordGroupAnalyze.new($`)
					@rg_ana.analyze
				end
			end
		end
	
		## モジュール情報
		def module_info
			if @module_ana then
			else
				return
			end
	
			"#{@module_ana.module_name}\t#{@blocks_ana.count_blocks}\t#{@blocks_ana.count_items}\t#{@lv_ana.count_list}\t#{@module_ana.count_triggers+@blocks_ana.count_triggers}\t#{@pgm_units_ana.count_pgm}\t#{@pgm_units_ana.count_pgm_steps}\t#{@pgm_units_ana.count_comment_steps}"
		end

		## パッケージ情報
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

		## 分析結果出力
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

			##出力先を引数で指定されたファイルに変更
			if @output_dir then
				$stdout = File.open(@output_dir+'module_info.txt', "w")
			end
			puts "モジュール名\tブロック数\t項目数\t値リスト数\tﾄﾘｶﾞｰ数\tﾌﾟﾛｸﾞﾗﾑ単位数\tｽﾃｯﾌﾟ数\tｺﾒﾝﾄ数"
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
	
			#ﾄﾘｶﾞｰ情報出力
			puts "レベル\t名前\tﾄﾘｶﾞｰ名\t実行の階層\t\ステップ数"
			@module_ana.print_trigger_list
			@blocks_ana.print_trigger_list
	
			if @output_dir then
				#ファイル出力
				@module_ana.output_triggers(@output_dir + 'ﾄﾘｶﾞｰ/')
				@blocks_ana.output_triggers(@output_dir + 'ﾄﾘｶﾞｰ/'+ @module_ana.module_name + '/')
		
				@rg_ana.output_query(@output_dir + '値リスト/')
		
				@pgm_units_ana.output_pgm_units(@output_dir + 'ﾌﾟﾛｸﾞﾗﾑ単位/')
			end

			if @output_dir then
				$stdout = File.open(@output_dir+'parameter_use_info.txt', "w")
			end
			puts "ﾌｫｰﾑ･ﾊﾟﾗﾒｰﾀ名\t使用しているﾌﾟﾛｸﾞﾗﾑ単位"
			parameter_use_list.sort.each {|key,value|
				package_name = key
				value.each {|value|
					puts "#{package_name}\t#{value}"
				}
			}

			if @output_dir then
				$stdout = File.open(@output_dir+'package_use_info.txt', "w")
			end
			puts "ﾊﾟｯｹｰｼﾞ名\t使用しているﾌﾟﾛｸﾞﾗﾑ単位"
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
