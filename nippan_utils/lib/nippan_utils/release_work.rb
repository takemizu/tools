# coding: Windows-31J
=begin
  2014/03/25  Ruby 2.0 対応で新規作成
=end
require "nippan_utils"
require "nippan_utils/version"

module NippanUtils

  class ReleaseWork
    DEFAULT_HOME_PATH = "C:/release_wk/"                            #コピー先Default Path

    attr_reader :path, :home_path

    def initialize(home_path: DEFAULT_HOME_PATH)
      @home_path = NippanUtils.cnv_unix_filename(home_path||DEFAULT_HOME_PATH)
      @home_path = @home_path + '/' if @home_path[-1] != '/'

      @path = Hash.new

      @path[:cmd] =  @home_path + "w1/"
      @path[:sql] =  @home_path + "w2/"
      @path[:etc] =  @home_path + "w3/"

      @path[:fmb] =  @path[:etc] + "fmb/"
      @path[:eex] =  @path[:etc] + "eex/"
      @path[:bmp] =  @path[:etc] + "bmp/"
      @path[:frm] =  @path[:etc] + "frm/"
      @path[:vrq] =  @path[:etc] + "vrq/"
      @path[:wft] =  @path[:etc] + "wft/"

      @path[:ddl] =  @path[:cmd] + "ddl/"
      @path[:ddl_table] =  @path[:ddl] + "table/"
      @path[:ddl_view] =  @path[:ddl] + "view/"
      @path[:ddl_seq] =  @path[:ddl] + "seq/"
      @path[:ddl_index] =  @path[:ddl] + "index/"
    end

    def create_all_dirs
      NippanUtils.create_dir(@home_path)

      NippanUtils.create_dir(@path[:cmd])
      NippanUtils.create_dir(@path[:sql])
      NippanUtils.create_dir(@path[:etc])

      NippanUtils.create_dir(@path[:ddl])
      NippanUtils.create_dir(@path[:ddl_table])
      NippanUtils.create_dir(@path[:ddl_view])
      NippanUtils.create_dir(@path[:ddl_seq])
      NippanUtils.create_dir(@path[:ddl_index])
    end

    #拡張子によってコピー先を振り分け
    def dir_by_extension(filename)
        to_path = ''
        case File.extname(filename).downcase
        when '.sql' then
          to_path = @path[:sql]
        when '.fmb' then
          to_path = @path[:fmb]
        when '.eex' then
          to_path = @path[:eex]
        when '.bmp' then
          to_path = @path[:bmp]
        when '.frm' then
          to_path = @path[:frm]
        when '.vrq' then
          to_path = @path[:vrq]
        when '.wft' then
          to_path = @path[:wft]
        end
        return to_path
    end

    def copy_files_from_post(post)
      post.source_files.each do |source_file|
        to_path = dir_by_extension(source_file)

        NippanUtils.copy_file(source_file, to_path) if to_path != ''

        stat = File.stat(source_file)         
        puts "#{to_path.ljust(24)} <- #{File.basename(source_file)}" + " "*([54-File.basename(source_file).bytesize,0].max) + "\t#{stat.mtime}\t#{stat.size.to_s.rjust(10)}"
      end
    end

    def filelist_by_subsys(type_code)      
      hash = Hash.new
      Dir.glob(@path[type_code] + "*.*").each do |file|
        wk_subsys = File.basename(file, ".*")[0,4]
        if hash.key?(wk_subsys) then
          hash[wk_subsys] << file
        else
          hash.store(wk_subsys, [file])
        end
      end
      hash
    end

    def file_array(type_code)
      ary = Array.new
      Dir.glob(@path[type_code] + "*.*").each do |file|
        ary << file
      end
      ary.sort!
      ary
    end

  end

  class PostDir
    DEFAULT_POST_PATH = "//tera03/share/ライブラリ/Library/Post/"  #コピー元Default Path

    attr_reader :home_path

    def initialize(post_path: DEFAULT_POST_PATH)

      @home_path = NippanUtils.cnv_unix_filename(post_path||DEFAULT_POST_PATH)
      @home_path = @home_path + '/' if @home_path[-1] != '/'
    end

    def source_files
      @files = Dir.glob(@home_path+"**/*.*") #POST以下の全てファイル名を取得
      @files.sort!{|a, b| File.extname(a) <=> File.extname(b)}  #拡張子順にSORT
    end
  end
end
