require "pp"

# Assists with sanity checks.
# Diffs 2 hathifiles by column. Counts the number of differences per column.
# Outputs diffs in `col<num>.tmp`
# assume sorted
# assume same items so we really only care about the differences in the columns

fin1 = File.open(ARGV.shift)
fin2 = File.open(ARGV.shift)

column_count = Hash.new 0
col_diff_count = Hash.new 0
fin1.each do |line|
  rec1 = line.split("\t")
  column_count[rec1.count] += 1

  rec2 = fin2.readline.split("\t")
  while rec2[0] != rec1[0]
    rec2 = fin2.readline.split("\t")
  end
  rec1.each_with_index do |col, index|
    if rec2[index].chomp != col.chomp
      col_diff_count[index] += 1
      colfout = File.open("col#{index}.tmp", "a")
      colfout.puts [rec1[0], col.chomp, rec2[index].chomp].join("\t")
      colfout.close
    end
  end
end

PP.pp col_diff_count
puts "================="
puts column_count
