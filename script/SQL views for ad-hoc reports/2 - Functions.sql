CREATE OR REPLACE FUNCTION public.reportingcrosstab(tableselect character varying, 
                                                    tablefrom character varying, 
                                                    tablewhere character varying,
                                                    tableidfieldname character varying,
                                                    lookuptablename character varying,
                                                    lookupfieldname character varying,
                                                    celldatatype character varying)

RETURNS character varying AS

$BODY$

declare

    dynsql1 varchar;
    dynsql2 varchar;
    valueslist varchar;
    columnlist varchar;

begin

    -- Values
    dynsql1 = 'select string_agg(distinct ''(''''''||'||lookupfieldname||'||'''''')'','','' order by ''(''''''||'||lookupfieldname||'||'''''')'') from '||lookuptablename||';';
    --RAISE NOTICE '%', dynsql1;
    execute dynsql1 into valueslist;
    
    -- Columns
    dynsql1 = 'select string_agg(distinct ''_''||'||lookupfieldname||'||'' '||celldatatype||''','','' order by ''_''||'||lookupfieldname||'||'' '||celldatatype||''') from '||lookuptablename||';';
    --RAISE NOTICE '%', dynsql1;
    execute dynsql1 into columnlist;

    -- Set up the crosstab query
    dynsql2 = 'select * from crosstab ( ''SELECT '||tableselect||' FROM '||tablefrom||' WHERE '||tablewhere||' ORDER BY 1,2''::text, $$VALUES '||valueslist||' $$) ct ( '||tableidfieldname||' integer,'||columnlist||' );';
    RAISE NOTICE '%', dynsql2;
    RAISE NOTICE ' ';

    return dynsql2;

 end

 $BODY$

  LANGUAGE plpgsql VOLATILE

  COST 100;


-- Function: refreshallmaterializedviews(text)

-- DROP FUNCTION refreshallmaterializedviews(text);

CREATE OR REPLACE FUNCTION refreshallmaterializedviews(schema_arg text DEFAULT 'public'::text)
  RETURNS integer AS
$BODY$
    DECLARE
        r RECORD;
    BEGIN
        RAISE NOTICE 'Refreshing materialized view in schema %', schema_arg;
        FOR r IN SELECT matviewname FROM pg_matviews WHERE schemaname = schema_arg
        LOOP
            RAISE NOTICE 'Refreshing %.%', schema_arg, r.matviewname;
            EXECUTE 'REFRESH MATERIALIZED VIEW ' || schema_arg || '."' || r.matviewname ||'"';
        END LOOP;

        RETURN 1;
    END
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;