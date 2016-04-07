--set up the env for sanity.
.h on
.m c

--get all Human IDs out of HvsF where its a seed pair (this is the subquery we want)
select * from HvsF where ID like "ENSP%" AND seed_status = "100%" limit 3;
--count on this is: 4385
select count(*) from HvsF where ID like "ENSP%" AND seed_status = "100%";

--get the Human Seed IDs as gene IDs (by joining with the hg_gene_prot_map)
SELECT * FROM hs_gene_prot_map as hs INNER JOIN 
(select * from HvsF where ID like "ENSP%" AND seed_status = "100%") as sq 
WHERE hs.prot_id=sq.ID limit 3;


--How big is this? = 4109
SELECT count(*) FROM hs_gene_prot_map as hs INNER JOIN 
(select * from HvsF where ID like "ENSP%" AND seed_status = "100%") as sq 
WHERE hs.prot_id=sq.ID ;





--get all FLY IDs out of HvsF where its a seed pair (this is the subquery we want)
select * from HvsF where ID like "FBpp%" AND seed_status = "100%" limit 3;
--count on this is 4612
select count(*) from HvsF where ID like "FBpp%" AND seed_status = "100%";

--get the join going
SELECT * FROM dm_gene_prot_map as dm INNER JOIN 
(select * from HvsF where ID like "FBpp%" AND seed_status = "100%") as sq 
WHERE dm.prot_id=sq.ID limit 3;


--How many fly genes can I get from a similar query to above? = 4558
SELECT count(*) FROM dm_gene_prot_map as dm INNER JOIN 
(select * from HvsF where ID like "FBpp%" AND seed_status = "100%") as sq 
WHERE dm.prot_id=sq.ID ;





--Lets do a merger between man and rat (just to test out the rat table)
select * from HvsR where ID like "ENSR%" AND seed_status = "100%" limit 3;
--count on this one is 14700
select count(*) from HvsR where ID like "ENSR%" AND seed_status = "100%" limit 3;

--JOIN
SELECT * FROM rn_gene_prot_map as rn INNER JOIN 
(select * from HvsR where ID like "ENSR%" AND seed_status = "100%") as sq 
WHERE rn.prot_id=sq.ID limit 3;


--How many rat genes can I get from a similar query to above? = 14695 (very slow)
SELECT count(*) FROM rn_gene_prot_map as rn INNER JOIN 
(select * from HvsR where ID like "ENSR%" AND seed_status = "100%") as sq 
WHERE rn.prot_id=sq.ID;




--What if we want to look at mouse relative to man?
select * from HvsM where ID like "mgi:%" AND seed_status = "100%" limit 3;




--So this all looks good so far, but what we ultimately want is to make a remapped table, 
--one that looks just like the inparanoid ones, but which has some other kind of ID in there.  
--Something like an EG ID instead.  But the numbers above indicate that in some cases, we 
--will not HAVE the ID we seek (IDs get retired etc.) so in those cases what do we want to do?
--We could: 1) drop the relation from the table or 2) leave the old less useful ID in there.
--I think we want to do option #2.  So that implies that I want to do a cross join 

--this would be backwards
--SELECT * FROM dm_gene_prot_map as dm LEFT JOIN 
--(select * from HvsF) as sq 
--ON dm.prot_id=sq.ID limit 3;

--What are the prot_ids that are in the HvsF, and NOT in the dm_gene_prot_map? - these are mostly the paralogs (it turns out)
SELECT * FROM 
(SELECT * FROM HvsF WHERE ID LIKE "FBpp%") 
as HF LEFT JOIN dm_gene_prot_map as dm 
ON HF.ID=dm.prot_id limit 40;

--Then we want to left join these
SELECT * FROM HvsF as sq 
LEFT JOIN dm_gene_prot_map as dm
ON dm.prot_id=sq.ID limit 10;




--One strategy is just to put all the gene_id and prot_id into one big table and then just do inner joins with that.

--Then its just a big left join to get all the values into one table.
--IT HAS to be a left join because there will be about ~800 rows in the ~15000 rows for HvsF that are missing (unmappable)
SELECT * FROM A LEFT JOIN B ON A.a=B.b
--So the basic join we WANT is:
SELECT * FROM HvsF as HF LEFT JOIN prot_gene as pg ON pg.prot_id=HF.ID limit 4;


--Finally then I will have to filter out so that I get the correct stuff into the final trimmed table.
SELECT clust_id,prot_id,gene_id,ID,seed_status  FROM
(SELECT * FROM HvsF as HF LEFT JOIN prot_gene as pg ON pg.prot_id=HF.ID)
limit 10;




--1st we can just mock up the same thing we get from:
SELECT * FROM HvsF as HF LEFT JOIN prot_gene as pg ON pg.prot_id=HF.ID limit 10;
--But based on a union version of two seperate queries...
SELECT clust_id,prot_id,gene_id,ID,seed_status  FROM
(SELECT * FROM HvsF as HF LEFT JOIN prot_gene as pg ON pg.prot_id=HF.ID)
WHERE prot_id IS NOT NULL
UNION
SELECT clust_id,prot_id,gene_id,ID,seed_status  FROM
(SELECT * FROM HvsF as HF LEFT JOIN prot_gene as pg ON pg.prot_id=HF.ID)
WHERE prot_id IS NULL limit 10;



--Then we just do the 'ol switcheroo to combine the 2nd field....
SELECT clust_id,prot_id,prot_id,gene_id,ID,seed_status  FROM
(SELECT * FROM HvsF as HF LEFT JOIN prot_gene as pg ON pg.prot_id=HF.ID)
WHERE prot_id IS NOT NULL
UNION
SELECT clust_id,ID,prot_id,gene_id,ID,seed_status  FROM
(SELECT * FROM HvsF as HF LEFT JOIN prot_gene as pg ON pg.prot_id=HF.ID)
WHERE prot_id IS NULL limit 10;


--And actually, what I really want to do is to combine the gene IDs with the IDs
SELECT clust_id,gene_id,prot_id,gene_id,ID,seed_status  FROM
(SELECT * FROM HvsF as HF LEFT JOIN prot_gene as pg ON pg.prot_id=HF.ID)
WHERE prot_id IS NOT NULL
UNION
SELECT clust_id,ID,prot_id,gene_id,ID,seed_status  FROM
(SELECT * FROM HvsF as HF LEFT JOIN prot_gene as pg ON pg.prot_id=HF.ID)
WHERE prot_id IS NULL limit 10;
