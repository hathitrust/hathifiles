# frozen_string_literal: true

require_relative "zephir_file"

class ZephirFiles
  attr_reader :zephir_dir, :hathifiles_dir

  def initialize(zephir_dir:, hathifiles_dir:)
    @zephir_dir = zephir_dir
    @hathifiles_dir = hathifiles_dir
  end

  def unprocessed
    all.reject do |zephir_file|
      File.exist? File.join(hathifiles_dir, zephir_file.hathifile)
    end
  end

  def all
    Dir.glob(File.join(zephir_dir, "zephir_{full,upd}*")).map do |zephir_file|
      ZephirFile.new(zephir_file)
    end
  end
end
