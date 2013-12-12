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
0.01		2012/01/13		

=end

require "form_analyze"

include OracleObjectReport
include Nippan::Common

if ARGV[0] then
	if File.exist?(ARGV[0]) then
		if File.file?(ARGV[0]) then
			form_analyze = FormAnalyze.new(ARGV[0], ARGV[1])
			form_analyze.execute
			form_analyze.output
		else
			puts "モジュール名\tブロック数\t項目数\t値リスト数\tﾄﾘｶﾞｰ数\tﾌﾟﾛｸﾞﾗﾑ単位数\tｽﾃｯﾌﾟ数\tｺﾒﾝﾄ数"
			ARGV.each {|dir|
				if File.exist?(dir) then
					if File.file?(dir) then
					else
						input_dir = cnv_unix_filename(dir)
						if input_dir then
							if input_dir =~ /\/$/ then
							else
								input_dir += '/'
							end
						end
						wk_files = Dir.glob(input_dir + "**/*.txt") #リリース対象のファイル名を取得
							
						wk_files.each { |source_file|
							form_analyze = FormAnalyze.new(source_file)
							form_analyze.execute
							puts form_analyze.module_info
						}
					end
				end
			}
		end
	end
else
end
