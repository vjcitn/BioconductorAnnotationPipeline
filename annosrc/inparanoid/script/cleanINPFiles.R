#This script just steps through all the files in a dir and reprocesses each one...

#read in list of files in a dir.
listIDs = list.files(path=".")

for(i in 1:length(listIDs)){
    data = read.delim(listIDs[i], header=F, sep="\t")
    write.table(data,file=listIDs[i],quote=FALSE,sep="\t",col.names=FALSE,row.names=FALSE)
}
