This script is to merge the files provided on the Sabre emergo site for DST. 
One file contains all the different DST Variance as well as the start and end of DST for each country and timezone in that country.
the other file is all the Airports as well as the country and timezone. 

Once the proper files are provided in the root path of this script it will create an output of AirportDST.csv with no header info.

The headers should be:
Airport, Country, Timezone, StartDST , EndDST, DSTVariant, StandardDST