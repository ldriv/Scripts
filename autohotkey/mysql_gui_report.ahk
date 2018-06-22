#SingleInstance,force
#persistent 

#Include mysql.ahk 


Gui,Font,norm bold s14 underline,Verdana
Gui,Add,Text,x150 y10 w220 h30,Admin Close Status

Gui,Font,norm s12,Verdana
Gui,Add,Groupbox,x20 y50 w460 h160,Processes

Gui,Add,Text,x40 y70 w120 h20,Post Delivery:
Gui,Add,Picture,x170 y70 w20 h20,C:\Users\ldr\Dropbox\scripts\SmartGui\Grey.png

Gui,Add,Text,x30 y100 w130 h20,Firewall Status:
Gui,Add,Picture,x170 y100 w20 h20,C:\Users\ldr\Dropbox\scripts\SmartGui\Grey.png
Gui,Font


Gui,Show,x702 y271 w501 h341 ,

db := dbConnect("server","user","pw","database")     

settimer, checkstatus , 1000
Return


checkstatus:
settimer, checkstatus, off


sql = 
(
select Store_n,name,flag from close_step
)

result := dbQuery(db, sql)

loop , parse,  result, `n
{
	stringsplit , data , a_loopfield , |
	if data2 = Firewall Status
	{
		if data3 = 0
			changecolor("red","Static4")
		if data3 = 1
			changecolor("green","Static4")
	}
	if data2 = Post Delivery
	{
		if data3 = 0
			changecolor("red","Static2")
		if data3 = 1
			changecolor("green","Static2")
	}
}   
    
settimer, checkstatus, on
return
    
changecolor(color,cname)
{   
	Gui , font , norm s12 c%color%, Verdana
	GuiControl , Font , %cname%
	Gui, font , Default
}
Return
