suppressMessages(library(RCurl))

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

ft.executestatement <- function(auth, api_key, statement) {
      url = "http://tables.googlelabs.com/api/query"
      params = list( sql = statement, key = api_key)
      connection.string = paste("GoogleLogin auth=", auth, sep="")
      opts = list( httpheader = c("Authorization" = connection.string))
      result = postForm(uri = url, .params = params, .opts = opts) 
      if (length(grep("<HTML>\n<HEAD>\n<TITLE>Parse error", result, ignore.case = TRUE))) {
      	stop(paste("incorrect sql statement:", statement)) 
      }
      return (result)  
}
updateFT <- function(auth, api_key, table_id, name, data, column='Data') {
  sql <- paste('SELECT ROWID from', table_id)
  sql <- paste(sql, " WHERE Name = '", name, sep='')
  sql <- paste(sql, "'", sep='')
  ret <- ft.executestatement(auth, api_key, sql)
  row.id <- strsplit(ret, '\n')[[1]][2]
  print(row.id)
  
  sql <- paste('UPDATE', table_id)
  sql <- paste(sql, "SET", column, " = '")
  sql <- paste(sql, paste(data, collapse=','), sep='')
  sql <- paste(sql, "' WHERE rowid='", sep='')
  sql <- paste(sql, row.id, sep = '')
  sql <- paste(sql, "'", sep = '')
  ft.executestatement(auth, api_key, sql)
  
  
}
