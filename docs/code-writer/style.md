# return early

- I don't like nested if/else
- I prefer a function or a loop that return/continue/break quickly
- It gets the simple case out of the way quickly, and continue with the complex path

# lint / format

- Code written should be checked through a linter
- It will find issues and fix formatting

# TDD

- Before writing any code, we should have a failing test for the feature
- This will ensure we actually implement the right thing

# Comments

- I like comments that show parameters/arguments for methods
- I like comments that explain concisely the flow if complex
- I like comments that give examples of the shape of the input if it's not obvious

# Variables

- I like camelCase for variables (not kebab, not underscore)
- I like to put complex boolean conditions in named variables so the condition
is easier to read
```zsh
local isAllLower
[[ "$word" == "$lowerWord" ]] && isAllLower=1 || isAllLower=0
if [[ "$isAllLower" == "1" ]]; then
    # Do stuff
fi
```
