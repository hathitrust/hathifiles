#!/bin/bash

# Compare 2 hathifiles and report which items have changed rights
# from ic/bib in file1 to pd/bib in file2.
#
# Invoke thusly:
# $ bash rights_change.sh f1 f2
# Results end up in ic_to_pd_YYYYMMDD.txt.
# Each record in the output are presumed to have changed from ic
# to pd between the generation of the 2 files.
# Script starts at the bottom.

run(){
    f1=$1
    f2=$2
    echo "Started"
    # First, simplify input hathifiles to the data we want.
    # All the ic/bib records from f1 into one file...
    cut_sort $f1 ic > cut_sort_ic.tsv
    # And all the pd/bib records from f2 into another file.
    cut_sort $f2 pd > cut_sort_pd.tsv
    # Then compare the 2 simplified files.
    isodate=`date +'%Y%m%d'`
    outfile="`pwd`/ic_to_pd_${isodate}.tsv"
    diff_records cut_sort_ic.tsv cut_sort_pd.tsv > $outfile
    echo -e "Wrote $outfile"
    # Remove intermediate files
    rm cut_sort_ic.tsv cut_sort_pd.tsv
    echo "Finished"
}

# Turn a hathifile into fewer cols and sorted matching lines.
# Matching means: has rights:$rights and reason:bib
cut_sort(){
    file=$1
    rights=$2
    # Get these cols from the hathifiles:
    # 1 (id), 3 (rights), 14 (reason), 16 (govdoc),
    # grep to only get lines matching $rights,
    # and sort the output.
    zcat -f $file |
	cut -f1,3,14,16 |
	grep -P "\t${rights}\tbib\t[01]$" |
	collated_sort
}

# Compare 2 outputs from cut_sort, but only look at col 1 (id) and
# col 4 (govdoc), meaning we will only output records that have the
# same id + govdoc values in both files, meaning each output record
# changed from ic to pd but kept the same govdoc status.
diff_records(){
    ic_file=$1
    pd_file=$2
    collated_comm -12 <(cut -f1,4 $ic_file) <(cut -f1,4 $pd_file)
}

# Sort and comm must use the same collation,
# or comm won't think the files are sorted...
# and the defaults may be different, so specify.
collated_comm(){
    LC_COLLATE=C comm $@
}
collated_sort(){
    LC_COLLATE=C sort $@
}

# Script starts here.
run $1 $2
