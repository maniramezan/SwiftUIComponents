# Building a questionnaire

Choose an answer kind separately from its visual presentation. A
``QuestionnaireQuestionKind/singleChoice(options:)`` question accepts one option;
``QuestionnaireQuestionKind/multipleChoice(options:)`` accepts any number. The default
presentation places each option on its own line, using bullets for single choice and
checkmarks for multiple choice. ``QuestionnaireChoiceStyle/chips`` keeps compact tagging
available when appropriate. Titles, prompts, details, placeholders, units, and boolean
choice titles are caller-supplied and must already be localized.

Set `choiceStyle: .chips` on questions that should use wrapping tags. Otherwise, the
default presentation uses separate rows.

## Open and binary responses

Use ``QuestionnaireQuestionKind/text(placeholder:)`` for free-form, multiline answers.
Whitespace-only text is unanswered; surrounding whitespace is trimmed on submission.
Use ``QuestionnaireQuestionKind/boolean(trueTitle:falseTitle:)`` for explicit binary
responses. Unlike a switch that starts off, this input starts unanswered. Selecting
`false` is a complete response, including for required questions.

Numeric answers use the shared ``NumericInput`` filter: typed and pasted text keeps decimal
digits and one separator from the environment locale. A leading minus is allowed when the
question's range includes negative values. Letters, grouping separators, and unrelated symbols
are removed. Clearing the field leaves the answer absent; range clamping and step snapping
still happen on submission. Existing negative answers retain their sign until submission,
including when the range is nonnegative.

## Custom component example

The showcase's **Custom component example** embeds a caller-owned graphical `DatePicker`
in the same prompt, progress, and navigation shell. The ordinary date kind remains
available when the built-in calendar behavior is sufficient.

```swift
QuestionnaireView(
    questions: [
        QuestionnaireQuestion(
            id: "custom-date",
            prompt: "Which date do you prefer?",
            isRequired: true,
            kind: .custom
        )
    ],
    answers: $answers,
    customInput: { question, answer in
        CustomCalendarInput(title: question.prompt, answer: answer)
    },
    onSubmit: { submitted in save(submitted) }
)
```

`CustomCalendarInput` is a caller-defined view accepting `Binding<QuestionnaireAnswer?>`.
It records `.date(selectedDate)` when a valid date is selected or confirmed, and `nil`
while incomplete. Custom inputs can use any answer case. The questionnaire trims text,
deduplicates choice identifiers in supplied order, and rejects non-finite numbers and
dates. Domain-specific constraints and accessibility belong to the custom input.

The builder runs only for custom questions. Without a builder, custom questions are
dropped with a logged fault. Required custom questions block navigation while their
answer is absent or invalid; `false` and zero remain valid answers.

## Additional formats to consider

Common survey platforms distinguish these formats beyond basic choice and text inputs:

| Format | Composition or remaining work |
| --- | --- |
| Labeled rating or Likert scale | Use single choice with stable IDs and balanced labels, as in the rating showcase. |
| Slider or visual star rating | Supply a custom input recording `.number`; enforce range and step in that input. |
| Dropdown or searchable choice | Supply a custom picker recording `.choices`; validate against its allowed options. |
| Ranking | A custom reorderable list can record `.choices` in ranked order; built-in multiple choice preserves option order. |
| Matrix | Prefer separate labeled questions on narrow screens; a custom matrix needs its own structured encoding. |
| Other with explanation | Compose a choice and a text question; conditional display and dependent-answer cleanup remain caller responsibilities. |
| Selection limits and exclusive options | Not built into multiple choice; use a custom input to enforce minimum/maximum counts or a mutually exclusive option. |
| Attachments, signatures, media | Supply custom content and record a stable reference; storage and upload lifecycle belong to the caller. |
| Conditional follow-ups, review, resume | Keep visibility, branching, persistence, and a review screen in the caller's flow. |

Question identifiers must remain stable and unique. Submission includes only normalized
answers to the currently supplied questions and rechecks every required answer. Changing
the question list does not implement dependency tracking or conditional routing.

## References

- [SurveyMonkey question types](https://help.surveymonkey.com/en/surveymonkey/create/question-types/)
- [Typeform question types](https://help.typeform.com/hc/en-us/articles/360051789692-Question-types)
- [Apple: Picker](https://developer.apple.com/documentation/swiftui/picker)
- [Apple: DatePicker](https://developer.apple.com/documentation/swiftui/datepicker)
- [Apple: multiline TextField](https://developer.apple.com/documentation/swiftui/textfield/init(_:text:axis:))
- [Swift Forums: separating validation from UI](https://forums.swift.org/t/validator-a-modular-type-safe-validation-framework-for-swiftui-and-uikit/84074)
