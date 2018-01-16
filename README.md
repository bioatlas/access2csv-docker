# Tool for migrating MS Access dbs to CSV

When migrating or mobilizing legacy data, sometimes data is stored in binary files in the MS Access format, often with the extension `.mdb` or `.accdb`. A step where the data is exported to an open format such as CSV is then required.

There are some free tools such as "MDB Tools", see <http://mdbtools.sourceforge.net/> (can be installed with `sudo apt install mdbtools`), which allows a FOSS system such as a host running Linux to migrate certain MS Access databases into open formats by exporting data and schema into CSV. However, the `mdbtools` is a bit long in the tooth. The latest release is from 2004 and it supports mostly Access 97 (Jet 3) and Access 2000/2002 (Jet 4) formats.

In contrast, the `access2csv` tool is Dockerized and uses the UCanAccess open-source Java JDBC driver, see <https://sourceforge.net/projects/ucanaccess/> and <http://ucanaccess.sourceforge.net/site.html>, so it supports both (.mdb and .accdb) MS Access formats: 2000, 2003, 2007, 2010 / 2013 / 2016 databases. It is up-to-date and maintained and even has an interactive console interface, see <https://sourceforge.net/p/ucanaccess/code/HEAD/tree/ucanaccess/trunk/src/main/java/net/ucanaccess/console/Main.java>

## Usage

To download and use the tool:


		# dl/install the tool		
		docker pull bioatlas/access2csv

		# example conversion on file data/OcurrenceLit.mdb
		# (run `make init` first to get the data/OcurrenceLit.mdb example file)
		docker run -it -v $(pwd)/data/:/tmp -u $(id -u):$(id -g) \
			bioatlas/access2csv -f /tmp/OcurrenceLit.mdb -d /tmp/

The Makefile provides commands for building and more detailed examples of usage

## Wishlist for access2csv

A default command to test the extraction of data from OcurrenceLit.mdb example files gives as an example a row that looks like this (using `cat OCCURRENCELiterature.csv | grep Plectrogenium | head -1`):

		375892,12965,47187,39722,114645,Plectrogenium,barsukovi,Plectrogenium barsukovi,null,N.A.,null,null,null,290.0,310.0,null,null,25,19.0,S,-25.316666666666666,85,8.0,W,-85.13333333333334,accurate,marine,null,null,null,null,null,null,null,87,null,null,null,null,null,1991,Accession,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,4,1,4,4,null,null,null,null,Literature,null,null,Compatible with distributional range,null,null,null,null,null,null,null,null,null,null,1,1998-03-17 00:00:00.000000,null,1998-03-17

As a contrast, the corresponding result from `mdb-export` includes the header row (but only provides 51667 rows instead of the 154545 rows above) and it encodes the nulls with empty fields and it quotes strings like so:

		catnum2,OccurrenceRefNo,SpecCode,StockCode,SynCode,GenusCol,SpeciesCol,ColName,PicName,CatNum,URL,Station,Gazetteer,WaterDepthMin,WaterDepthMax,AltitudeMin,AltitudeMax,LatitudeDeg,LatitudeMin,NorthSouth,LatitudeDec,LongitudeDeg,LongitudeMIn,EastWest,LongitudeDec,Accuracy,Salinity,LatitudeDegTo,LatitudeMinTo,NorthSouthTo,LongitudeDegTo,LongitudeMInTo,EastWestTo,Temp,AreaCode,SeaDrainage,C_Code,Province,Date,DateTo,Year,DateType,DayTimeStart,DayTimeStop,Length,LengthType,Length2,LengthType2,Lengthmin,Lengthmax,Weight,Number,PercentCatch,Abundance,LiveStage,Sex,Bottom,Gear,Remark_FB,Remark,Vessel,Expedition,Collector,Identifier,IdentifierStandard,IdentifierYR,QName,QIdentifier,QArea,QCountry,QCoordinates,Type,Live,MS,Storage,RecordType,BasisOfRecord,CheckedCol,Validity,DateRecapture,LatDegRel,LatMinRel,NorthSouthRel,LongDegRel,LongMinRel,EastWestRel,LengthRel,LengthTypeRel,WeightRel,Entered,DateEntered,Modified,DateModified,Expert,DateChecked,Locality1,TwoDegree30W,OneDegree30W,TenDegree30W,CSquarecode,PublishedDistance,Info,LocalityType
		375892,12965,47187,39722,114645,"Plectrogenium","barsukovi","Plectrogenium barsukovi",,"N.A.",,,,2.9000000000000000e+02,3.1000000000000000e+02,,,25,1.90000000e+01,"S",-2.5316666666666666e+01,85,8.00000000e+00,"W",-8.5133333333333340e+01,"accurate","marine",,,,,,,,87,,,,,,1991,"Accession",,,,,,,,,,,,,,,,,,,,,,,,,1,4,1,4,4,,,,,"Literature",,,"Compatible with distributional range",,,,,,,,,,,1,"03/17/98 00:00:00",,"03/17/98 00:00:00",,,"Nasca Ridge.","25S249E","25S249E","25S255E","5208:455:1",,,"Bank"

It would be good to harmonize the outputs between the two tools to get similar default behaviors, therefore here are some suggestions:

- The `mdb-export` tool lists about ten more columns for the example row above (it adds `,,"Nasca Ridge.","25S249E","25S249E","25S255E","5208:455:1",,,"Bank"`) - why is the set of columns returned different?
- By default, the tool should provide a header row with the column names, like `mdb-export`does
- By default, nulls should be encoded with an empty value ie "" instead of "null"
- By default, all text fields should be quoted using " as quotation character
- The manual should be printed when tool is called with option "-h, --help", otherwise not (use `make test-man`)
- If called with the "-list" option or "--schema" (use `make test-list` or `make test-schema`) it seems the output doesn't go to stdout, instead various exceptions with "java.io.IOException: Permission denied" occurs where expected output would be that which `mdb-tables OcurrenceLit.mdb" which produces ie a space delimited string like so to stdout: "COUNTFAOCSREF COUNTFAOPoints Museum_orig OCCURRENCE_struct OCCURRENCELiterature OCCURRENCELiterature_copy"

