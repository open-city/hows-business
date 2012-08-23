library(GFu

ft.connect <- function(username, password) {
  url = "https://www.google.com/accounts/ClientLogin";
  params = list(Email = username, Passwd = password, accountType="GOOGLE", service= "fusiontables", source = "R_client_API")
 connection = postForm(uri = url, .params = params)
 if (length(grep("error", connection, ignore.case = TRUE))) {
 	stop("The wrong username or password")
 	return ("")
 }
 authn = strsplit(connection, "\nAuth=")[[c(1,2)]]
 auth = strsplit(authn, "\n")[[c(1,1)]]
 return (auth)
}

ft.disconnect <- function(connection) {
}

ft.executestatement <- function(auth, statement) {
      url = "http://tables.googlelabs.com/api/query"
      params = list( sql = statement)
      connection.string = paste("GoogleLogin auth=", auth, sep="")
      opts = list( httpheader = c("Authorization" = connection.string))
      result = postForm(uri = url, .params = params, .opts = opts) 
      if (length(grep("<HTML>\n<HEAD>\n<TITLE>Parse error", result, ignore.case = TRUE))) {
      	stop(paste("incorrect sql statement:", statement)) 
      }
      return (result)  
}

ft.showtables <- function(auth) {
   url = "http://tables.googlelabs.com/api/query"
   params = list( sql = "SHOW TABLES")
   connection.string = paste("GoogleLogin auth=", auth, sep="")
   opts = list( httpheader = c("Authorization" = connection.string))
   result = getForm(uri = url, .params = params, .opts = opts)
   tables = strsplit(result, "\n")
   tableid = c()
   tablename = c()
   for (i in 2:length(tables[[1]])) { 
     	str = tables[[c(1,i)]]
   	    tnames = strsplit(str,",")
   	    tableid[i-1] = tnames[[c(1,1)]]
   	    tablename[i-1] = tnames[[c(1,2)]] 
   	}
   	tables = data.frame( ids = tableid, names = tablename)
    return (tables)
}

ft.describetablebyid <- function(auth, tid) {
   url = "http://tables.googlelabs.com/api/query"
   params = list( sql = paste("DESCRIBE", tid))
   connection.string = paste("GoogleLogin auth=", auth, sep="")
   opts = list( httpheader = c("Authorization" = connection.string))
   result = getForm(uri = url, .params = params, .opts = opts)
   columns = strsplit(result,"\n")
   colid = c()
   colname = c()
   coltype = c()
   for (i in 2:length(columns[[1]])) { 
     	str = columns[[c(1,i)]]
   	    cnames = strsplit(str,",")
   	    colid[i-1] = cnames[[c(1,1)]]
   	    colname[i-1] = cnames[[c(1,2)]] 
   	    coltype[i-1] = cnames[[c(1,3)]]    	    
   	}
   	cols = data.frame(ids = colid, names = colname, types = coltype)
    return (cols)
}

ft.describetable <- function (auth, table_name) {
   table_id = ft.idfromtablename(auth, table_name)  
   result = ft.describetablebyid(auth, table_id)
   return (result)
}

ft.idfromtablename <- function(auth, table_name) {
    tables = ft.showtables(auth)
	tableid = tables$ids[tables$names == table_name]
	return (tableid)
}

ft.importdata <- function(auth, table_name) {
	tableid = ft.idfromtablename(auth, table_name)
	columns = ft.describetablebyid(auth, tableid)
	column_spec = ""
	for (i in 1:length(columns)) {
		column_spec = paste(column_spec, columns[i, 2])
		if (i < length(columns)) {
			column_spec = paste(column_spec, ",", sep="")
		}
	}
	mdata = matrix(columns$names,
	              nrow = 1, ncol = length(columns), 
	              dimnames(list(c("dummy"), columns$names)), byrow=TRUE) 
	select = paste("SELECT", column_spec)
	select = paste(select, "FROM")
	select = paste(select, tableid)
	result = ft.executestatement(auth, select)
    numcols = length(columns)
    rows = strsplit(result, "\n")
    for (i in 3:length(rows[[1]])) { 
    	row = strsplit(rows[[c(1,i)]], ",")
    	mdata = rbind(mdata, row[[1]])
   	}
   	output.frame = data.frame(mdata[2:length(mdata[,1]), 1])
   	for (i in 2:ncol(mdata)) {
   		output.frame = cbind(output.frame, mdata[2:length(mdata[,i]),i])
   	}	
   	colnames(output.frame) = columns$names
    return (output.frame)   
}

quote_value <- function(value, to_quote = FALSE, quote = "'") {
	 ret_value = ""
     if (to_quote) {
     	ret_value = paste(quote, paste(value, quote, sep=""), sep="")
     } else {
     	ret_value = value
     }
     return (ret_value)
}

converttostring <- function(arr, separator = ", ", column_types) {
	con_string = ""
	for (i in 1:(length(arr) - 1)) {
		value = quote_value(arr[i], column_types[i] != "number")
		con_string = paste(con_string, value)	
	    con_string = paste(con_string, separator, sep="")
	}
	
    if (length(arr) >= 1) {
    	value = quote_value(arr[length(arr)], column_types[length(arr)] != "NUMBER")
    	con_string = paste(con_string, value)
    }
}	 

ft.exportdata <- function(auth, input_frame, table_name, create_table) {
	if (create_table) {
       create.table = "CREATE TABLE "
       create.table = paste(create.table, table_name)
       create.table = paste(create.table, "(")
       cnames = colnames(input_frame)
       for (columnname in cnames) {
         create.table = paste(create.table, columnname)
    	 create.table = paste(create.table, ":string", sep="")
    	   if (columnname != cnames[length(cnames)]){
    		  create.table = paste(create.table, ",", sep="")
           }
       }
      create.table = paste(create.table, ")")
      result = ft.executestatement(auth, create.table)
    }
    if (length(input_frame[,1]) > 0) {
    	tableid = ft.idfromtablename(auth, table_name)
	    columns = ft.describetablebyid(auth, tableid)
	    column_spec = ""
	    for (i in 1:length(columns$names)) {
		   column_spec = paste(column_spec, columns[i, 2])
		   if (i < length(columns$names)) {
			  column_spec = paste(column_spec, ",", sep="")
		   }
	    }    	
    	insert_prefix = "INSERT INTO "
    	insert_prefix = paste(insert_prefix, tableid)
    	insert_prefix = paste(insert_prefix, "(")
    	insert_prefix = paste(insert_prefix, column_spec)
    	insert_prefix = paste(insert_prefix, ") values (")
    	insert_suffix = ");"
    	insert_sql_big = ""
    	for (i in 1:length(input_frame[,1])) {
    		data = unlist(input_frame[i,])
    		values = converttostring(data, column_types  = columns$types)
    		insert_sql = paste(insert_prefix, values)
    		insert_sql = paste(insert_sql, insert_suffix) ;
    		insert_sql_big = paste(insert_sql_big, insert_sql)
    		if (i %% 500 == 0) {
    			ft.executestatement(auth, insert_sql_big)
    			insert_sql_big = ""
    		}   
    	}
        ft.executestatement(auth, insert_sql_big)
    }	 
}

updateFT <- function(auth, table_id, name, data) {
  sql <- paste('SELECT ROWID from', table_id)
  sql <- paste(sql, " WHERE Name = '", name, sep='')
  sql <- paste(sql, "'", sep='')
  ret <- ft.executestatement(auth, sql)
  row.id <- strsplit(ret, '\n')[[1]][2]
  print(row.id)
  
  sql <- paste('UPDATE', table_id)
  sql <- paste(sql, "SET Data = '")
  sql <- paste(sql, paste(data, collapse=','), sep='')
  sql <- paste(sql, "' WHERE rowid='", sep='')
  sql <- paste(sql, row.id, sep = '')
  sql <- paste(sql, "'", sep = '')
  ft.executestatement(auth, sql)


}
