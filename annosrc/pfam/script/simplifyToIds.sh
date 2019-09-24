#!/bin/sh

# #this works:
# grep "#=GF [A,D][C,R]" Pfam-A.full  > tempIDs
# grep -v "#=GF DC" tempIDs > PFAM_IDs.txt
# rm -f tempIDs


#Good news: everything appears to be in there.
#Not so good news: its all encoded oddly so there is some preprocessing to write.

# #I will begin by separating things into sequence (GS) based 
# #entries and the file based annotations

echo "Pfam-A.part"
rm -f Pfam-A.part
grep "#=G[F,S]" Pfam-A.full  > Pfam-A.part
echo "Pfam-A.GF"
rm -f Pfam-A.GF
grep "#=GF" Pfam-A.full  > Pfam-A.GF
echo "Pfam-A.GS"
rm -f Pfam-A.GS
grep "#=GS" Pfam-A.full  > Pfam-A.GS

#Next I will split the GF based stuff into 5 files.  
#Each one needs to have its own set of alternating AC accessions 
#or the other information will be meaningless.

#1st we can get the files for the DR (reference) IDs
#=GF DR and #=GF ACi
echo "DR_IDs"
rm -f DR_IDs.txt
grep "#=GF [A,D][C,R]" Pfam-A.GF > tempIDs
grep -v "#=GF DC" tempIDs > tempIDs2
cat tempIDs2 | awk -F " " '{print $2"\t"$3"\t"$4"\t"$5}' > DR_IDs.txt
rm -f tempIDs

#2nd we can get the files for the DE ids 
echo "DE_IDs"
rm -f DE_IDs.txt
grep "#=GF [A,D][C,E]" Pfam-A.GF > tempIDs
grep -v "#=GF DC" tempIDs > tempIDs2
cat tempIDs2 | perl -ne 'chomp($_);s/^#=GF\s+?([A,D][C,E])\s+?(.+)/$1\t$2/g;print($_,"\n")'  > DE_IDs.txt
rm -f tempIDs*

#3rd we can get the files for the ID ids
#note that ID happens BEFORE AC in orig file (unlike the others)
echo "ID_IDs"
rm -f ID_IDs.txt
grep "#=GF [A,I][C,D]" Pfam-A.GF > tempIDs
cat tempIDs | awk -F " " '{print $2"\t"$3}' > ID_IDs.txt
rm -f tempIDs

#4th we can get the files for the RM ids
echo "RM_IDs"
rm -f RM_IDs.txt
grep "#=GF [A,R][C,M]" Pfam-A.GF > tempIDs
grep -v "#=GF AM" tempIDs > tempIDs2
cat tempIDs2 | awk -F " " '{print $2"\t"$3}' > RM_IDs.txt
rm -f tempIDs*

#5th we can get the files for the TP ids
echo "TP_IDs"
rm -f TP_IDs.txt
grep "#=GF [A,T][C,P]" Pfam-A.GF > tempIDs
grep -v "#=GF TC" tempIDs > tempIDs2
cat tempIDs2 | awk -F " " '{print $2"\t"$3}' > TP_IDs.txt
rm -f tempIDs*



# #One last step is to clean up the GS file 
# #(and then split it into two parts so I can 
# # load it into two tables and then join it up later on...
# rm -f GS_ACs.tab
# grep "  AC " Pfam-A.GS > tempIDs
# cat tempIDs | awk -F " " '{print $2"\t"$3,"\t"$4}' > GS_ACs.tab
# sed -i -e "s/;//g" GS_ACs.tab
# rm -f tempIDs*

# rm -f GS_DRs.tab
# grep "  DR " Pfam-A.GS > tempIDs
# cat tempIDs | awk -F " " '{print $2"\t"$3"\t"$4"\t"$5" "$6"\t"$7}' > tempIDs2
# sed -i -e "s/;//g" tempIDs2
# cat tempIDs2 | perl -ne 'chomp($_);s/(.+?)\t(DR)\t(PDB)\t(.+?)\t(\d+?)-(\d+?)/$1\t$2\t$3\t$4\t$5\t$6/g;print($_,"\n")' > GS_DRs.tab
# R --slave < ../script/readWrite.R
# rm -f tempIDs*


##Rather than cleaning up the GS files, what we really need is just to tie the pdb fields to the PFAM
##So lets make a file that has stuff like that inside it:

#We want things that fit the pattern:
#=GF AC and #GS ... DR PDB
echo "PDB_IDs"
rm -f PDB_IDs.txt
grep -E "GF AC|DR PDB" Pfam-A.part > tempIDs
cat tempIDs | awk -F " " '{print $2"\t"$3"\t"$4"\t"$5" "$6"\t"$7}' > tempIDs2
sed -i -e "s/;//g" tempIDs2
cat tempIDs2 | perl -ne 'chomp($_);s/(.+?)\t(DR)\t(PDB)\t(.+?)\t(\d+?)-(\d+?)/$3\t$4\t$5\t$6/g;print($_,"\n")' > tempIDs3
cat tempIDs3 | perl -ne 'chomp($_);s/(AC)\t(.+?)\t(.+)/$1\t$2\t\t/g;print($_,"\n")' > PDB_IDs.txt
rm -f tempIDs*

#the aim is then to just run parseComplex on PDB_IDs.txt
