struct FloatingActionShowcaseTrigger {
    var title = "Actions"
    var icon = FloatingActionIcon.plus
    var showsSelectedAction = false
    var selection: (title: String, symbol: String)?

    var label: (title: String, symbol: String) {
        if showsSelectedAction, let selection {
            return selection
        }
        return (title, icon.rawValue)
    }
}
