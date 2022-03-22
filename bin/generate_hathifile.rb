#!/usr/bin/env ruby
# frozen_string_literal: true

require "bib_record"

def run(infile, outfile)
  fout = File.open(outfile, "w")
  
  if infile =~ /\.gz$/
    fin = Zlib::GzipReader.open(infile)
  else
    fin = open(infile)
  end
  File.open(infile).each do |line|
    BibRecord.new(line).hathifile_records.each do |rec|
      outrec = [rec[:htid],
            rec[:access],
            rec[:rights],
            rec[:ht_bib_key],
            rec[:description],
            (rec[:source] || ''),
            (rec[:source_bib_num].join(',') || ''),
            rec[:oclc_num].join(','),
            rec[:isbn].join(','),
            rec[:issn].join(','),
            rec[:lccn].join(','),
            rec[:title].join(','),
            rec[:imprint].join(', '),
            (rec[:rights_reason_code] || ''),
            (rec[:rights_timestamp] || ''),
            rec[:us_gov_doc_flag],
            rec[:rights_date_used],
            rec[:pub_place],
            rec[:lang],
            rec[:bib_fmt],
            (rec[:collection_code] || ''), 
            (rec[:content_provider_code] || ''),
            (rec[:responsible_entity_code] || ''),
            (rec[:digitization_agent_code] || ''),
            (rec[:access_profile] || ''),
            (rec[:author].join(', ') || '')
        ]
      fout.puts outrec.join("\t")
    end 
  end
end

run(ARGV.shift, ARGV.shift) if __FILE__ == $PROGRAM_NAME
