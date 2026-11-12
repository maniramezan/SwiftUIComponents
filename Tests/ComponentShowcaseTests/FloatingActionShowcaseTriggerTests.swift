import Testing

@testable import ComponentShowcase

@Suite("Floating action showcase trigger")
struct FloatingActionShowcaseTriggerTests {
    @Test("menu opener keeps its configured title and icon after selections")
    func fixedTrigger() {
        var trigger = FloatingActionShowcaseTrigger()
        trigger.title = "More items"
        trigger.icon = .more
        trigger.selection = ("First action", "star")
        #expect(trigger.label.title == "More items")
        #expect(trigger.label.symbol == "ellipsis")
        #expect(trigger.selection?.title == "First action")
    }

    @Test("selection mode falls back before selection and follows the latest item")
    func selectedTrigger() {
        var trigger = FloatingActionShowcaseTrigger()
        trigger.showsSelectedAction = true
        #expect(trigger.label.title == "Actions")
        #expect(trigger.label.symbol == "plus")
        trigger.selection = ("First action", "star")
        #expect(trigger.label.title == "First action")
        #expect(trigger.label.symbol == "star")
        trigger.selection = ("Second action", "square")
        #expect(trigger.label.title == "Second action")
        #expect(trigger.label.symbol == "square")
        trigger.showsSelectedAction = false
        #expect(trigger.label.title == "Actions")
        #expect(trigger.label.symbol == "plus")
        trigger.showsSelectedAction = true
        #expect(trigger.label.title == "Second action")
        #expect(trigger.label.symbol == "square")
    }
}
