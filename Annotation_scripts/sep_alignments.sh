
# transcript alignments
awk '{ if ($2 == "est2genome") print $0 }' pelargonium_rnd2.all.maker.noseq.gff > pelargonium_rnd2.all.maker.est2genome.gff
# protein alignments
awk '{ if ($2 == "protein2genome") print $0 }' pelargonium_rnd2.all.maker.noseq.gff > pelargonium_rnd2.all.maker.protein2genome.gff
# repeat alignments
awk '{ if ($2 ~ "repeat") print $0 }' pelargonium_rnd2.all.maker.noseq.gff > pelargonium_rnd2.all.maker.repeats.gff