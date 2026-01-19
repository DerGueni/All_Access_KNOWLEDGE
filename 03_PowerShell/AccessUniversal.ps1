# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
# ACCESS BRIDGE UNIVERSAL v2.0 - FÃ¼r Claude AI
# Vollautomatischer Zugriff auf geÃ¶ffnetes Access Frontend
# ALLE Dialoge unterdrÃ¼ckt - Keine manuellen Eingriffe nÃ¶tig
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

param(
    [string]$Action = "test",
    [string]$Query = "",
    [string]$Table = "",
    [string]$Module = "",
    [string]$Code = "",
    [string]$Form = "",
    [hashtable]$Data = @{},
    [string]$VBAFunction = "",
    $VBAArgs = $null,
    [switch]$NoCleanup
)

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
# GLOBALE KONFIGURATION
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

# UTF-8 Encoding erzwingen
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# Kultur fÃ¼r Datumsformate (US-Format fÃ¼r Access)
$script:USCulture = [System.Globalization.CultureInfo]::InvariantCulture

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
# HILFSFUNKTIONEN
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

function Format-DateUS {
    param([datetime]$Date = (Get-Date))
    return $Date.ToString("MM/dd/yyyy", $script:USCulture)
}

function Format-DateTimeUS {
    param([datetime]$Date = (Get-Date))
    return $Date.ToString("MM/dd/yyyy HH:mm:ss", $script:USCulture)
}

function Format-TimeUS {
    param([datetime]$Time = (Get-Date))
    return $Time.ToString("HH:mm:ss", $script:USCulture)
}

