local Search = {}


local function getBlogQueryTemplate()
	local Query = {
    ['from']= 0,
    ['size']= 10,
    ['timeout']= "30s",
    ['query']= {
        ['bool']= {
            ['filter']= {
                {
                    ['term']= {
                        ['usableStatus']= {
                            ['value']= 0,
                            ['boost']= 1
                        }
                    }
                }
            },
            ['should']= {
                {
                    ['multi_match']= {
                        ['query']= "",
                        ['fields']= {
                            "content^1.0",
                            "tags.name^1.0",
                            "title^1.0"
                        },
                        ['type']= "best_fields",
                        ['operator']= "OR",
                        ['analyzer']= "ik_max_word",
                        ['slop']= 0,
                        ['prefix_length']= 0,
                        ['max_expansions']= 50,
                        ['zero_terms_query']= "NONE",
                        ['auto_generate_synonyms_phrase_query']= true,
                        ['fuzzy_transpositions']= true,
                        ['boost']= 1
                    }
                },
                {
                    ['regexp']= {
                        	['title']= {
                            	['value']= "",
                            	['flags_value']= 65535,
                            	['max_determinized_states']= 10000,
                            	['boost']= 1
                        	}
                    	}
                	},
                	{
                    	['regexp']= {
                        	['content']= {
                            	['value']= "",
                            	['flags_value']= 65535,
                            	['max_determinized_states']= 10000,
                            	['boost']= 1
                        	}
                    	}
                	}
            	},
            	['adjust_pure_negative']= true,
            	['minimum_should_match']= "1",
            	['boost']= 1
        	}
    	},
    	['highlight']= {
        	['pre_tags']= {
        	    [[<font color="#FF0000">]]
        	},
        	['post_tags']= {
        	    "</font>"
        	},
        	['fragment_size']= 1000,
        	['number_of_fragments']= 20,
        	['fields']= {
            	['title']= {},
            	['content']= {},
            	['tags.name']= {}
        	}
    	}
	}
	return Query
end


Search.getBlogQueryTemplate = getBlogQueryTemplate
return Search