[![Tests](https://github.com/hathitrust/hathifiles/actions/workflows/ci.yml/badge.svg)](https://github.com/hathitrust/hathifiles/actions/workflows/ci.yml)
[![Coverage Status](https://coveralls.io/repos/github/hathitrust/hathifiles/badge.svg?branch=main)](https://coveralls.io/github/hathitrust/hathifiles?branch=main)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-standard-brightgreen.svg)](https://github.com/testdouble/standard)

# Getting Started

## Developer Setup

```bash
git clone https://github.com/hathitrust/hathifiles
git submodule init
git submodule update
bin/setup_test.sh
```

## Running Tests

```bash
docker compose run --rm hf bundle exec standardrb
docker compose run --rm hf bundle exec rspec
```

# Hathifiles Generation
`bundle exec ruby jobs/generate_hathifile.rb (upd|full)`

Generates a metadata extract for public use, from the zephir `_upd_` and `_full_` files.

# Hathifiles Listing
`bundle exec ruby jobs/update_hathifile_listing.rb`

Moves Hathifiles to the appropriate directory and generates the [listing on the website](https://www.hathitrust.org/hathifiles).

## Field Definitions
End user documentation is available on the [Hathitrust website](https://www.hathitrust.org/hathifiles_description).
The following is a more precise definition of the MARC extractions.

|  Column #  | Data element |  Field name in [header file] (https://www.hathitrust.org/filebrowser/download/269539) | Description    |
| --- | --- | --- | --- |
| 1 | Volume Identifier | htid | The "permanent" HathiTrust item identifier. Taken from the 974$u |
| 2 | Access | access | "allow" or "deny" indicating very generally whether or not users can view the item. N.B. it is United States biased. It is "allow" if 974$r is "pd" or "pdus", or if it starts with "world", "ic-world", "cc", or "und-world". All other values in 974$r get "deny". |
| 3 | Rights code | rights | 974$r |
| 4 | HathiTrust record number | ht_bib_key | HathiTrust's bib record number. Taken from the 001 field, without processing. |
| 5 | Enumeration/Chronology | description | 974$z or empty string |
| 6 | Source | source | In theory, it is the "code identifying the source of the bibliographic record." In practice, it is taken from the 974$b so may be unrelated to the bib record found in the catalog. |
| 7 | Source institution record number | source_bib_num | Local bib record number taken from the 035 sdr nums using the 974$c (collection) and a [prefix mapping] (https://github.com/cdlib/hathitrust-contrib-configs) |
| 8 | OCLC numbers | oclc_num | Extracted from the 035s with the regex: /(\(oco{0,1}lc\)|ocm|ocn)(\d+)/i Joined with "," if multiple. |
| 9 | ISBNs | isbn | 020a, stripped of whitespace, uniqd, and joined with "," |
| 10 | ISSNs | issn | 022a, stripped of whitespace, uniqd, and joined with "," |
| 11 | LCCNs | lccn | 010a, stripped of whitespace, uniqd, and joined with "," |
| 12 | Title | title | 245abcnp, stripped of whitespace, joined with "," |
| 13 | Publishing information | imprint | 260bc, stripped of whitespace, joined with ", ". If no 260bc is found, then we look for 264|\*1|bc |
| 14 | Rights determination reason code | rights_reason_code | 974$q or "" |
| 15 | Date of last update | rights_timestamp | `time` field taken from the `rights_current` table of the rights database. Formatted as %Y-%m-%d %H:%M:%S |
| 16 | Government Document | us_gov_doc_flag | 1 if a US federal goverment document. 0 otherwise. Uses the third character of the [pub place code](https://github.com/hathitrust/hathifiles/blob/main/lib/place_of_publication.rb) and if character 28 in the 008 is "f". It incorporates [multiple exceptions] (https://github.com/hathitrust/hathifiles/blob/main/lib/us_fed_doc.rb#L7) that mean this is better considered a "Government Document that is also public domain". |
| 17 | Publication Date | rights_date_used | 974$y or, if empty, "9999" |
| 18 | Publication Place | pub_place | Three digit code for the place of publication taken from the 008 with some [minor tweaks](https://github.com/hathitrust/hathifiles/blob/main/lib/place_of_publication.rb) |
| 19 | Language | lang | 008\[35-37\] or "   " |
| 20 | Bibliographic Format | bib_fmt | An extraction from the Leader, [this](https://github.com/hathitrust/hathifiles/blob/main/lib/bib_record.rb#L71) is a reimplementation of https://github.com/mlibrary/traject_umich_format/blob/7d355a5be133dc86f8795954fdd2e01355758309/lib/traject/umich_format/bib_format.rb#L18 |
| 21 | Collection Code | collection_code | 974$c |
| 22 | Content Provider Code | content_provider_code | The `content_provider_cluster` field taken from the `ht_collections` table using the collection_code |
| 23 | Responsible Entity Code | responsible_entity_code | The institution that took responsiblity for accessioning the content into HathiTrust. The `responsible_entity` field taken from the `ht_collections` table using the collection_code |
| 24 | Digitization Source | digitization_agent_code | The organization that digitized the content. 974$s |
| 25 | Access profile | access_profile_code | Indicates whether an item has view or download restrictions. The `access_profile` field from the `rights_current` table for this htid. |
| 26 | Author | author | 100$abcd, 110$abcd, **and** 111$acd stripped and uniqd, joined by ", " |

## Catalog Redirect: Generate hathifile history and compute record redirects

We want to generate redirects for catalog records that have been completely
replaced by.

## Basic usage: add_monthly_and_dump_redirects.rb

```shell
bundle exec ruby bin/add_monthly_and_dump_redirects.rb \
../archive/hathi_full_20211101.txt.gz
```

In general, the only script we really need is
`add_monthly_and_dump_redirects.rb`. It does the following:

* Find the most recent full hathfiles dump in `/.../archive/hathi_full_YYYYMMDD.txt.gz`
* Figure out current/previous month (and thus filenames) from the found filename
* Load up the data from `history_file/#{yyyymm_prev}.ndj.gz`
* Add the data from the passed file
* Dump the updated data to `history_file/#{yyyymm_current}.ndj.gz`
* Compute the redirects (all of them, not just new ones) and dump them
  to `redirects/redirects_#{yyyymm_current}.txt` as two-column,
  tab-delimited lines of the form `old_dead_record    current_record`

`add_monthly_and_dump_redirects.rb` can optionally take all those things as arguments;
run with `-h` to see them.


## Other scripts

`bin/dump_redirects_from_history_file history_files/202111.ndj.gz
my_redir_file.txt.gz` dumps the redirects from an existing file.

`bin/initial_load.rb` is the script that was used to load all the
monthlies to get everything up to date. It will only be useful if
we need to rebuild everything.

## Performance

Running under ruby 3.x it takes about 30-40mn.

## Idempotence-ish

Because each history file is kept, it's easy to roll back to
a given point and start from there. There's no database so no
need to roll back any data or anything complex like that.

## Using the underlying `HathifileHistory` code

```ruby

$LOAD_PATH.unshift 'lib'
require 'hathifile_history'

hh = HathifileHistory.new_from_ndj('history_files/202110.ndj.gz')
hh.add_monthly("hathi_full_20211101.txt")
hh.dump_to_ndj('history_files/202111.ndj.gz')

# Eliminate any ids that are no longer used
hh.remove_missing_htids!

# ...or just get a list of them without deleting
# missing_ids = recs.missing_htids

# Compute and dump valid record redirect pairs

File.open('redirects/redirect_202111.txt', 'w:utf-8') do |out|
  hh.redirects.each_pair do |source, sink|
    out.puts "#{source}\t#{sink}"
  end
end

```



## Generated files

**redirects_YYYYMM.txt** are tab-delimited files, two columns, each a
zero-padded record id, `old_dead_record    current_record`

**YYYYMM.ndj.txt** are json dumps of the ginormous data structure that
holds all the history data (along with some extra fields to allow easy
re-creation of the actual ruby classes upon load).

## Data explanation and memory use

This whole project is just is simple(-ish) code to build up a history of

* which HTIDs were added to which record IDs
* and when was it added
* and when was it last seen on this record in a hathifile
* and when was the record last seen in a hathifile

When a file is loaded, it computes the year/month (YYYYMM) from the filename
and notes which HTIDs are on which records, and which ids are seen at all. We
end up with a big hash keyed on record id that contain data similar to
this structure:

```ruby
{
  rec_id: "000001046",
  most_recently_seen: 202111, # record appeared in Nov 2021 hathifile
    entries: {
    "mdp.39015070574192" => {
      appeared: 200808,
      last_seen_here: 202111 # was seen on this record Nov 2021
    }
  }
}
```

Because the queries we want to do can be pretty expensive in SQL-land,
and because we have gobs of memory, the whole thing is
stored in memory for processing, and later dumped to newline-delimited JSON
(`.ndj.gz`) files for loading up again the next month.


## How redirects are computed

We reduce the computation of redirects to say that `record-A` should
redirect to `record-B` iff every record that has ever been on `record-A`
is currently on `record-B`.

Things we do _not_ redirect:
  * records whose component HTIDs have ended up on more than one record
  * records that current exist cannot be a source
  * records that no longer exist cannot be a target

To find the redirects:

* Eliminate HTIDs that don't exist anymore. Otherwise,
  `htid -> new_rec -> htid-dies` could make it seem like htids got
  split over multiple records.
* Build a hash of `htid -> current_record` by buzzing through all the
  htids and checking `most_recent_appearance`
* For each record that was not seen in the most recent load (so, deleted
  records):
  *


* Get a list of all the HTIDs that have ever moved
* For each moved HTID
  * Figure out where it currently lives (`record_current`)
  * For every _other_ record it's ever lived on `record_past`, see if
    `record_current.htids.superset?(record_past.htids)`
  * If so, set up a redirect from `record_past` to `record_current`
