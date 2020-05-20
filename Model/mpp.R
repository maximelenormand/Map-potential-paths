mpp=function(season,delta_w,delta_r,wd){  

            # Update Resistance.ini (if needed)
	    con=file(paste0(wd, "/Model/Resistance.ini"), "r")
		ini=readLines(con)
	    close(con)

	    ini[37]=paste0("output_file = ", wd, "/Model/Resistance.out")
	    ini[58]=paste0("point_file = ", wd, "/Model/Node.asc")
	    ini[66]=paste0("habitat_file = ", wd, "/Model/Resistance.asc")

	    write.table(ini, paste0(wd, "/Model/Resistance.ini"), col.names=FALSE, row.names=FALSE, quote=FALSE)

	    # Import data
	    lu=raster(paste0(wd, "/Inputs/LU_", season, ".tif"))      # Import raster land use according to the season
	    roads=raster(paste0(wd, "/Inputs/Roads.tif"))             # Import raster roads
	    border=raster(paste0(wd, "/Inputs/Border.tif"))           # Import raster border
	    node=raster(paste0(wd, "/Inputs/Node.tif"))               # Import raster nodes (of livestock mobility network)
	    OD=read.csv2(paste0(wd, "/Inputs/OD_",season,".csv"))     # Import OD (i.e. livestock mobility network) according to the season

            # Number of links in the livestock mobility network
            n=dim(OD)[1]   

	    # Build resistance raster 
	    matlu=as.matrix(lu)
	    matroads=as.matrix(roads)
	    matborder=as.matrix(border)

	    resistance=matlu
	    resistance[!is.na(matlu)]=delta_w*(matlu[!is.na(matlu)]*99+1)

	    resistance[matroads==1 & !is.na(matroads)]=100
	    resistance[matborder==1 & !is.na(matborder)]=100
	    resistance[matborder==0 & !is.na(matborder)]=delta_r*resistance[matborder==0 & !is.na(matborder)]

	    resistance[!is.na(resistance)]=100-resistance[!is.na(resistance)]

	    resistance[!is.na(resistance) & resistance==0]=1

	    resistance=setValues(lu,resistance)  

	    writeRaster(resistance, filename=paste0(wd, "/Model/Resistance.asc"), overwrite = TRUE)

	    # Initialized the current map           
	    currentrast=lu
	    current=as.matrix(currentrast)
	    current=matrix(0, nrow=dim(current)[1], ncol=dim(current)[2])

            # Initialized total number of animals
            tot=0
	 
            # Loop over the number of links in the livestock mobility network
	    for(i in 1:n){

		print(c(i,n))

                # Set origin and destination
		from=OD[i,1]
		to=OD[i,2]

		# Export node in Circuitscape format (.asc, from=1, to=2, NA otherwise)
		matnode=as.matrix(node)

		if(sum(matnode[!is.na(matnode)]==from)==0 | sum(matnode[!is.na(matnode)]==to)==0){   # Skip if "from" or "to" not in nodes (may append)
		    next                                                                             # May append for markets in OD located outside Senegal, Gambia or Mauritania 
		}

		matnode[!is.na(matnode) & matnode!=from & matnode!=to]=NA
		matnode[matnode==from & !is.na(matnode)]=1
		matnode[matnode==to & !is.na(matnode)]=2

		nodetemp=setValues(node, matnode)
		writeRaster(nodetemp, filename=paste0(wd, "/Model/Node.asc"), overwrite = TRUE)

                # Run Circuitscape
		system(paste0("cd ", wd, "/Model && python2 csrun.py Resistance.ini"))

                # Check if "from" and "to" are connected
		check=read.table(paste0(wd, "/Model/Resistance_resistances.out")) 
		if(sum(check==-1)>0){
		    next
		}

                # Import Circuitscape current map
		currenti=raster(paste0(wd, "/Model/Resistance_curmap_1_2.asc"))
		currenti=as.matrix(currenti)

                # Normalize by the maximum
		currenti[!is.na(currenti)]=currenti[!is.na(currenti)]/max(currenti[!is.na(currenti)])  
	    
                # Weight by the number of animals in the OD
		current[!is.na(currenti)]=current[!is.na(currenti)]+OD[i,3]*currenti[!is.na(currenti)]

                # Update total number of animals
                tot=tot+OD[i,3]
	    
	    }

            # Normalized by the total number of animals           
	    current[!is.na(current)]=current[!is.na(current)]/tot

            # Export current map
	    currentrast=setValues(currentrast,current)
	    writeRaster(currentrast, paste0(wd, "/Model/Current.tif"), overwrite=TRUE) 

	    # Remove files
	    file.remove(paste0(wd, "/Model/Resistance_curmap_1_2.asc"))
	    file.remove(paste0(wd, "/Model/Resistance_cum_curmap.asc"))
	    file.remove(paste0(wd, "/Model/Resistance_resistances.out"))
	    file.remove(paste0(wd, "/Model/Resistance_resistances_3columns.out"))

}








