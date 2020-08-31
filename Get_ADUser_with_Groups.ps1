###########################################################################
######################## Made by Hannes Kreische aka FFx25
###########################################################################

###################################################Deactivate error action interrupts
#Save them for later
$save_error_action_before = $ErrorActionPreference
$ErrorActionPreference = "SilentlyContinue"

###################################################Select needed information
#Select the names from the employes
$AD_User_Names = Get-ADUser -Filter * | Select-Object Name

#Select loginnames from the employes
$AD_User_Logins = Get-ADUser -Filter * -Properties * | Select-Object SAMAccountName

#Select the state enabled/disabled
$AD_User_state = Get-ADUser -Filter * -Properties * | Select-Object enabled

#Select given loginscripts
$AD_User_Loginscript = Get-ADUser -Filter * -Properties Scriptpath | Select-Object Scriptpath

#Select all the groups
$AD_User_Groups = Get-ADGroup -Filter * | Select-Object Name

###################################################Create custom table
#Create custom table
$AD_Table = New-Object System.Data.DataTable "AD_Documentation"

#Create columns
$coloumn1 = New-Object System.Data.DataColumn AD_Names
$coloumn2 = New-Object System.Data.DataColumn AD_Logins
$coloumn3 = New-Object System.Data.DataColumn AD_Login_State
$coloumn4 = New-Object System.Data.DataColumn AD_Loginscript

#Add Columns
$AD_Table.Columns.Add($coloumn1)
$AD_Table.Columns.Add($coloumn2)
$AD_Table.Columns.Add($coloumn3)
$AD_Table.Columns.Add($coloumn4)


#Define column names
for ($i = 0; $i -le $AD_User_Groups.Count; $i++)
{
    #Add dynamic some more columns for each group
    $coloumni = New-Object System.Data.DataColumn $AD_User_Groups[$i].Name
    $AD_Table.Columns.Add($coloumni)
}

#Fill the rows
for ($i = 0; $i -le $AD_User_Names.Count; $i++)
{
        $row = $AD_Table.NewRow()
        $row.AD_Names = $AD_User_Names[$i].Name
        $row.AD_Logins = $AD_User_Logins[$i].SAMAccountName
        $row.AD_Login_State = $AD_User_state[$i].Enabled
        $row.AD_Loginscript = $AD_User_Loginscript[$i].Scriptpath
        $AD_Table.Rows.Add($row)
}


###################################################Lets get the groups
#if the user is in the right group then write x
#$iterate_current_AD_user
    #Create the list of groups which depends to the AD user
#$iterate_grouplist 
    #Find the matches betwenn AD user groups & the list of all groups
for ($iterate_current_AD_user = 0; $iterate_current_AD_user -le $AD_Table.Columns.Count; $iterate_current_AD_user++)
{
    #Grab the user
    $AD_Name_With_Group = Get-ADPrincipalGroupMembership -Identity $AD_User_Logins[$iterate_current_AD_user].SAMAccountName | Select-Object Name
    #Grab the groups
    for ($iterate_grouplist = 0; $iterate_grouplist -le $AD_User_Groups.Count; $iterate_grouplist++)
    { 
        #Compare the groups of the user with all groups, if its a match print x in the table
        if ($AD_Name_With_Group.name -contains $AD_User_Groups[$iterate_grouplist].name ) 
        {
            $AD_Table.Rows[$iterate_current_AD_user].($AD_User_Groups[$iterate_grouplist].Name) = " X "
        }

    }
}

###################################################Finalize it
#Reset error action preference to the value before
$ErrorActionPreference = $save_error_action_before

#Remove the last row, because we added one to much
$AD_Table.Rows.RemoveAt($AD_Table.Rows.Count-1)

#Remove the last coloumn, becaue we added one to much
$AD_Table.Columns.RemoveAt($AD_Table.Columns.Count-1)

#Save this in a csv file <3
$AD_Table | Export-Csv -Delimiter "," -Path C:\AD_DOKU.TxT