function init()
    print "[MainMenu] init"

    m.serverIpValue = m.top.findNode("serverIpValue")
    m.serverIpValue.text = "random text"

    m.mainMenuOptions = m.top.findNode("mainMenuOptions")
    m.mainMenuOptions.observeField("itemSelected", "settext")

    m.top.setFocus(true)
end function

function settext()
    print "[MainMenu] setText"
    m.serverIpValue.text = m.mainMenuOptions.content.getChild(m.mainMenuOptions.itemSelected).title
end function
