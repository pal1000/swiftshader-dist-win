$gitData = ConvertFrom-StringData (git log -1 --format=format:"commitId=%H%nmessage=%s%ncommitted=%aD" | out-string)
Update-AppveyorBuild @gitData