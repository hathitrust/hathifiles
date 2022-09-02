# Getting Started

```bash
git clone https://github.com/hathitrust/hathifiles
git submodule init
git submodule update
docker-compose build hf
docker-compose run --rm hf bundle install
docker-compose up -d
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
