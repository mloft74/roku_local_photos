function Init()
    print "[MainMenu] Init"

    m.registrySection = CreateObject("roRegistrySection", "rokuLocalPhotos")
    serverIp = m.registrySection.Read("serverIp")

    m.serverIpValue = m.top.FindNode("serverIpValue")

    m.connectionStatusValue = m.top.FindNode("connectionStatusValue")

    SetServerIpValue(serverIp)

    m.mainMenuOptions = m.top.FindNode("mainMenuOptions")
    m.mainMenuOptions.ObserveField("itemSelected", "OnItemSelected")

    m.top.SetFocus(true)
end function

function SetServerIpValue(serverIp as string)
    print "[MainMenu] SetServerIpValue"
    if serverIp <> invalid and serverIp <> "" then
        m.serverIpValue.text = serverIp
    else
        m.serverIpValue.text = "IP not set"
    end if
    m.connectionStatusValue.text = "Untested"
end function

function OnItemSelected()
    print "[MainMenu] OnItemSelected"
    index = m.mainMenuOptions.itemSelected
    if index = 0 then
        StartConnectionTask()
    else if index = 1 then
        OpenServerIpDialog()
    else
        unknownOptionTitle = m.mainMenuOptions.content.GetChild(index).title
        print "unhandled option: "; unknownOptionTitle
    end if
end function

function StartConnectionTask()
    print "[MainMenu] StartConnectionTask"
    m.connectionStatusValue.text = "Connecting..."

    m.connectionTask = CreateObject("roSGNode", "CheckConnectionTask")
    m.connectionTask.ObserveField("state", "ListenForConnectionDone")
    m.connectionTask.control = "run"
end function

function ListenForConnectionDone()
    print "[MainMenu] ListenForConnectionDone"
    if m.connectionTask.state <> "done"
        return invalid
    end if
    m.connectionStatusValue.text = m.connectionTask.message
    m.connectionTask.UnobserveField("state")
    m.connectionTask = invalid
end function

function OpenServerIpDialog()
    print "[MainMenu] OpenServerIpDialog"
    dialog = CreateObject("roSGNode", "StandardKeyboardDialog")
    dialog.id = "serverIpDialog"
    dialog.title = "Server IP"
    dialog.buttons = ["Done"]
    if m.registrySection.Exists("serverIp")
        serverIp = m.registrySection.Read("serverIp")
        if serverIp <> invalid
            dialog.text = serverIp
        end if
    end if

    dialog.ObserveField("buttonSelected", "SaveServerIp")

    m.top.dialog = dialog
end function

function SaveServerIp()
    print "[MainMenu] SaveServerIp"

    serverIp = m.top.dialog.text

    SetServerIpValue(serverIp)

    m.registrySection.Write("serverIp", serverIp)
    m.registrySection.Flush()

    m.top.dialog.UnobserveField("buttonSelected")
    m.top.dialog.close = true
end function