function Format-SQLValue {
    param($Value)
    
    if ($null -eq $Value) { return "NULL" }
    
    switch ($Value.GetType().Name) {
        "String"   { return "'$($Value -replace "'", "''")'" }
        "DateTime" { return "#$(Format-DateTimeUS $Value)#" }
        "Boolean"  { return if ($Value) { "True" } else { "False" } }
        "Int32"    { return $Value }
        "Int64"    { return $Value }
        "Double"   { return $Value.ToString($script:USCulture) }
        "Decimal"  { return $Value.ToString($script:USCulture) }
        default    { return "'$($Value.ToString() -replace "'", "''")'" }
    }
}

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
# ACCESS-VERBINDUNG MIT VOLLSTÃ„NDIGER DIALOG-UNTERDRÃœCKUNG
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

function Get-AccessApp {
    param([switch]$SuppressAllDialogs = $true)
    
    try {
        $app = [System.Runtime.InteropServices.Marshal]::GetActiveObject("Access.Application")
        
        if ($SuppressAllDialogs) {
            # ALLE Warnungen/Dialoge deaktivieren
            $app.DoCmd.SetWarnings($false)
            
            # AutoExec deaktivieren (falls nÃ¶tig)
            # $app.SetOption("Confirm Action Queries", $false)
            # $app.SetOption("Confirm Document Deletions", $false)
            # $app.SetOption("Confirm Record Changes", $false)
        }
        
        return $app
    } catch {
        throw "Access nicht geÃ¶ffnet oder nicht erreichbar: $_"
    }
}

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
# SQL-OPERATIONEN
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

function Invoke-SQL {
    param(
        [string]$SQL, 
        [bool]$ReturnData = $true,
        [int]$MaxRetries = 3
    )
    
    $app = Get-AccessApp
    $db = $app.CurrentDb()
    
    for ($retry = 0; $retry -lt $MaxRetries; $retry++) {
        try {
            if ($ReturnData -and $SQL -match "^\s*SELECT") {
                $rs = $db.OpenRecordset($SQL)
                $results = @()
                
                while (-not $rs.EOF) {
                    $row = @{}
                    for ($i = 0; $i -lt $rs.Fields.Count; $i++) {
                        $fieldName = $rs.Fields($i).Name
                        $fieldValue = $rs.Fields($i).Value
                        
                        # DateTime korrekt konvertieren
                        if ($fieldValue -is [DateTime]) {
                            $row[$fieldName] = $fieldValue.ToString("yyyy-MM-dd HH:mm:ss")
                        } else {
                            $row[$fieldName] = $fieldValue
                        }
                    }
                    $results += [PSCustomObject]$row
                    $rs.MoveNext()
                }
                $rs.Close()
                return $results
            } else {
                $db.Execute($SQL, 128) # 128 = dbFailOnError
                return @{ Success = $true; RecordsAffected = $db.RecordsAffected }
            }
        } catch {
            if ($retry -eq $MaxRetries - 1) { throw $_ }
            Start-Sleep -Milliseconds 100
        }
    }
}

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
# VBA-MODUL-OPERATIONEN (Dialog-frei)
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

function Get-VBAModule {
    param([string]$ModuleName)
    
    $app = Get-AccessApp
    $comp = $app.VBE.ActiveVBProject.VBComponents.Item($ModuleName)
    return $comp.CodeModule.Lines(1, $comp.CodeModule.CountOfLines)
}

function Set-VBAModule {
    param(
        [string]$ModuleName, 
        [string]$Code, 
        [bool]$Replace = $true,
        [bool]$AutoSave = $true
    )
    
    $app = Get-AccessApp
    $vbProj = $app.VBE.ActiveVBProject
    
    # Warnungen aus
    $app.DoCmd.SetWarnings($false)
    
    try {
        $comp = $vbProj.VBComponents.Item($ModuleName)
        if ($Replace -and $comp.CodeModule.CountOfLines -gt 0) {
            $comp.CodeModule.DeleteLines(1, $comp.CodeModule.CountOfLines)
        }
        $comp.CodeModule.AddFromString($Code)
    } catch {
        # Modul existiert nicht - neu erstellen
        $comp = $vbProj.VBComponents.Add(1) # 1 = vbext_ct_StdModule
        $comp.Name = $ModuleName
        $comp.CodeModule.AddFromString($Code)
    }
    
    # Automatisch speichern (OHNE Dialog!)
    if ($AutoSave) {
        try {
            # DoCmd.Save funktioniert fÃ¼r Module
            $app.DoCmd.Save(5, $ModuleName) # 5 = acModule
        } catch {
            # Ignorieren - manche Module speichern sich automatisch
        }
    }
    
    return @{ Success = $true; Module = $ModuleName }
}

function Remove-VBAModule {
    param([string]$ModuleName)
    
    $app = Get-AccessApp
    $app.DoCmd.SetWarnings($false)
    
    try {
        $comp = $app.VBE.ActiveVBProject.VBComponents.Item($ModuleName)
        $app.VBE.ActiveVBProject.VBComponents.Remove($comp)
        return @{ Success = $true; Removed = $ModuleName }
    } catch {
        return @{ Success = $false; Error = $_.Exception.Message }
    }
}

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
# VBA-FUNKTIONEN AUSFÃœHREN
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

function Invoke-VBAFunction {
    param(
        [string]$FuncName, 
        $Args = $null
    )
    
    $app = Get-AccessApp
    
    if ($null -eq $Args) {
        return $app.Run($FuncName)
    } elseif ($Args -is [array]) {
        switch ($Args.Count) {
            0 { return $app.Run($FuncName) }
            1 { return $app.Run($FuncName, $Args[0]) }
            2 { return $app.Run($FuncName, $Args[0], $Args[1]) }
            3 { return $app.Run($FuncName, $Args[0], $Args[1], $Args[2]) }
            4 { return $app.Run($FuncName, $Args[0], $Args[1], $Args[2], $Args[3]) }
            5 { return $app.Run($FuncName, $Args[0], $Args[1], $Args[2], $Args[3], $Args[4]) }
            default { throw "Max 5 Argumente unterstÃ¼tzt" }
        }
    } else {
        return $app.Run($FuncName, $Args)
    }
}

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
# FORMULAR-OPERATIONEN (Dialog-frei)
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

function Open-AccessForm {
    param(
        [string]$FormName, 
        [int]$View = 0,      # 0=Normal, 1=Design, 2=Vorschau, 5=Datenblatt
        [string]$Filter = "",
        [string]$WhereCondition = ""
    )
    
    $app = Get-AccessApp
    $app.DoCmd.SetWarnings($false)
    
    if ($WhereCondition) {
        $app.DoCmd.OpenForm($FormName, $View, "", $WhereCondition)
    } elseif ($Filter) {
        $app.DoCmd.OpenForm($FormName, $View, $Filter)
    } else {
        $app.DoCmd.OpenForm($FormName, $View)
    }
    
    return @{ Success = $true; Form = $FormName; View = $View }
}

function Close-AccessForm {
    param(
        [string]$FormName,
        [int]$Save = 0  # 0=acSaveNo, 1=acSaveYes, 2=acSavePrompt
    )
    
    $app = Get-AccessApp
    $app.DoCmd.SetWarnings($false)
    $app.DoCmd.Close(2, $FormName, $Save) # 2 = acForm
    
    return @{ Success = $true; Closed = $FormName }
}

function Save-AccessObject {
    param(
        [string]$ObjectName,
        [int]$ObjectType = 2  # 2=acForm, 1=acTable, 4=acReport, 5=acModule, 6=acMacro
    )
    
    $app = Get-AccessApp
    $app.DoCmd.SetWarnings($false)
    
    try {
        $app.DoCmd.Save($ObjectType, $ObjectName)
        return @{ Success = $true; Saved = $ObjectName }
    } catch {
        return @{ Success = $false; Error = $_.Exception.Message }
    }
}

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
# INSERT MIT KORREKTER DATUMSFORMATIERUNG
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

function Insert-Record {
    param(
        [string]$TableName, 
        [hashtable]$Data,
        [switch]$ReturnID
    )
    
    $fields = ($Data.Keys -join ", ")
    $values = ($Data.Values | ForEach-Object { Format-SQLValue $_ }) -join ", "
    
    $sql = "INSERT INTO [$TableName] ($fields) VALUES ($values)"
    $result = Invoke-SQL -SQL $sql -ReturnData $false
    
    if ($ReturnID) {
        $rs = (Get-AccessApp).CurrentDb().OpenRecordset("SELECT @@IDENTITY AS NewID")
        $newID = $rs.Fields("NewID").Value
        $rs.Close()
        $result.NewID = $newID
    }
    
    return $result
}

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
# DATENBANK-SPEICHERUNG (Dialog-frei)
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

function Save-Database {
    param([switch]$CompactAfter)
    
    $app = Get-AccessApp
    $app.DoCmd.SetWarnings($false)
    
    # Alle offenen Objekte speichern
    try {
        $app.DoCmd.RunCommand(3) # acCmdSaveRecord
    } catch { }
    
    # Datenbank-Eigenschaften aktualisieren
    try {
        $app.CurrentDb().Properties.Refresh()
    } catch { }
    
    return @{ Success = $true; Message = "Database saved" }
}

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
# HAUPTLOGIK
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

try {
    switch ($Action.ToLower()) {
        
        "test" {
            $app = Get-AccessApp
            $db = $app.CurrentDb()
            [PSCustomObject]@{
                Status = "SUCCESS"
                Database = $db.Name
                Tables = $db.TableDefs.Count
                Queries = $db.QueryDefs.Count
                VBAModules = $app.VBE.ActiveVBProject.VBComponents.Count
                DialogsDisabled = $true
            } | ConvertTo-Json
        }
        
        "sql" {
            if (-not $Query) { throw "Query erforderlich fÃ¼r Action=sql" }
            $result = Invoke-SQL -SQL $Query
            $result | ConvertTo-Json -Depth 10
        }
        
        "vba" {
            if ($VBAFunction) {
                # Direkte COM-AusfÃ¼hrung fÃ¼r zuverlÃ¤ssige Argument-Ãœbergabe
                $app = Get-AccessApp
                if ($null -eq $VBAArgs -or ($VBAArgs -is [array] -and $VBAArgs.Count -eq 0)) {
                    $result = $app.Run($VBAFunction)
                } elseif ($VBAArgs -is [array]) {
                    switch ($VBAArgs.Count) {
                        1 { $result = $app.Run($VBAFunction, $VBAArgs[0]) }
                        2 { $result = $app.Run($VBAFunction, $VBAArgs[0], $VBAArgs[1]) }
                        3 { $result = $app.Run($VBAFunction, $VBAArgs[0], $VBAArgs[1], $VBAArgs[2]) }
                        default { $result = $app.Run($VBAFunction, $VBAArgs[0]) }
                    }
                } else {
                    $result = $app.Run($VBAFunction, $VBAArgs)
                }
                [PSCustomObject]@{ Function = $VBAFunction; Result = $result } | ConvertTo-Json
            } elseif ($Module -and $Code) {
                Set-VBAModule -ModuleName $Module -Code $Code -Replace $true | ConvertTo-Json
            } elseif ($Module) {
                Get-VBAModule -ModuleName $Module
            } else {
                throw "VBA: Module oder VBAFunction erforderlich"
            }
        }
        
        "form" {
            if (-not $Form) { throw "Form erforderlich" }
            Open-AccessForm -FormName $Form | ConvertTo-Json
        }
        
        "form-close" {
            if (-not $Form) { throw "Form erforderlich" }
            Close-AccessForm -FormName $Form -Save 0 | ConvertTo-Json
        }
        
        "module" {
            if (-not $Module) { throw "Module erforderlich" }
            if ($Code) {
                Set-VBAModule -ModuleName $Module -Code $Code -Replace $true | ConvertTo-Json
            } else {
                Get-VBAModule -ModuleName $Module
            }
        }
        
        "module-delete" {
            if (-not $Module) { throw "Module erforderlich" }
            Remove-VBAModule -ModuleName $Module | ConvertTo-Json
        }
        
        "insert" {
            if (-not $Table -or $Data.Count -eq 0) { 
                throw "Table und Data erforderlich" 
            }
            Insert-Record -TableName $Table -Data $Data -ReturnID | ConvertTo-Json
        }
        
        "save" {
            Save-Database | ConvertTo-Json
        }
        
        "save-object" {
            if (-not $Form -and -not $Module) { throw "Form oder Module erforderlich" }
            if ($Form) {
                Save-AccessObject -ObjectName $Form -ObjectType 2 | ConvertTo-Json
            } else {
                Save-AccessObject -ObjectName $Module -ObjectType 5 | ConvertTo-Json
            }
        }
        
        "list-modules" {
            $app = Get-AccessApp
            $app.VBE.ActiveVBProject.VBComponents | ForEach-Object {
                [PSCustomObject]@{
                    Name = $_.Name
                    Type = switch ($_.Type) { 
                        1 {"Module"} 
                        2 {"Class"} 
                        3 {"UserForm"} 
                        100 {"Document"} 
                        default {$_.Type} 
                    }
                    Lines = $_.CodeModule.CountOfLines
                }
            } | ConvertTo-Json
        }
        
        "list-tables" {
            $app = Get-AccessApp
            $app.CurrentDb().TableDefs | 
                Where-Object { -not $_.Name.StartsWith("MSys") -and -not $_.Name.StartsWith("~") } | 
                ForEach-Object {
                    [PSCustomObject]@{
                        Name = $_.Name
                        Records = $_.RecordCount
                        Fields = $_.Fields.Count
                    }
                } | ConvertTo-Json
        }
        
        "list-forms" {
            $app = Get-AccessApp
            $app.CurrentProject.AllForms | ForEach-Object {
                [PSCustomObject]@{
                    Name = $_.Name
                    IsLoaded = $_.IsLoaded
                }
            } | ConvertTo-Json
        }
        
        "eval" {
            if (-not $Query) { throw "Query erforderlich (Access-Ausdruck)" }
            $app = Get-AccessApp
            $result = $app.Eval($Query)
            [PSCustomObject]@{ Expression = $Query; Result = $result } | ConvertTo-Json
        }
        
        "create-form" {
            # Formular mit optionalen Buttons erstellen
            # -Form "FormName" -Data @{Buttons=@("Btn1","Btn2"); Caption="Titel"}
            if (-not $Form) { throw "Form-Name erforderlich" }
            
            $app = Get-AccessApp
            $app.DoCmd.SetWarnings($false)
            
            # Altes Formular lÃ¶schen falls vorhanden
            try { $app.DoCmd.Close(2, $Form, 0) } catch {}
            try { $app.DoCmd.DeleteObject(2, $Form) } catch {}
            
            # Neues Formular erstellen
            $frm = $app.CreateForm()
            $tempName = $frm.Name
            
            # Buttons hinzufÃ¼gen falls angegeben
            if ($Data -and $Data.Buttons) {
                $topPos = 300
                foreach ($btnName in $Data.Buttons) {
                    $btn = $app.CreateControl($tempName, 104, 0, "", "", 500, $topPos, 2000, 400)
                    $btn.Name = $btnName
                    $btn.Caption = $btnName
                    $topPos += 600
                }
            }
            
            # Caption setzen falls angegeben
            if ($Data -and $Data.Caption) {
                $frm.Caption = $Data.Caption
            } else {
                $frm.Caption = $Form
            }
            
            # Speichern und umbenennen
            $app.DoCmd.Save(2, $tempName)
            $app.DoCmd.Close(2, $tempName, 1)
            $app.DoCmd.Rename($Form, 2, $tempName)
            
            [PSCustomObject]@{
                Success = $true
                Form = $Form
                Buttons = $Data.Buttons
            } | ConvertTo-Json
        }
        
        "delete-form" {
            if (-not $Form) { throw "Form-Name erforderlich" }
            $app = Get-AccessApp
            $app.DoCmd.SetWarnings($false)
            try { $app.DoCmd.Close(2, $Form, 0) } catch {}
            $app.DoCmd.DeleteObject(2, $Form)
            [PSCustomObject]@{ Success = $true; Deleted = $Form } | ConvertTo-Json
        }
        
        default {
            throw "Unbekannte Action: $Action. VerfÃ¼gbar: test, sql, vba, form, form-close, module, module-delete, insert, save, save-object, list-modules, list-tables, list-forms, eval"
        }
    }
} catch {
    [PSCustomObject]@{
        Error = $true
        Message = $_.Exception.Message
        Action = $Action
    } | ConvertTo-Json
    exit 1
}

