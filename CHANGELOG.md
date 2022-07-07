#0.0.6
- new ruby 3 image for ruby 3 testing
- fix get_new_column_type incompatibility with ruby 

#0.0.5
- rubocop-shopify added to dev dependencies
- fixed ruby 3.0 incompatibility in delegate_uniqueness, now gem could be used with ruby 3+

#0.0.4
- removed 'OR REPLACE' in trigger definition, lowering Postgres version constraint 
- trigger_condition added ( could replace partial uniq index ) 
 
#0.0.3
- wrapper_function options added, you can define function to convert to uniquely sortable types, for instance array to string 
- moved all helper functions to internal module, just to keep things clear on the migrations

#0.0.2
- delegate_uniqueness helper is available as a migration method
- functionality worked and tested 