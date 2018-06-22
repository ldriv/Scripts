;============================================================
; mysql.ahk
;
;   Provides a set of functions to connect and query a mysql database
;============================================================

;============================================================
; The fileinstall command does 2 things.
; 1. When this ahk program is compiled into an exe, fileinstall indicates which files should be embedded inside the exe.
; 2. When the exe version of the program is run, fileinstall extracts the embedded file to the specified folder.
; 
; note: #include files are automatically embedded at compile time, so you don't need to use fileinstall for them.
;============================================================ 

;FileInstall, libmysql.dll, %A_AppData%\libmysql.dll, 1

;============================================================
; Connect to mysql database and return db handle
;
; host = hostname   
; user = username
; password = mypassword
; database = mydatabase
;============================================================ 

dbConnect(host,user,password,database){	


		ExternDir := A_WorkingDir


	hModule := DllCall("LoadLibrary", "Str", "libmySQL.dll")
		
	If (hModule = 0)
	{
		MsgBox 16, MySQL Error 233, Can't load libmySQL.dll from directory %ExternDir%
		ExitApp
	}

	db := DllCall("libmySQL.dll\mysql_init", "UInt", 0)
			
	If (db = 0)
	{
		MsgBox 16, MySQL Error 445, Not enough memory to connect to MySQL
		ExitApp
	}

	connection := DllCall("libmySQL.dll\mysql_real_connect"
			, "UInt", db
			, "Str", host       ; host name
			, "Str", user       ; user name
			, "Str", password   ; password
			, "Str", database   ; database name
			, "UInt", 3306   ; port
			, "UInt", 0   ; unix_socket
			, "UInt", 0)   ; client_flag

	If (connection = 0)
	{
      HandleMySQLError(db, "Cannot connect to database")
		Return
	}

	serverVersion := DllCall("libmySQL.dll\mysql_get_server_info", "UInt", db, "Str")
			
	;MsgBox % "Ping database: " . DllCall("libmySQL.dll\mysql_ping", "UInt", db) . "`nServer version: " . serverVersion

	return db

}

;============================================================
; mysql error handling
;============================================================ 

HandleMySQLError(db, message, query="") {        ; the equal sign means optional
   errorCode := DllCall("libmySQL.dll\mysql_errno", "UInt", db)
   errorStr := DllCall("libmySQL.dll\mysql_error", "UInt", db, "Str")
   MsgBox 16, MySQL Error: %message%, Error %errorCode%: %errorStr%`n`n%query%
	Return
}

;============================================================
; mysql get address
;============================================================ 

GetUIntAtAddress(_addr, _offset)
{
   local addr

   addr := _addr + _offset * 4

   Return *addr + (*(addr + 1) << 8) +  (*(addr + 2) << 16) + (*(addr + 3) << 24)
}

;============================================================
; process query
;============================================================ 

dbQuery(_db, _query)
{
   local resultString, result, requestResult, fieldCount
   local row, lengths, length, fieldPointer, field

	query4error := RegExReplace(_query , "\t", "   ")    ; convert tabs to spaces so error message formatting is legible
   result := DllCall("libmySQL.dll\mysql_query", "UInt", _db , "Str", _query)
			
   If (result != 0) {
      errorMsg = %_query%
		HandleMySQLError(_db, "dbQuery Fail", query4error)
		Return
   }
	
   requestResult := DllCall("libmySQL.dll\mysql_store_result", "UInt", _db)
	
	if (requestResult = 0) {    ; call must have been an insert or delete ... a select would return results to pass back
		return
	}
	
	fieldCount := DllCall("libmySQL.dll\mysql_num_fields", "UInt", requestResult)

   Loop
   {
      row := DllCall("libmySQL.dll\mysql_fetch_row", "UInt", requestResult)
      If (row = 0 || row == "")
         Break

      ; Get a pointer on a table of lengths (unsigned long)
      lengths := DllCall("libmySQL.dll\mysql_fetch_lengths" , "UInt", requestResult)
				
      Loop %fieldCount%
      {
         length := GetUIntAtAddress(lengths, A_Index - 1)
         fieldPointer := GetUIntAtAddress(row, A_Index - 1)
         VarSetCapacity(field, length)
         DllCall("lstrcpy", "Str", field, "UInt", fieldPointer)
         resultString := resultString . field
         If (A_Index < fieldCount)
            resultString := resultString . "|"     ; seperator for fields
      }
      
		resultString := resultString . "`n"          ; seperator for records  

	}

	; remove last newline from resultString
	resultString := RegExReplace(resultString , "`n$", "") 	
	
   Return resultString
}
