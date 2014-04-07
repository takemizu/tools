# coding: Windows-31J
require 'spec_helper'

describe NippanUtils::PostDir do
  context 'initialize' do

    context 'home_path' do
      it 'post_pathのDefault値が正しく設定される' do
        expect(NippanUtils::PostDir.new().home_path).to eq  "//tera03/share/ライブラリ/Library/Post/"
        expect(NippanUtils::PostDir.new(post_path: nil).home_path).to eq "//tera03/share/ライブラリ/Library/Post/"
      end

      it 'post_pathの指定値が正しく設定される' do
        expect(NippanUtils::PostDir.new(post_path: 'c:/post/').home_path).to eq 'c:/post/'
      end

      it 'post_pathの指定値が正しく設定される(末文字が区切文字以外)' do
        expect(NippanUtils::PostDir.new(post_path: 'c:/post').home_path).to eq 'c:/post/'
      end

      it 'post_pathの指定値が正しく設定される(DOS形式)' do
        expect(NippanUtils::PostDir.new(post_path: 'c:\\post\\test1').home_path).to eq 'c:/post/test1/'
      end
    end

  end

  context 'source_files' do
    #テスト実行前処理
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

    #テスト実行後処理
    after :all do
      FileUtils.rm_r(@post_path, :force=>true)
    end

    it '対象ファイルが正しく抽出される' do
      files = @post_dir.source_files

      #コピー元とコピー先のファイルが等しいことを確認
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
      it 'home_pathのDefault値が正しく設定される' do
        expect(NippanUtils::ReleaseWork.new().home_path).to eq "C:/release_wk/"
        expect(NippanUtils::ReleaseWork.new(home_path: nil).home_path).to eq "C:/release_wk/"
      end

      it 'home_pathの指定値が正しく設定される' do
        expect(NippanUtils::ReleaseWork.new(home_path: 'c:/release_wk_test1/').home_path).to eq 'c:/release_wk_test1/'
      end

      it 'home_pathの指定値が正しく設定される(末文字が区切文字以外)' do
        expect(NippanUtils::ReleaseWork.new(home_path: 'c:/release_wk_test2').home_path).to eq 'c:/release_wk_test2/'
      end

      it 'home_pathの指定値が正しく設定される(DOS形式)' do
        expect(NippanUtils::ReleaseWork.new(home_path: 'c:\\release_wk_test3\\').home_path).to eq 'c:/release_wk_test3/'
      end
    end

  end

  context 'create_all_dirs' do
    #テスト実行前処理
    before :each do
      @wk_path = 'c:/release_wk_test/'
      FileUtils.rm_r(@wk_path, :force=>true)
      @release_work = NippanUtils::ReleaseWork.new(home_path: @wk_path)
    end

    #テスト実行後処理
    after :each do
      FileUtils.rm_r(@wk_path, :force=>true)
    end

    it '各dirが正しく作成される' do
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
    #テスト実行前処理(最初の１回だけ実行される)
    before :all do
      @wk_path = 'c:/release_wk_test/'
      @release_work = NippanUtils::ReleaseWork.new(home_path: @wk_path)
    end

    it '正しくコピー先を拡張子で振り分けることができる(fmb)' do
      expect(@release_work.dir_by_extension('aaa.fmb')).to eq @release_work.path[:fmb]
    end

    it '正しくコピー先を拡張子で振り分けることができる(sql)' do
      expect(@release_work.dir_by_extension('aaa.sql')).to eq @release_work.path[:sql]
    end

    it '正しくコピー先を拡張子で振り分けることができる(eex)' do
      expect(@release_work.dir_by_extension('aaa.eex')).to eq @release_work.path[:eex]
    end

    it '正しくコピー先を拡張子で振り分けることができる(wft)' do
      expect(@release_work.dir_by_extension('aaa.wft')).to eq @release_work.path[:wft]
    end

    it '正しくコピー先を拡張子で振り分けることができる(vrq)' do
      expect(@release_work.dir_by_extension('aaa.vrq')).to eq @release_work.path[:vrq]
    end

    it '正しくコピー先を拡張子で振り分けることができる(frm)' do
      expect(@release_work.dir_by_extension('aaa.frm')).to eq @release_work.path[:frm]
    end

    it '正しくコピー先を拡張子で振り分けることができる(bmp)' do
      expect(@release_work.dir_by_extension('aaa.bmp')).to eq @release_work.path[:bmp]
    end

    it '正しくコピー先を拡張子で振り分けることができる(対象外)' do
      expect(@release_work.dir_by_extension('aaa.xxx')).to eq ''
    end
  end

  context 'copy_files_from_post' do
    #テスト実行前処理
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

    #テスト実行後処理
    after :each do
      FileUtils.rm_r(@wk_path, :force=>true)
      FileUtils.rm_r(@post_path, :force=>true)
    end

    it '各ファイルが正しくコピーされる' do
      capture(:stdout) {
       @release_work.copy_files_from_post(@post_dir) 
      }

      #コピー元とコピー先のファイルが等しいことを確認
      expect(FileUtils.cmp(@fmb_file1, @release_work.path[:fmb]+File.basename(@fmb_file1))).to be_true
      expect(FileUtils.cmp(@fmb_file2, @release_work.path[:fmb]+File.basename(@fmb_file2))).to be_true
      expect(FileUtils.cmp(@fmb_file3, @release_work.path[:fmb]+File.basename(@fmb_file3))).to be_true

      expect(FileUtils.cmp(@sql_file1, @release_work.path[:sql]+File.basename(@sql_file1))).to be_true
      expect(FileUtils.cmp(@sql_file2, @release_work.path[:sql]+File.basename(@sql_file2))).to be_true
    end
  end
end
