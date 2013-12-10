# -*- coding: Windows-31J -*-

=begin
���R�[�h�O���[�v�𕪐͂��A�o�͂���

����: �I�u�W�F�N�g�E���X�g�E���|�[�g�t�@�C���̃��R�[�h�O���[�v���

Version
0.01		2012/01/13		����

=end

require "oracle_program_unit"

module OracleObjectReport

=begin
		CLASS RecordGroupAnalyze
		���R�[�h�O���[�v����
=end
	class RecordGroupAnalyze

		include Nippan::Common
		
		def initialize(pgm_text)
			@rg_list = Hash.new
			@pgm_text = pgm_text
		end
	
	
		## ���͎��s
		def analyze
			w_text = @pgm_text
	    while w_text.size > 0 do
				if w_text =~ /^   \* ���O *(.*?)\n/i then
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
			@rg_list[rg_name]['��d�l'] = Hash.new
	
			w_text = rg_text
	
			if w_text =~ /^   [-\*\^] ں��ޥ��ٰ�ߥ���� *(.*?)\n/i then
				@rg_list[rg_name]['ں��ޥ��ٰ�ߥ����'] = $1
		    w_text = $'
	    else
				@rg_list[rg_name]['ں��ޥ��ٰ�ߥ����'] = ''
	    end
	
			if w_text =~ /^   [-\*\^] ں��ޥ��ٰ�ߖ⍇��\s*/i then
		    w_text = $'
				if $'=~ /   [-\*\^] ں��ޥ��ٰ�߂̎�o������/mi then
					@rg_list[rg_name]['ں��ޥ��ٰ�ߖ⍇��'] = $`
			    w_text = $'
				end
	#    else
	#			@rg_list[rg_name]['ں��ޥ��ٰ�ߖ⍇��'] = ''
	    end
	
	    if w_text =~ /^   [-\*\^] ��d�l *\n/ then
					analyze_columns(rg_name, $')
	    end
	
		end
	
	
		def analyze_columns(rg_name, col_text)
			w_text = col_text
	    while w_text.size > 0 do
				if w_text =~ /^     \* ���O *(.*?)\n/i then
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
			@rg_list[rg_name]['��d�l'][col_name] = Hash.new
	
			w_text = col_text
	
			if w_text =~ /^     [-o\*\^] �ő咷\s*(.*?)\n/i then
				@rg_list[rg_name]['��d�l'][col_name]['�ő咷'] = $1
		    w_text = $'
	    else
				@rg_list[rg_name]['��d�l'][col_name]['�ő咷'] = ''
	    end
	
			if w_text =~ /^     [-o\*\^] ����ް��^\s*(.*?)\n/i then
				@rg_list[rg_name]['��d�l'][col_name]['����ް��^'] = $1
		    w_text = $'
	    else
				@rg_list[rg_name]['��d�l'][col_name]['����ް��^'] = ''
	    end
	
	    if w_text =~ /^     [-o\*\^] ��lؽ�\s*\n/ then
				analyze_col_values(rg_name, col_name, $')
	    end
	
		end
	
		def analyze_col_values(rg_name, col_name, col_text)
			@rg_list[rg_name]['��d�l'][col_name]['��lؽ�'] = Hash.new
	
			w_text = col_text
	    while w_text.size > 0 do
				if w_text =~ /^       \* ���O\s*(.*?)\n/i then
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
			@rg_list[rg_name]['��d�l'][col_name]['��lؽ�'][val_name] = Hash.new
	
			w_text = col_text
	
			if w_text =~ /^       [-o\*\^] ؽč��ڒl\s*(.*?)\n/i then
				@rg_list[rg_name]['��d�l'][col_name]['��lؽ�'][val_name]['ؽč��ڒl'] = $1
		    w_text = $'
	    else
				@rg_list[rg_name]['��d�l'][col_name]['��lؽ�'][val_name]['ؽč��ڒl'] = ''
	    end
		end
	
		## ���͌���(���R�[�h�O���[�v���)���o��
		def print_info
			puts "ں��ޥ��ٰ�ߖ�\tں��ޥ��ٰ�ߥ����\t��\t�ő咷\t����ް��^\tؽč��ڒl"
			@rg_list.each {|key, value|
				rg_name = key
				rg_type = value['ں��ޥ��ٰ�ߥ����']
				if value['��d�l'] then
					value['��d�l'].each {|key, value|
						list_val = nil
						if value['��lؽ�'] then
							list_val = Array.new
							value['��lؽ�'].each {|key, value|
								list_val << value['ؽč��ڒl']
							}
							if list_val.size == 0 then
								list_val = nil
							end
						end
						
						puts "#{rg_name}\t#{rg_type}\t#{key}\t#{value['�ő咷']}\t#{value['����ް��^']}\t#{list_val.join(",") if list_val}"
					}
	
				end
			}
		end
	
		#�₢���킹 �t�@�C���o��
		def output_query(out_dir)
			if out_dir then
				make_dir(out_dir)
				@rg_list.each {|key, value|
					rg_name = key
					if value['ں��ޥ��ٰ�ߖ⍇��'] then
						$stdout = File.open(out_dir + key + '.sql' , "w")
						puts value['ں��ޥ��ٰ�ߖ⍇��']
					end
				}
			end
		end
	
	end

end
