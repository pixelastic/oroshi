choices = ["konqueror", "firefox", "chrome"]
retCode, choice = dialog.list_menu(choices)
if retCode == 0:
  system.exec_command(choice + " " + clipboard.get_selection())