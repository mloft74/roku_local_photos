function init()
    print "[MainMenu] init"

    m.registrySection = createObject("roRegistrySection", "rokuLocalPhotos")
    serverIp = m.registrySection.read("serverIp")

    m.serverIpValue = m.top.findNode("serverIpValue")
    setServerIpValue(serverIp)

    m.connectionStatusLabel = m.top.findNode("connectionStatusLabel")
    m.connectionStatusValue = m.top.findNode("connectionStatusValue")

    m.mainMenuOptions = m.top.findNode("mainMenuOptions")
    m.mainMenuOptions.observeField("itemSelected", "onItemSelected")

    m.top.setFocus(true)
end function

function setServerIpValue(serverIp as string)
    print "[MainMenu] setServerIpValue"
    if serverIp <> invalid and serverIp <> "" then
        m.serverIpValue.text = serverIp
    else
        m.serverIpValue.text = "IP not set"
    end if
end function

function onItemSelected()
    print "[MainMenu] onItemSelected"
    index = m.mainMenuOptions.itemSelected
    if index = 0 then
        startConnectionTask()
    else if index = 1 then
        openServerIpDialog()
    else
        unknownOptionTitle = m.mainMenuOptions.content.getChild(index).title
        print "unhandled option: " + unknownOptionTitle
    end if
end function

function startConnectionTask()
    print "[MainMenu] startConnectionTask"
    m.connectionStatusLabel.text = "Connection status:"
    m.connectionStatusValue.text = "Connecting..."

    m.connectionTask = CreateObject("roSGNode", "CheckConnectionTask")
    m.connectionTask.observeField("message", "listenToMessage")
    m.connectionTask.control = "run"
end function

function listenToMessage()
    print "[MainMenu] listenToMessage"
    m.connectionStatusValue.text = m.connectionTask.message
    m.connectionTask.unobserveField("message")
end function

function openServerIpDialog()
    print "[MainMenu] openServerIpDialog"
    dialog = createObject("roSGNode", "StandardKeyboardDialog")
    dialog.id = "serverIpDialog"
    dialog.title = "Server IP"
    dialog.buttons = ["Done"]

    dialog.observeField("buttonSelected", "saveServerIp")

    m.top.dialog = dialog
end function

function saveServerIp()
    print "[MainMenu] saveServerIp"

    serverIp = m.top.dialog.text

    setServerIpValue(serverIp)

    m.registrySection.write("serverIp", serverIp)
    m.registrySection.flush()

    m.top.dialog.unobserveField("buttonSelected")
    m.top.dialog.close = true
end function
