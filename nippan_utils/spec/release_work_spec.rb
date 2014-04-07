# coding: Windows-31J
require 'spec_helper'

describe NippanUtils::PostDir do
  context 'initialize' do

    context 'home_path' do
      it 'post_path��Default�l���������ݒ肳���' do
        expect(NippanUtils::PostDir.new().home_path).to eq  "//tera03/share/���C�u����/Library/Post/"
        expect(NippanUtils::PostDir.new(post_path: nil).home_path).to eq "//tera03/share/���C�u����/Library/Post/"
      end

      it 'post_path�̎w��l���������ݒ肳���' do
        expect(NippanUtils::PostDir.new(post_path: 'c:/post/').home_path).to eq 'c:/post/'
      end

      it 'post_path�̎w��l���������ݒ肳���(����������ؕ����ȊO)' do
        expect(NippanUtils::PostDir.new(post_path: 'c:/post').home_path).to eq 'c:/post/'
      end

      it 'post_path�̎w��l���������ݒ肳���(DOS�`��)' do
        expect(NippanUtils::PostDir.new(post_path: 'c:\\post\\test1').home_path).to eq 'c:/post/test1/'
      end
    end

  end

  context 'source_files' do
    #�e�X�g���s�O����
    before :all do
      @post_path = 'C:\\temp\\test_release_work\\post\\'

      @post_dir = NippanUtils::PostDir.new(post_path: @post_path)

      @fmb_file1 = @post_path+'EBS\\XXOM\\forms\\fmb\\xxomtt01.fmb'
      create_dummy_file(@fmb_file1)
      @fmb_file2 = @post_path+'EBS\\XXOM\\forms\\fmb\\xxomtt02.fmb'
      create_dummy_file(@fmb_file2)
      @fmb_file3 = @post_path+'EBS\\XXPO\\forms\\fmb\\xxpott02.fmb'
      create_dummy_file(@fmb_file3)

      @sql_file1 = @post_path+'EBS\\XXPO\\plsql\\xxpopx01.sql'
      create_dummy_file(@sql_file1)
      @sql_file2 = @post_path+'EBS\\XXIV\\plsql\\xxivpx01.sql'
      create_dummy_file(@sql_file2)
    end

    #�e�X�g���s�㏈��
    after :all do
      FileUtils.rm_r(@post_path, :force=>true)
    end

    it '�Ώۃt�@�C�������������o�����' do
      files = @post_dir.source_files

      #�R�s�[���ƃR�s�[��̃t�@�C�������������Ƃ��m�F
      expect(files.size).to eq 5
      expect(files).to include(NippanUtils::cnv_unix_filename(@fmb_file1))
      expect(files).to include(NippanUtils::cnv_unix_filename(@fmb_file2))
      expect(files).to include(NippanUtils::cnv_unix_filename(@fmb_file3))
      expect(files).to include(NippanUtils::cnv_unix_filename(@sql_file1))
      expect(files).to include(NippanUtils::cnv_unix_filename(@sql_file2))
    end
  end
end

