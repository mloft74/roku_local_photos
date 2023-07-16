function init()
    print "[MainMenu] init"

    m.registrySection = createObject("roRegistrySection", "rokuLocalPhotos")
    serverIp = m.registrySection.read("serverIp")

    m.serverIpValue = m.top.findNode("serverIpValue")

    m.connectionStatusValue = m.top.findNode("connectionStatusValue")

    setServerIpValue(serverIp)

    m.mainMenuOptions = m.top.findNode("mainMenuOptions")
    m.mainMenuOptions.observeField("itemSelected", "onItemSelected")

    m.top.setFocus(true)
endfunction

function setServerIpValue(serverIp as string)
    print "[MainMenu] setServerIpValue"
    if serverIp <> invalid and serverIp <> "" then
        m.serverIpValue.text = serverIp
    else
        m.serverIpValue.text = "IP not set"
    endif
    m.connectionStatusValue.text = "Untested"
endfunction

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
    endif
endfunction

function startConnectionTask()
    print "[MainMenu] startConnectionTask"
    m.connectionStatusValue.text = "Connecting..."

    m.connectionTask = CreateObject("roSGNode", "CheckConnectionTask")
    m.connectionTask.observeField("message", "listenToMessage")
    m.connectionTask.control = "run"
endfunction

function listenToMessage()
    print "[MainMenu] listenToMessage"
    m.connectionStatusValue.text = m.connectionTask.message
    m.connectionTask.unobserveField("message")
endfunction

function openServerIpDialog()
    print "[MainMenu] openServerIpDialog"
    dialog = createObject("roSGNode", "StandardKeyboardDialog")
    dialog.id = "serverIpDialog"
    dialog.title = "Server IP"
    dialog.buttons = ["Done"]
    if m.registrySection.exists("serverIp")
        serverIp = m.registrySection.read("serverIp")
        if serverIp <> invalid
            dialog.text = serverIp
        endif
    endif

    dialog.observeField("buttonSelected", "saveServerIp")

    m.top.dialog = dialog
endfunction

function saveServerIp()
    print "[MainMenu] saveServerIp"

    serverIp = m.top.dialog.text

    setServerIpValue(serverIp)

    m.registrySection.write("serverIp", serverIp)
    m.registrySection.flush()

    m.top.dialog.unobserveField("buttonSelected")
    m.top.dialog.close = true
endfunction
