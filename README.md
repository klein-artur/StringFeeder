# StringFeeder: Enhance Strings with Custom Scripting Features

Welcome to StringFeeder! This tool empowers your strings with the ability to interpret small and straightforward placeholder scripts. You can leverage this for scenarios where users need to define a string template to be populated and modified with given parameters, using a simple script-like language.

## Sample Usage

Here's an example of how your application might provide these parameters:

```swift
some_int: 12
some_boolean: true
some_string: "Hello World"
some_converter: { (inputString) throws -> String in }
```

Now, users can craft a string by incorporating these placeholders:

```swift
The int value of this is $some_int, the boolean is $some_boolean("correct"; "not correct") and I just want to say $some_string.
```

This would result in:

```swift
The int value of this is 12, the boolean is correct and I just want to say Hello World.
```

## Placeholder Types

StringFeeder supports a variety of placeholders:

- `$some_var`: Substitutes the value of the corresponding variable. For boolean values, it will be "true" or "false".
- `$some_bool("true text"; "false text")`: Applicable only to boolean variables. Replaces this placeholder with either "true text" or "false text".
- `$some_converter("converter input")`: Converts input using a function provided as a parameter to the feeder.
- `$ifSet(field_name; "result if set"; "result if not set")`: Outputs the "result if set" if the field exists in the parameters.
- `$ifNotSet(field_name; "result if not set"; "result if set")`: Outputs the "result if not set" if the field is missing in the parameters.
- `$if(field_name; "result if true"; "result if false")`: Useful for boolean fields. Outputs "result if true" if the boolean field is true, and "result if false" otherwise.
- Comments: Use `#` to comment until the end of the line, or end the comment with another `#`. Note that comments cannot span multiple lines and will not appear in the final string.
- Escaping: Use a backslash (`\`) to escape characters. For example, `\$some_var` will be rendered as `$some_var` in the final string.

## Quick Start Guide

To use StringFeeder:

```swift 
import StringFeeder

let feeder = Feeder() // Alternatively, use Feeder(parameterIndicator: .percent) if you prefer to use "%" as the indicator.

let params = [
    // A string value.
    Feeder.Parameter(name: "some_string", value: Feeder.Value.string("some string")),
    
    // An integer value.
    Feeder.Parameter(name: "some-integer", value: Feeder.Value.integer(5)),
    
    // A boolean value.
    Feeder.Parameter(name: "some_boolean", value: Feeder.Value.boolean(true)),
    
    // A converter.
    Feeder.Parameter(name: "some_converter", value Feeder.Value.converter({ origString in 
        return doWhateverNeeded(to: origString)
    }))
]

let result = feeder.feed(parameters: params, into: userString)
```

## Advanced Usage

You can also combine and nest placeholders. Here are some examples:

Combining placeholders:
```swift
This is $some_bool("$true_string"; "$false_string")
```

Nesting placeholders:
```swift
This is $some_bool("$some_other_bool("yes"; "no")": "no")
```

You can format your functions as needed:
```swift
This boolean should be $some_bool(
    "$some_true_value(
        "yes";
        "no"
    )";
    "$some_other_bool(
        "secondYes"; 
        "secondNo"
    )"
).
```

## Writing Effective Placeholders

When writing placeholders, it's important to note the following:

- You can define clauses without quotes, but this relinquishes control over how the resulting string will look. For example:
```swift
Test String$test_bool(" Ja."; " Nein").     # Results in "Test String Ja."
Test String$test_bool( Ja; Nein).           # Results in "Test StringJa."
```
- Always provide both cases for `if` and `bool` clauses. If not, they won't be recognized.

## Examples

Fill an email template:
```
Dear $name,

we just want to inform you that your order $ifSet(order_number; "with order number $order_number "; ")was shipped to your address.

Please consider checking it upon arrival.

Your Customer Support
$should_show_ad(" # will show an add if should show add is set to true.
Have you heard about our new product?
"; "")
```
```swift
parameters: [
    Feeder.Parameter(name: "name", value: .string("John Doe")),
    Feeder.Parameter(name: "order_number", value: .integer(12345654321)),
    Feeder.Parameter(name: "should_show_ad", value: .boolean(true))
]
```

Fill a URL template:
```
https://some.api.com/api/v$version/users/$user_id/items/?searchstring=$url_encoded("$search_string")
```
```swift
let params = [
    Feeder.Parameter(name: "version", value: .integer(3)),
    Feeder.Parameter(name: "user_id", value: .string("someUserId")),
    Feeder.Parameter(name: "search_string", value: .string("Bücher")),
    Feeder.Parameter(name: "url_encoded", value: .converter({ value in 
        guard let encoded = value.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
            throw SomeError()
        }
        return encoded
    }))
]
```