describe NippanUtils::ReleaseWork do
  context 'initialize' do

    context 'home_path' do
      it 'home_path��Default�l���������ݒ肳���' do
        expect(NippanUtils::ReleaseWork.new().home_path).to eq "C:/release_wk/"
        expect(NippanUtils::ReleaseWork.new(home_path: nil).home_path).to eq "C:/release_wk/"
      end

      it 'home_path�̎w��l���������ݒ肳���' do
        expect(NippanUtils::ReleaseWork.new(home_path: 'c:/release_wk_test1/').home_path).to eq 'c:/release_wk_test1/'
      end

      it 'home_path�̎w��l���������ݒ肳���(����������ؕ����ȊO)' do
        expect(NippanUtils::ReleaseWork.new(home_path: 'c:/release_wk_test2').home_path).to eq 'c:/release_wk_test2/'
      end

      it 'home_path�̎w��l���������ݒ肳���(DOS�`��)' do
        expect(NippanUtils::ReleaseWork.new(home_path: 'c:\\release_wk_test3\\').home_path).to eq 'c:/release_wk_test3/'
      end
    end

  end

  context 'create_all_dirs' do
    #�e�X�g���s�O����
    before :each do
      @wk_path = 'c:/release_wk_test/'
      FileUtils.rm_r(@wk_path, :force=>true)
      @release_work = NippanUtils::ReleaseWork.new(home_path: @wk_path)
    end

    #�e�X�g���s�㏈��
    after :each do
      FileUtils.rm_r(@wk_path, :force=>true)
    end

    it '�edir���������쐬�����' do
      @release_work.create_all_dirs

      expect(File.exist?(@release_work.home_path)).to be_true
      expect(File.exist?(@release_work.path[:sql]+'xxx')).to be_false
      expect(File.exist?(@release_work.path[:sql])).to be_true
      expect(File.exist?(@release_work.path[:cmd])).to be_true
      expect(File.exist?(@release_work.path[:etc])).to be_true
      expect(File.exist?(@release_work.path[:ddl])).to be_true
      expect(File.exist?(@release_work.path[:ddl_table])).to be_true
      expect(File.exist?(@release_work.path[:ddl_view])).to be_true
      expect(File.exist?(@release_work.path[:ddl_seq])).to be_true
      expect(File.exist?(@release_work.path[:ddl_index])).to be_true
    end
  end

  context 'dir_by_extension' do
    #�e�X�g���s�O����(�ŏ��̂P�񂾂����s�����)
    before :all do
      @wk_path = 'c:/release_wk_test/'
      @release_work = NippanUtils::ReleaseWork.new(home_path: @wk_path)
    end

    it '�������R�s�[����g���q�ŐU�蕪���邱�Ƃ��ł���(fmb)' do
      expect(@release_work.dir_by_extension('aaa.fmb')).to eq @release_work.path[:fmb]
    end

    it '�������R�s�[����g���q�ŐU�蕪���邱�Ƃ��ł���(sql)' do
      expect(@release_work.dir_by_extension('aaa.sql')).to eq @release_work.path[:sql]
    end

    it '�������R�s�[����g���q�ŐU�蕪���邱�Ƃ��ł���(eex)' do
      expect(@release_work.dir_by_extension('aaa.eex')).to eq @release_work.path[:eex]
    end

    it '�������R�s�[����g���q�ŐU�蕪���邱�Ƃ��ł���(wft)' do
      expect(@release_work.dir_by_extension('aaa.wft')).to eq @release_work.path[:wft]
    end

    it '�������R�s�[����g���q�ŐU�蕪���邱�Ƃ��ł���(vrq)' do
      expect(@release_work.dir_by_extension('aaa.vrq')).to eq @release_work.path[:vrq]
    end

    it '�������R�s�[����g���q�ŐU�蕪���邱�Ƃ��ł���(frm)' do
      expect(@release_work.dir_by_extension('aaa.frm')).to eq @release_work.path[:frm]
    end

    it '�������R�s�[����g���q�ŐU�蕪���邱�Ƃ��ł���(bmp)' do
      expect(@release_work.dir_by_extension('aaa.bmp')).to eq @release_work.path[:bmp]
    end

    it '�������R�s�[����g���q�ŐU�蕪���邱�Ƃ��ł���(�ΏۊO)' do
      expect(@release_work.dir_by_extension('aaa.xxx')).to eq ''
    end
  end

  context 'copy_files_from_post' do
    #�e�X�g���s�O����
    before :each do
      @wk_path = 'c:/release_wk_test/'
      @post_path = 'C:\\temp\\test_release_work\\post\\'

      @release_work = NippanUtils::ReleaseWork.new(home_path: @wk_path)
      @post_dir = NippanUtils::PostDir.new(post_path: @post_path)


      @release_work.create_all_dirs

      @fmb_file1 = @post_path+'EBS\\XXOM\\forms\\fmb\\xxomtt01.fmb'
      create_dummy_file(@fmb_file1)
      @fmb_file2 = @post_path+'EBS\\XXOM\\forms\\fmb\\xxomtt02.fmb'
      create_dummy_file(@fmb_file2)
      @fmb_file3 = @post_path+'EBS\\XXPO\\forms\\fmb\\xxpott02.fmb'
      create_dummy_file(@fmb_file3)

      @sql_file1 = @post_path+'EBS\\XXPO\\plsql\\xxpopx01.sql'
      create_dummy_file(@sql_file1)
      @sql_file2 = @post_path+'EBS\\XXIV\\plsql\\xxivpx01.sql'
      create_dummy_file(@sql_file2)
    end

    #�e�X�g���s�㏈��
    after :each do
      FileUtils.rm_r(@wk_path, :force=>true)
      FileUtils.rm_r(@post_path, :force=>true)
    end

    it '�e�t�@�C�����������R�s�[�����' do
      capture(:stdout) {
       @release_work.copy_files_from_post(@post_dir) 
      }

      #�R�s�[���ƃR�s�[��̃t�@�C�������������Ƃ��m�F
      expect(FileUtils.cmp(@fmb_file1, @release_work.path[:fmb]+File.basename(@fmb_file1))).to be_true
      expect(FileUtils.cmp(@fmb_file2, @release_work.path[:fmb]+File.basename(@fmb_file2))).to be_true
      expect(FileUtils.cmp(@fmb_file3, @release_work.path[:fmb]+File.basename(@fmb_file3))).to be_true

      expect(FileUtils.cmp(@sql_file1, @release_work.path[:sql]+File.basename(@sql_file1))).to be_true
      expect(FileUtils.cmp(@sql_file2, @release_work.path[:sql]+File.basename(@sql_file2))).to be_true
    end
  end
end
