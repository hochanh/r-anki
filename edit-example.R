library(RSQLite)
library(stringr)
sqlite    <- dbDriver("SQLite")
# Import 2 anki database
rtk1.v6 <- dbConnect(sqlite,"rtk1-v6.anki2")
rtk1.full <- dbConnect(sqlite,"rtk1-full.anki2")


# We need creat a new "revlog" table for "rtk1-full.anki2" database
# this task follow SQL syntax below:
# CREATE TABLE revlog (
#     id              integer primary key,
#        -- epoch-seconds timestamp of when you did the review
#     cid             integer not null,
#        -- cards.id
#     usn             integer not null,
#        -- all my reviews have -1
#     ease            integer not null,
#        -- which button you pushed to score your recall. 1(wrong), 2(hard), 3(ok), 4(easy)
#     ivl             integer not null,
#        -- interval
#     lastIvl         integer not null,
#        -- last interval
#     factor          integer not null,
#       -- factor
#     time            integer not null,
#        -- how many milliseconds your review took, up to 60000 (60s)
#     type            integer not null
# );


# All we need to do now is replace ALL "cid" field in table "revlog" 
# of "rtk1.v6" database by "cid" of 2200 cards in "rtk1.full" database,
# respectively.
# So we need to create a corresponsive matrix with 2 columns:
# - v6.cid is cid from rtk1.v6 database
# - full.cid is cid from rtk1.full database

# We create a table of rtk1.full database
# with 4 columns: V4, V6, Note ID, Card ID:
full.flds <- dbGetQuery(rtk1.full, "select flds from notes")
full.flds <- str_split(full.flds[,1], "\037")

full.nid <- dbGetQuery(rtk1.full, "select id from notes")
full.cid <- dbGetQuery(rtk1.full, "select nid, id from cards")

full.note <- matrix(rep("",4*2200), ncol=4, 
										dimnames=list(1:2200,c("v6","v4","nid","cid")))

for (i in 1:2200) {
	full.note[i,1] <- full.flds[[i]][3]
	full.note[i,2] <- full.flds[[i]][2]
	note.id <- full.nid[i,]
	full.note[i,3] <- note.id
	full.note[i,4] <- full.cid[full.cid$nid==note.id,2]
}

full.note <- as.data.frame(full.note, stringsAsFactors = FALSE)

# We create a table of rtk1.v6 database
# with 3 columns: V4, Note ID, Card ID, New Card ID:
v6.nid <- dbGetQuery(rtk1.v6, "select sfld, id from notes")
v6.cid <- dbGetQuery(rtk1.v6, "select nid, id from cards")

v6.note <- matrix(rep("",4*2200), ncol=4, 
									dimnames=list(1:2200,c("v4","nid","cid","newcid")))

for (i in 1:2200) {
	note.v4 <- v6.nid[i,1]
	v6.note[i,1] <- note.v4
	note.id <- v6.nid[i,2]
	v6.note[i,2] <- note.id
	v6.note[i,3] <- v6.cid[v6.cid$nid==note.id, 2]
	v6.note[i,4] <- full.note[full.note$v4==note.v4, 4]
}

v6.note <- as.data.frame(v6.note, stringsAsFactors = FALSE)

# NOW we have "v6.note" matrix with "cid" and "newcid", then what?
# we create a new "revlog" table contain everything from old table
# in rtk1.v6 database except "cid".


# Make new table from rtk1.v6
revlog.old <- dbGetQuery(rtk1.v6, "select * from revlog")
revlog.new <- revlog.old
revlog.new$cid <- 0L
for (i in 1:8061) {
  revlog.new[revlog.new$cid==]
}



# Remove tabe in rtk1.full
dbRemoveTable(rtk1.full, "revlog")


# Write new table to rtk1.full
dbWriteTable(rtk1.full, "revlog", "data where?")


