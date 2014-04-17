# coding: Windows-31J
require "nippan_utils"

include NippanUtils

if ARGV[0] then
	p_dir = ARGV[0]
else
	p_dir = nil
end

post_dir = PostDir.new(post_path: p_dir)

puts ""
puts "コピー元:#{post_dir.home_path}"
puts ""

if ARGV[1] then
	w_dir = ARGV[1]
else
	w_dir = nil
end

release_work = ReleaseWork.new(home_path: w_dir)


release_work.create_all_dirs

release_work.copy_files_from_post(post_dir)

puts "End Copy_from_post."
