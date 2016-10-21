SELECT DISTINCT p2e.DB_ID, e2i.indirectIdentifier FROM reactome_dn.Pathway_2_hasEveryComponent AS p2e, reactome_dn.Event_2_indirectIdentifier AS e2i WHERE e2i.DB_ID = p2e.hasEveryComponent AND e2i.indirectIdentifier LIKE "%Entrez%" INTO OUTFILE "/tmp/pathway2gene.txt";

SELECT DB_ID, indirectIdentifier FROM reactome_dn.Event_2_indirectIdentifier WHERE indirectIdentifier LIKE "%go%" INTO OUTFILE "/tmp/reactome2go.txt";

SELECT DISTINCT(do.DB_ID), do2._displayName, do._displayName FROM reactome.DatabaseObject AS do, reactome.Event_2_species AS e2s, reactome.DatabaseObject AS do2 WHERE do._class = "Pathway" AND e2s.DB_ID = do.DB_ID AND do2.DB_ID = e2s.species INTO OUTFILE "/tmp/pathway2name.txt";