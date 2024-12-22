#!/bin/bash

# Se connecter à PostgreSQL et fait tous les types joins
psql -U mafoin -d csv_database -c "
    SET enable_hashjoin = off;
    SET enable_mergejoin = off;
    SET enable_sort = off;
    SET enable_nestloop = on;
    EXPLAIN ANALYZE SELECT * FROM TABLE_$1_A JOIN TABLE_$1_B ON TABLE_$1_A.Entier = TABLE_$1_B.Entier;
    SET enable_mergejoin = off;
    SET enable_nestloop = off;
    SET enable_sort = off;
    SET enable_hashjoin = on;
    EXPLAIN ANALYZE SELECT * FROM TABLE_$1_A JOIN TABLE_$1_B ON TABLE_$1_A.Entier = TABLE_$1_B.Entier;
    SET enable_hashjoin = off;
    SET enable_nestloop = off;
    SET enable_sort = on;
    SET enable_mergejoin = on;
    EXPLAIN ANALYZE SELECT * FROM TABLE_$1_A JOIN TABLE_$1_B ON TABLE_$1_A.Entier = TABLE_$1_B.Entier;
    " > out/$1.txt
