#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path(Pathname.new("#{File.dirname(__FILE__)}/../lib"))

require "push_metrics"

require "hathifile_writer"
require "services"
require "settings"
require "zephir_files"

class GenerateHathifile
  attr_reader :tracker

  def initialize
    @tracker = PushMetrics.new(batch_size: 10_000, job_name: "generate_hathifiles",
      logger: Services["logger"])
  end

  def run
    Services[:logger].info "zephir_dir: #{Settings.zephir_dir}, hathifiles_dir: #{Settings.hathifiles_dir}"
    zephir_files = ZephirFiles.new(
      zephir_dir: Settings.zephir_dir,
      hathifiles_dir: Settings.hathifiles_dir
    )
    Services[:logger].info "Unprocessed Zephir files: #{zephir_files.unprocessed}"
    zephir_files.unprocessed.each do |zephir_file|
      run_file zephir_file
    end
    tracker.log_final_line
  end

  def run_file(zephir_file)
    infile = File.join(Settings.zephir_dir, zephir_file.filename)
    Services[:logger].info "Processing file: #{infile}"
    fin = if /\.gz$/.match?(infile)
      Zlib::GzipReader.open(infile)
    else
      File.open(infile)
    end
    writer = HathifileWriter.new(hathifile: zephir_file.hathifile)
    fin.each do |line|
      records = BibRecord.new(line).hathifile_records.to_a
      writer.add records
      tracker.increment_and_log_batch_line
    end
    writer.finish
    fin.close
  end
end

# Force logger to flush STDOUT on write so we can see what out Argo Workflows are doing.
$stdout.sync = true
GenerateHathifile.new.run if __FILE__ == $PROGRAM_NAME
