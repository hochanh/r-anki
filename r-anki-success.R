library(RSQLite)
library(stringr)
sqlite    <- dbDriver("SQLite")
# Import 2 anki database
rtk1.v6 <- dbConnect(sqlite,"rtk1-v6.anki2")
rtk1.full <- dbConnect(sqlite,"rtk1-full.anki2")

# We create a table of rtk1.full database
# with 4 columns: V4, V6, flds, sfld:
full.flds <- dbGetQuery(rtk1.full, "select flds from notes")
full.split <- str_split(full.flds[,1], "\037")

full.note <- matrix(rep(0L,2*2200), ncol=2, 
										dimnames=list(1:2200,c("v4","flds")))

for (i in 1:2200) {
	full.note[i,1] <- full.split[[i]][2]
	full.note[i,2] <- full.flds[i,1]
}

full.note <- as.data.frame(full.note, stringsAsFactors = FALSE)

# Call old note from rtk1-v6
notes.old <- dbGetQuery(rtk1.v6, "select * from notes")
notes.new <- notes.old

for (i in 1:2200) {
	v4.no <- notes.new[i, 8]
	notes.new[i, 7] <- full.note[full.note$v4==v4.no, 2]
}

# Write table
dbWriteTable(rtk1.v6, "notes_2", notes.new)

dbSendQuery(rtk1.v6, 
"UPDATE notes 
	SET flds = (SELECT notes_2.flds 
		FROM notes_2 
		WHERE notes_2.sfld = notes.sfld);")

dbSendQuery(rtk1.v6, "DROP TABLE notes_2")

# Disconnect
dbDisconnect(rtk1.full)
dbDisconnect(rtk1.v6)

# AS LONG AS YOU DON'T CHECK DATABASE IN ANKI,
# EVERYTHING WILL BE FINE!
# I'LL FIND DOWN WHY LATER :)
