-- ## This produces hits:
SELECT * FROM ReferenceEntity_2_otherIdentifier AS g, EntityWithAccessionedSequence AS s  WHERE g.DB_ID = s.referenceEntity;

-- ## This does NOT:
SELECT * FROM ReferenceEntity_2_otherIdentifier AS g, SimpleEntity_2_referenceEntity AS s  WHERE g.DB_ID = s.referenceEntity;

-- ## Neither does this?
SELECT * FROM ReferenceEntity_2_otherIdentifier AS g, OpenSet AS s  WHERE g.DB_ID = s.referenceEntity;

-- ## So I only have to worry about the physical entities that are EntityWithAccessionedSequence


-- #####################################################
-- ## A bit better
SELECT DISTINCT s.DB_ID, g.otherIdentifier FROM ReferenceEntity_2_otherIdentifier AS g, EntityWithAccessionedSequence AS s  WHERE g.DB_ID = s.referenceEntity AND otherIdentifier LIKE "EntrezGene:%"  ;



-- ########################################################
-- ########################################################
-- ########################################################
-- ########################################################
-- ## Trail of Tables (From Pathway to ReferenceEntity_2_otherIdentifier)

-- ## via catalysts:
-- -- Pathway_2_hasEvent  ## Can be a pathway, reaction or BlackBoxEvent
-- -- ReactionlikeEvent_2_catalystActivity ## one example
-- -- CatalystActivity
-- -- EntityWithAccessionedSequence
-- -- ReferenceEntity_2_otherIdentifier

SELECT p.DB_ID, cc.physicalEntity FROM Pathway_2_hasEvent AS p, ReactionlikeEvent_2_catalystActivity AS c, CatalystActivity AS cc WHERE p.hasEvent=c.DB_ID AND c.catalystActivity=cc.DB_ID ;

-- ## via catalysts that are part of a complex
-- -- Pathway_2_hasEvent  ## Can be a pathway, reaction or BlackBoxEvent
-- -- ReactionlikeEvent_2_catalystActivity ## one example
-- -- CatalystActivity
-- -- Complex_2_hasComponent
-- -- EntityWithAccessionedSequence
-- -- ReferenceEntity_2_otherIdentifier

SELECT p.DB_ID, ccc.hasComponent FROM Pathway_2_hasEvent AS p, ReactionlikeEvent_2_catalystActivity AS c, CatalystActivity AS cc, Complex_2_hasComponent AS ccc WHERE p.hasEvent=c.DB_ID AND c.catalystActivity=cc.DB_ID AND cc.physicalEntity_class='Complex' AND  cc.physicalEntity=ccc.DB_ID ;


-- ## via inputs
-- -- Pathway_2_hasEvent
-- -- ReactionlikeEvent_2_input ## one example
-- -- EntityWithAccessionedSequence
-- -- ReferenceEntity_2_otherIdentifier

SELECT p.DB_ID, i.input FROM Pathway_2_hasEvent AS p, ReactionlikeEvent_2_input AS i WHERE p.hasEvent=i.DB_ID ;

-- ## via outputs
-- -- Pathway_2_hasEvent
-- -- ReactionlikeEvent_2_output ## one example
-- -- EntityWithAccessionedSequence
-- -- ReferenceEntity_2_otherIdentifier

-- ## via regulations??? - no real options???

SELECT p.DB_ID, o.output FROM Pathway_2_hasEvent AS p, ReactionlikeEvent_2_output AS o WHERE p.hasEvent=o.DB_ID ;


-- #####################################################
-- ## Now put them together to make 4 queries.

--catalysts:
SELECT c.DB_ID AS pathway, ltrim(g.otherIdentifier,'EntrezGene:') AS entrez_gene FROM (SELECT p.DB_ID, cc.physicalEntity FROM Pathway_2_hasEvent AS p, ReactionlikeEvent_2_catalystActivity AS c, CatalystActivity AS cc WHERE p.hasEvent=c.DB_ID AND c.catalystActivity=cc.DB_ID) AS c, (SELECT DISTINCT s.DB_ID, g.otherIdentifier FROM ReferenceEntity_2_otherIdentifier AS g, EntityWithAccessionedSequence AS s  WHERE g.DB_ID = s.referenceEntity AND otherIdentifier LIKE 'EntrezGene:%') as g WHERE c.physicalEntity = g.DB_ID ;


--catalysts in complexes:
SELECT c.DB_ID AS pathway, ltrim(g.otherIdentifier,'EntrezGene:') AS entrez_gene FROM (SELECT p.DB_ID, ccc.hasComponent FROM Pathway_2_hasEvent AS p, ReactionlikeEvent_2_catalystActivity AS c, CatalystActivity AS cc, Complex_2_hasComponent AS ccc WHERE p.hasEvent=c.DB_ID AND c.catalystActivity=cc.DB_ID AND cc.physicalEntity_class='Complex' AND  cc.physicalEntity=ccc.DB_ID) AS c, (SELECT DISTINCT s.DB_ID, g.otherIdentifier FROM ReferenceEntity_2_otherIdentifier AS g, EntityWithAccessionedSequence AS s  WHERE g.DB_ID = s.referenceEntity AND otherIdentifier LIKE 'EntrezGene:%') as g WHERE c.hasComponent = g.DB_ID ;


--inputs
SELECT i.DB_ID AS pathway, ltrim(g.otherIdentifier,'EntrezGene:') AS entrez_gene FROM (SELECT p.DB_ID, i.input FROM Pathway_2_hasEvent AS p, ReactionlikeEvent_2_input AS i WHERE p.hasEvent=i.DB_ID) AS i, (SELECT DISTINCT s.DB_ID, g.otherIdentifier FROM ReferenceEntity_2_otherIdentifier AS g, EntityWithAccessionedSequence AS s  WHERE g.DB_ID = s.referenceEntity AND otherIdentifier LIKE 'EntrezGene:%') as g WHERE i.input = g.DB_ID ;


--outputs
SELECT o.DB_ID AS pathway, ltrim(g.otherIdentifier,'EntrezGene:') AS entrez_gene FROM (SELECT p.DB_ID, o.output FROM Pathway_2_hasEvent AS p, ReactionlikeEvent_2_output AS o WHERE p.hasEvent=o.DB_ID) AS o, (SELECT DISTINCT s.DB_ID, g.otherIdentifier FROM ReferenceEntity_2_otherIdentifier AS g, EntityWithAccessionedSequence AS s  WHERE g.DB_ID = s.referenceEntity AND otherIdentifier LIKE 'EntrezGene:%') as g WHERE o.output = g.DB_ID ;





-- ## For regulators, I apparently have to work backwards to reactionLikeEvent and then connect them to pathways


-- ## AND it looks really ugly, because from Regulation alone I see a query to to go to Pathway, as well as one to go to CatalystActivity and another to go to Reaction.
-- ## ALSO: Still unclear how I get from a reaction / catalyst activity etc to a pathway?  Some of these *are* pathways though so at least that is straightforward?  


SELECT * FROM Regulation WHERE regulatedEntity_class = "Pathway" limit 40;
-- choose to explore one
SELECT * FROM Pathway_2_hasEvent WHERE DB_ID = '83572';
-- leads to reactions and also a Pathway (that in turn leads to more reactions)


SELECT * FROM Pathway_2_hasEvent WHERE DB_ID = '75177';



-- ALSO: I need to check back when querying Pathway_2_hasEvent AS OFTEN the clas is itself a pathway, and so I need to "expand" those...


