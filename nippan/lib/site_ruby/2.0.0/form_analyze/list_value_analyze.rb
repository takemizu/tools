# -*- coding: Windows-31J -*-

=begin
�l���X�g�𕪐͂��A�o�͂���

����: �I�u�W�F�N�g�E���X�g�E���|�[�g�t�@�C���̒l���X�g���

Version
0.01		2012/01/13		����

=end

module OracleObjectReport

=begin
		CLASS ListValueAnalyze
		�l���X�g����
=end
	class ListValueAnalyze
		
		def initialize(pgm_text)
			@lv_list = Hash.new
			@pgm_text = pgm_text
		end
	
	
		## ���͎��s
		def analyze
			w_text = @pgm_text
	    while w_text.size > 0 do
				if w_text =~ /^   \* ���O\s*(.*?)\n/i then
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
	
			if w_text =~ /^   [-\*\^] ں��ޥ��ٰ��\s*(.*?)\n/i then
				@lv_list[lv_name]['ں��ޥ��ٰ��'] = $1
		    w_text = $'
	    else
				@lv_list[lv_name]['ں��ޥ��ٰ��'] = ''
	    end
	
	    if w_text =~ /^   [-\*\^] ��ϯ��ݸޥ�����è\s*\n/ then
				if $' =~ /^   [-\*\^] �\���Ǫ��/ then
					if $` then
						analyze_columns(lv_name, $`)
					end
				end
	    end
	
		end
	
		def analyze_columns(lv_name, col_text)
			@lv_list[lv_name]['��ϯ��ݸޥ�����è'] = Hash.new
			w_text = col_text
	    while w_text.size > 0 do
				if w_text =~ /^     \* ���O\s*(.*?)\n/i then
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
			@lv_list[lv_name]['��ϯ��ݸޥ�����è'][col_name] = Hash.new
	
			w_text = col_text
	
			if w_text =~ /^     [-o\*\^] ���� *(.*?)\n/i then
				@lv_list[lv_name]['��ϯ��ݸޥ�����è'][col_name]['����'] = $1
		    w_text = $'
	    else
				@lv_list[lv_name]['��ϯ��ݸޥ�����è'][col_name]['����'] = ''
	    end
	
			if w_text =~ /^     [-o\*\^] �߂荀�� *(.*?)\n/i then
				@lv_list[lv_name]['��ϯ��ݸޥ�����è'][col_name]['�߂荀��'] = $1
		    w_text = $'
	    else
				@lv_list[lv_name]['��ϯ��ݸޥ�����è'][col_name]['�߂荀��'] = ''
	    end
	
			if w_text =~ /^     [-o\*\^] �ި���ڲ�� *(.*?)\n/i then
				@lv_list[lv_name]['��ϯ��ݸޥ�����è'][col_name]['�ި���ڲ��'] = $1
		    w_text = $'
	    else
				@lv_list[lv_name]['��ϯ��ݸޥ�����è'][col_name]['�ި���ڲ��'] = ''
	    end
		end
		
		def count_list
			@lv_list.size
		end
	
		## ���͌���(�l���X�g���)���o��
		def print_info
			puts "�l���X�g\tں��ޥ��ٰ��"
			@lv_list.each {|key, value|
				puts "#{key}\t#{value['ں��ޥ��ٰ��']}"
			}
		end
	
		def print_col_info
			puts "�l���X�g\t��\t����\t�߂荀��\t�ި���ڲ��"
			@lv_list.each {|key, value|
				lv_name = key
				value['��ϯ��ݸޥ�����è'].each {|key,value|
					puts "#{lv_name}\t#{key}\t#{value['����']}\t#{value['�߂荀��']}\t#{value['�ި���ڲ��']}"
				}
			}
		end
	
	end

end
