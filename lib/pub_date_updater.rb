class PubDateUpdater
  def update(bib_record)
    date = bib_record.pub_date
    Services.db[:hf_pub_date]
      .replace(bib_num: bib_record.ht_bib_key, 
               pub_date: bib_record.pub_date)
  end
end
