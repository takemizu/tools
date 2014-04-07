# coding: Windows-31J
require 'spec_helper'

describe NippanUtils do

  it 'should have a version number' do
    NippanUtils::VERSION.should_not be_nil
  end

  context 'create_dir' do

		#�e�X�g���s�O����
		before :each do
			@wk_path = 'C:\\temp\\test_NippanUtils\\'
			FileUtils.mkdir_p(@wk_path) if not File.exist?(@wk_path)
		end

		#�e�X�g���s�㏈��
		after :each do
			FileUtils.rm_r(@wk_path, :force=>true)
		end

  	it '���݂��Ȃ�Dir���쐬�ł���' do
  		new_path = @wk_path+'testdir1'
  		FileUtils.rm_r(new_path, :force=>true)

  		NippanUtils.create_dir(new_path)
  		expect(File.exist?(new_path)).to be_true
  	end

  	it '���݂��Ȃ�Dir���쐬�ł���(�����K�w)' do
  		new_path = @wk_path+'a\\b\\c\\testdir2'
  		FileUtils.rm_r(new_path, :force=>true)

  		NippanUtils.create_dir(new_path)
  		expect(File.exist?(new_path)).to be_true
  	end

  	it '���łɑ��݂���ꍇ�ł��G���[�ɂȂ�Ȃ�' do
  		new_path = @wk_path+'testdir2'
  		NippanUtils.create_dir(new_path)
  		
  		expect(NippanUtils.create_dir(new_path)).to be_nil
  	end
  end

  context 'copy_file' do

		#�e�X�g���s�O����
		before :each do
			@wk_path = 'C:\\temp\\test_NippanUtils\\'
			FileUtils.mkdir_p(@wk_path) if not File.exist?(@wk_path)
		end

		#�e�X�g���s�㏈��
		after :each do
			FileUtils.rm_r(@wk_path, :force=>true)
		end

	  it '�p�������t�@�C���̃R�s�[���s����' do
	  	src_path = @wk_path+'src\\';
  		NippanUtils.create_dir(src_path)
	  	filename = 'test1.txt';
	  	create_dummy_file(src_path+filename)

	  	des_path = @wk_path+'des\\'
  		NippanUtils.create_dir(des_path)

	  	NippanUtils.copy_file(src_path+filename, des_path)
	  	expect(FileUtils.cmp(src_path+filename, des_path+filename)).to be_true
	  end

	  it '�������t�@�C���̃R�s�[���s����' do
	  	src_path = @wk_path+'src\\';
  		NippanUtils.create_dir(src_path)
	  	filename = '�e�X�g���̂P.txt';
	  	create_dummy_file(src_path+filename)

	  	des_path = @wk_path+'des\\'
  		NippanUtils.create_dir(des_path)

	  	NippanUtils.copy_file(src_path+filename, des_path)
	  	expect(FileUtils.cmp(src_path+filename, des_path+filename)).to be_true
	  end

	  it '���݂��Ȃ�PATH�ւ��R�s�[���s����' do
	  	src_path = @wk_path+'src\\';
  		NippanUtils.create_dir(src_path)
	  	filename = 'test2.txt';
	  	create_dummy_file(src_path+filename)

	  	des_path = @wk_path+'desX\\'
  		FileUtils.rm_r(des_path, :force=>true)

	  	NippanUtils.copy_file(src_path+filename, des_path)
	  	expect(FileUtils.cmp(src_path+filename, des_path+filename)).to be_true
	  end

	end
end
