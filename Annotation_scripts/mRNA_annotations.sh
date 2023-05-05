# be sure your reference genome is indexed with samtools (.fai file is present)
awk -v OFS="\t" '{ if ($3 == "mRNA") print $1, $4, $5 }' ../../pelargonium_citronellum.maker_1stround.output/pelargonium_rnd1.all.maker.noseq.gff | \
  while read rna; \
  do \
  scaffold=`echo ${rna} | awk '{ print $1 }'`; \
  end=`cat ../../pelargonium_citronellum.fasta.fai | awk -v scaffold="${scaffold}" \
    -v OFS="\t" '{ if ($1 == scaffold) print $2 }'`; \
  echo ${rna} | awk -v end="${end}" -v OFS="\t" '{ if ($2 < 1000 && (end - $3) < 1000) print $1, "0", end; \
    else if ((end - $3) < 1000) print $1, "0", end; \
    else if ($2 < 1000) print $1, "0", $3+1000; \
    else print $1, $2-1000, $3+1000 }'; \
  done | \
  bedtools getfasta -fi ../../pelargonium_citronellum.fasta -bed - -fo pelargonium_rnd1.all.maker.transcripts1000.fasta