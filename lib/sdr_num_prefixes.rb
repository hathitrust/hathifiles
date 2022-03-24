# frozen_string_literal: true

require "services"

class SdrNumPrefixes
  attr_reader :prefix_map

  def initialize
    # collection code => prefix
    @prefix_map = {
      "deu" => "udel",
      # 'ibc' => 'bc\.',
      "ibc" => '(?:bc\.|bc-loc\.)',
      "iduke" => 'duke\.',
      "iloc" => "loc",
      "incsu" => 'ncsu\.',
      "innc" => "nnc",
      "inrlf" => "nrlf",
      "ipst" => 'pst\.',
      "isrlf" => "srlf",
      "iucla" => "ucla",
      "iucd" => "ucd",
      "iufl" => "(?:ufl|ufdc)",
      "iuiuc" => "uiuc",
      "iunc" => 'unc\.',
      "mdl" => 'mdl\.',
      "mwica" => "mwica",
      "mmet" => "tu",
      "mu" => "uma",
      "nrlf" => "(?:nrlf-ucsc|nrlf-ucsf|nrlf)",
      "pst" => 'pst\.',
      "qmm" => "qmm",
      "txcm" => "tam",
      # 'ucm' => 'ucm\.',
      "ucm" => '(?:ucm\.|ucm-loc\.)',
      # 'uiucl' => 'uiuc-loc',
      "uiucl" => "uiuc",
      "usu" => 'usu\.',
      "uva" => 'uva\.',
      "gri" => "cmalg",
      "umlaw" => "miu",
      "umdb" => "miu",
      "umbus" => "miu",
      "umdcmp" => "miu",
      "umprivate" => "miu",
      "gwla" => "miu",
      "iau" => "uiowa",
      "ctu" => "ucw",
      "ucbk" => "(?:ucbk|ucb|ucb-2|cul)",
      "geu" => "emu",
      "nbb" => "miu",
      "aubru" => "uql-1"
    }
    load_additional_mappings_from_collections_table
  end

  def [](collection_code)
    @prefix_map[collection_code]
  end

  def each
    return enum_for(:each) unless block_given?

    @prefix_map.each { |collection_code, prefix| yield [collection_code, prefix] }
  end

  private

  def load_additional_mappings_from_collections_table
    Services.collections.each do |collection_code, coll|
      unless @prefix_map.has_key? collection_code.downcase
        @prefix_map[collection_code.downcase] = collection_code.downcase
      end
    end
  end
end
