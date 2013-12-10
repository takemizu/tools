# -*- coding: Windows-31J -*-

=begin
PL/SQL�v���O��������͂���

Version
0.01		2012/01/13

=end
require 'pp'

module OracleSQLProgram
=begin
		CLASS ProgramText
		�v���O������������
=end
	class ProgramText
		def initialize(pg_text)
			@pg_text = pg_text
			@para_list = Array.new
			@syst_list = Array.new
			@blok_list = Array.new
			@pack_list = Array.new
			@strg_list = Array.new
	
			@sql_list = Array.new
		end
	
		def list_use_packages
			@pack_list.uniq.sort
		end
	
		def list_use_parameters
			@para_list.uniq.sort
		end
	
		def list_use_items
			@blok_list.uniq.sort
		end
	
		def list_sql
			@sql_list
		end
	
		def make_list
			w_text = @pg_text
	    while w_text.size > 0 do
	      if w_text =~   /([^|^\s^\(^\)^,^\.]+?)\.([^|^\s^\(^\)^;^\'^,^\.]+)/m then
	        w_text = $'
        	package_name = $1.upcase
	      	first_char = package_name[0]
        	item_name = $2.upcase
	      	if package_name =~ /^=>/ then
	      		package_name = $'
	      	end
	        if first_char == "'" then
	          @strg_list << "#{package_name}.#{item_name}"
					elsif package_name == ":SYSTEM" then
	          @syst_list << "#{package_name}.#{item_name}"
	        elsif package_name == ":PARAMETER" then
	          @para_list <<  "#{package_name}.#{item_name}"
	        elsif package_name[0,1] == ":" then
	          @blok_list <<  "#{package_name}.#{item_name}"
	        else
	        	save_result_text = "#{package_name}.#{item_name}"
	        	if package_name =~ /_rec$/i then
	        	elsif package_name =~ /^rec_/i then
	        	elsif package_name =~ /^[0-9]+$/i then
	        	elsif item_name =~ /\%type$/i then
	        	else
		          @pack_list <<  save_result_text
		        end
		      end
	      else
	        w_text = ""
	      end
	    end
		end
		
		def make_sql_list
			w_text = @pg_text
	    while w_text.size > 0 do
	      if w_text =~ /\n\s*(^\s*?SELECT\s*.*?);/mi then
	      	@sql_list << $1
	        w_text = $'
	      elsif w_text =~ /\n*\s*(^\s*?INSERT\s*.*?);/mi then
	      	@sql_list << $1
	        w_text = $'
	      elsif w_text =~ /\n*\s*(^\s*?UPDATE\s*.*?);/mi then
	      	@sql_list << $1
	        w_text = $'
	      elsif w_text =~ /\n*\s*(^\s*?MERGE\s*.*?);/mi then
	      	@sql_list << $1
	        w_text = $'
	      elsif w_text =~ /\n*\s*(^\s*?DELETE\s*.*?);/mi then
	      	@sql_list << $1
	        w_text = $'
	      else
	        w_text = ""
	      end
	    end
		end
		
	end
	
	
=begin
		CLASS PgmUnit
		�v���O�����P�ʏ�������
=end
	class PgmUnit
	
		def initialize(name, text)
			@name = name											#�v���O�����P�ʖ�
			@text = text											#�v���O�����P�ʂ̃e�L�X�g
			@text_array = @text.split(/\n/)		#�v���O�����P�ʂ̃e�L�X�g�����s�ŋ�؂��Ĕz��ɂ�������
			@text_array_nocomment = Array.new	#�v���O�����P�ʂ̃e�L�X�g����R�����g����菜���z��ɂ������́i�������̂݁j
			@list_pgm = Hash.new							#�v���O�����P�ʂɊ܂܂��v���O�������i�������̂݁j
		end
	
		#�s��
		def line_count
			@text_array.size
		end
	
		#��s��
		def space_count
			delete_comment if @text_array_nocomment.size == 0
			
			cnt = 0
			@text_array_nocomment.count {|line|line =~ /^\s*$/}
			
		end
		
		#�R�����g�s��
		def comment_count
			cnt = 0
			delete_comment if @text_array_nocomment.size == 0
			
			@text_array.size - @text_array_nocomment.size
		end
		
		#�R�����g��������菜��
		def delete_comment
			comment_now = false
			@text_array.each do |line|
				
				if line =~ /^\s*$/ then		#��s�̏ꍇ
					if comment_now then
					else
						@text_array_nocomment << line
					end
					next
				end
	
				line = line.gsub(/\/\*.*?\*\//, " ")		# /* */ �ň͂܂ꂽ�������" "�ɒu��
				if line =~ /^\s*$/ then		#��s�ɂȂ�����
					next
				end
	
				if line =~ /\/\*/ then
					comment_now = true
					line = line.gsub(/\/\*/, "")		# /* �ȍ~�̕������""�ɒu��
					if line =~ /^\s*$/ then		#��s�ɂȂ�����
						next
					end
				end
	
				if line =~ /\*\// then
					comment_now = false
					line = line.gsub(/.*\*\//, "")		# */ �ȑO�̕������""�ɒu��
					if line =~ /^\s*$/ then		#��s�ɂȂ�����
						next
					end
				end
	
				if line =~ /--(.*)/ then
					line = $`			#�}�b�`�������O�̂�
					if line =~ /^\s*$/	#��s�ɂȂ�����
						next
					end
				end
		
				if comment_now then
				else
					@text_array_nocomment << line
				end
		
			end
		end
	
		#�R�����g��������菜�����e�L�X�g
		def nocomment_text
			delete_comment if @text_array_nocomment.size == 0
			@text_array_nocomment
		end
	
		#�v���O������񃊃X�g�̍쐬
		def create_list_pgm
			name = ""
			@list_pgm = Hash.new
			delete_comment if @text_array_nocomment.size == 0
			@text_array_nocomment.each do |line|
				if /^\s*(PROCEDURE|FUNCTION)\s*(\S*)/i =~ line then
					name = line.slice(/^\s*(PROCEDURE|FUNCTION)\s*(\S*)/i,2)
					if name =~ /\(/ then
						name = $`
					end
					@list_pgm.store(name, "")
				end
				if name != "" then
					@list_pgm[name] = @list_pgm[name] + line + "\n"
				end
			end
		end
	
		#�v���O������񃊃X�g
		def list_pgm
			create_list_pgm if @list_pgm.size == 0
			@list_pgm
		end	
		
		#����
		def count_bunki
			delete_comment if @text_array_nocomment.size == 0
	
			cnt_if = cnt_loop = cnt_etc = 0
			@text_array_nocomment.join("\n").split(nil).each {|w|		#�R�����g����菜�����e�L�X�g�����[�h�P�ʂŎ��o��
				case w.upcase
				when 'IF' then
					cnt_if += 1
				when 'LOOP' then
					cnt_loop += 1
				when 'ELSE' then
					cnt_etc += 1
				when 'ELSIF' then
					cnt_etc += 1
				end
			}
			cnt_if + cnt_loop  + cnt_etc
		end
	
		#�p�b�P�[�W�g�p
		def list_use_packages
			@list = Hash.new
			if list_pgm.size > 0 then
				list_pgm.each { |key,value|
					pt = ProgramText.new(value)
					pt.make_list
					@list[key] = pt.list_use_packages
				}
			else
				pt = ProgramText.new(nocomment_text.join("\n"))
				pt.make_list
				@list[@name] = pt.list_use_packages
			end
			@list
		end
	
		#�p�b�P�[�W�g�p
		def list_use_parameters
			@list = Hash.new
			if list_pgm.size > 0 then
				list_pgm.each { |key,value|
					pt = ProgramText.new(value)
					pt.make_list
					@list[key] = pt.list_use_parameters
				}
			else
				pt = ProgramText.new(nocomment_text.join("\n"))
				pt.make_list
				@list[@name] = pt.list_use_parameters
			end
			@list
		end
	
		#SQL�g�p
		def list_use_sql
			delete_comment if @text_array_nocomment.size == 0
	
			pt = ProgramText.new(@text_array_nocomment.join("\n"))
			pt.make_sql_list
			pt.list_sql
		end
	
	
	end
end
