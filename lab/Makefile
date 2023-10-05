dbt_docs:
	dbt docs generate && \
dbt docs serve

model_doc:
	dbt run-operation generate_model_yaml --args '{"model_names": ["$(model)"], "upstream_descriptions":true}'

clean_data:
	rm -rf ${DUCKDB_DATA}/*
