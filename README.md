# socarxiv-data
Description: Data from SocArXiv and code to produce collaboration networks from the json objects
 Author: Christopher Steven Marcum <cmarcum@uci.edu>
 Date: 1 May 2018
 Last Modified: 1 May 2018

I. Summary 

 This collection represents files used to make, and generated from, GET calls to the OSF api (https://api.osf.io/). Specifically, either authenticated or non-authenticated GET calls run through socarxiv.R, with error recall fixes in sarecall.R, were made to the OSF API to pull data from preprints in the SocArXiv collection. Intermediate and protected files (i.e., JSON objects and api tokens) were not deposited in git.

 There may be human- or API-induced errors in the dataset (see Section III.)

II. List of files:

 1. callback : a dummy callback file for OAuth app, no end user utility

 2. nntw.csv : a semi-manually curated list of full_names associated with twitter handles, end users may wish to correct errors or modify

 3. PlotSANet.R : R script working on socarxiv.Rdata to generate network plots SA10Com.gif and SANet.png, end users may wish to use this code to generate new plots etc

 4. SA10Com.gif : animated figure of the first 10 components of the final network

 5. SANet.gif : raster image of final network, isolates suppressed, colored by component membership

 6. sarecall.R : script use to patch up errors in calling the API, end users may wish to see this method but not-replicable in general

 7. socarxiv.FriApr201457482018.Rdata : an intermediate file storing converted JSON objects as lists of dataframes in an R workspace environment

 8. socarxiv.R : the master api call script,  end users may wish to see this method

 9. socarxiv.Rdata : the final network dataset saved in a R workspace environment (requires network packages to use)

III. Known Errors

These 14 vertices require deduplication (i.e., reduced to v=7)
 Some users have two id instantiations (this can arise for several reasons, including:
 1) user has two (unlinked) OSF accounts
 2) user has no OSF account (multiple third-party submitter effects) e.g., Golgher  with cnm54 and vwp76
 3) user has multiple contributions with different account statuses over time (active vs. not active) e.g. Billari with xye9a (not active) and baz53 (active)

Other errors can arise due to temporal changes in spelling or character encoding e.g., Präg
Still others have unknown resolution and may not need to be deduplicated e.g., Neimneh and Neimneh.
The following can be copypasta'd the first column indexes the vertex position in socarxiv network object.

 vp,vertex.name,uid
 101, "AndrÃ© B. Golgher",                          "cnm54"
 102, "AndrÃ© Braz Golgher",                        "vwp76"
 136, "Anthony B. Aktinson",                        "bx23f"
 137, "Anthony B. Atkinson",                        "vfjgd"
 213, "Brianna L. Schofield",                       "yr5m9"
 215, "Brianna Schofield",                          "4vw33"
 363, "Dina Al Jamal",                              "rt6kz"
 364, "Dina Al-Jamal",                              "z84m3"
 468, "Francesco Billari",                          "xye9a"
 469, "Francesco C Billari",                        "baz53"
 1072, "Patrick PrÃ¤g",                              "euzd6"
 1073, "Patrick Präg",                               "euzd6"
 1257, "Shadi S. Neimneh",                           "rtd3h"
 1258, "Shadi Saleh Ahmad Neimneh",                  "3vvfw"
