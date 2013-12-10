# -*- coding: Windows-31J -*-

=begin
���R�[�h�O���[�v�𕪐͂��A�o�͂���

����: �I�u�W�F�N�g�E���X�g�E���|�[�g�t�@�C���̃��R�[�h�O���[�v���

Version
0.01		2012/01/19		����

=end

require "oracle_program_unit"

module OracleObjectReport

=begin
		CLASS ParameterAnalyze
		̫�ѥ���Ұ�����
=end
	class ParameterAnalyze

		include Nippan::Common
		
		def initialize(pgm_text)
			@para_list = Hash.new
			@pgm_text = pgm_text
		end
	
	
		## ���͎��s
		def analyze
			w_text = @pgm_text
	    while w_text.size > 0 do
				if w_text =~ /^   \* ���O *(.*?)\n/i then
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
	
			if w_text =~ /^   [-\*\^] ���� *(.*?)\n/i then
				@para_list[para_name]['����'] = $1
		    w_text = $'
	    else
				@para_list[para_name]['����'] = ''
	    end
	
			if w_text =~ /^   [-\*\^] ���Ұ����ް��^ *(.*?)\n/i then
				@para_list[para_name]['���Ұ����ް��^'] = $1
		    w_text = $'
	    else
				@para_list[para_name]['���Ұ����ް��^'] = ''
	    end
	
			if w_text =~ /^   [-\*\^] �ő咷 *(.*?)\n/i then
				@para_list[para_name]['�ő咷'] = $1
		    w_text = $'
	    else
				@para_list[para_name]['�ő咷'] = ''
	    end
	
			if w_text =~ /^   [-\*\^] ���Ұ��̏����l *(.*?)\n/i then
				@para_list[para_name]['���Ұ��̏����l'] = $1
		    w_text = $'
	    else
				@para_list[para_name]['���Ұ��̏����l'] = ''
	    end
		end
	
	
		## ���͌���(���R�[�h�O���[�v���)���o��
		def print_info
			puts "���Ұ���\t����\t�ް��^\t�ő咷\t�����l"
			@para_list.each {|key, value|
				para_name = key
				puts "#{para_name}\t#{value['����']}\t#{value['���Ұ����ް��^']}\t#{value['�ő咷']}\t#{value['���Ұ��̏����l']}"
			}
		end
	
	end #class ParameterAnalyze

end #module
