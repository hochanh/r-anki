library(RSQLite)
sqlite    <- dbDriver("SQLite")
# Import 2 anki database
rtk1.v6 <- dbConnect(sqlite,"rtk1-v6.anki2")
rtk1.full <- dbConnect(sqlite,"rtk1-full.anki2")

# Tables in database
dbListTables(rtk1.v6)


# This is review log from rtk1-v6 that we need to export
# and import to rtk1-full
dbListFields(rtk1.v6, "revlog")

dbListFields(rtk1.v6, "cards")

rtk1.v6.cid.1 <- dbGetQuery(rtk1.v6, "select id from cards")

rtk1.v6.cid.2 <- dbGetQuery(rtk1.v6, "select cid from revlog")




#
rtk1.full.cid.1 <- dbGetQuery(rtk1.full, "select id from cards")