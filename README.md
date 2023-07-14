# StringFeeder

This code will give strings the potential to hold small and simple placeholder scripts. 
You can use this for example if you want to give the user the possibility to define a template string that will then be filled and altered with given parameters and simple script like language.

For example your app can provide this parameters:

```
some_int: 12
some_boolean: true
some_string: "Hello World"
some_converter: { (inputString) throws -> String in }
```

Now the user can define a string entangling this placeholders like this for example:
```
The int value of this is $some_int, the boolean is $some_boolean("correct"; "not correct") and I just want to say $some_string.
```

The string will then be replaced with 
```
The int value of this is 12, the boolean is correct and I just want to say Hello World.
```


## Supported Logic Placeholders

This placeholders are possible:

- `$some_var`
  Will be replaced by the value of the variable. In case of bool it will be "true" or "false".
- `$some_bool("true text"; "false text")` 
  Only for booleans. Will place "true text" or "false text" in the string.
- `$some_converter("converter input")`
  Converters can be seen as functions that are injected into the string by a logic passed to the feeder.
- `$ifSet(field_name; "result if set"; "result if not set")`
  The syntax is `ifSet([fieldname]; [trueOutput]; [falseOutput])`. Will return the true output if the field is existent in the parameters.
- `$ifNotSet(field_name; "result if not set"; "result if set")`
  The syntax is `ifNotSet([fieldname]; [trueOutput]; [falseOutput])`. Will return the true output if the field is not existent in the parameters.
- `$if(field_name; "result if not set"; "result if set")`
  The syntax is `if([fieldname]; [trueOutput]; [falseOutput])`. This is for checking booleans. If the field is not a boolean the clause is considered als false. 
- Comments: A `#` will comment for the rest of the line. or you can end the comment with `#` again. Comments cannot contain multiple lines. Comments will not end in the final string.
- Escaping: You can escape characters by placing a backslash before them. So for example `\$some_var` will end in the string as `$some_var` and will not be recognized as a placeholder and `\#` will not indicate a comment but rather end up as `#` in the string.

## How To

It's very simple:

```swift 
import StringFeeder

let feeder = Feeder() // or Feeder(parameterIndicator: .percent) if you don't want to use "$" as the indicator.

let params = [

    // A string value.
    Feeder.Parameter(name: "some_string", value: Feeder.Value.string("some string")),
    
    // An integer value.
    Feeder.Parameter(name: "some-integer", value: Feeder.Value.integer(5)),
    
    // A boolean value.
    Feeder.Parameter(name: "some_boolean", value: Feeder.Value.boolean(true))
    
    // A converter.
    Feeder.Parameter(name: "some_converter", value Feeder.Value.converter({ origString in 
        return doWhateverNeeded(to: origString)
    ))
]

let result = feeder.feed(parameters: params, into: userString)

```

## Some Rules

Combining placeholders is also possble, like this:
```
This is $some_bool("$true_string"; "$false_string")
```

Also nesting placeholders works:
```
This is $some_bool("$some_other_bool("yes"; "no")": "no")
```

You can also format your functions as wanted:
```
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

You can define clauses without the double quots, but this will take control from you how the resulting string should look like. Let's say you have this user string:
```
Test String$test_bool(" Ja."; " Nein").     # Will result in "Test String Ja."
Test String$test_bool( Ja; Nein).           # Will result in "Test StringJa."
```

In an `if` and `bool` clause you always have to provide both cases. Otherwise it's not recognized.

## Examples:

### Filling an email template:

```
Dear $name,

we just want to inform you that your order $ifSet(order_number; "with order number $order_number "; ")was shipped to your address.

Please consider checking it upon arrival.

Your Customer Support
$should_show_ad(" # will show an add if should show add is set to true.
Have you heard about our new product?
"; "")

parameters: [
    Feeder.Parameter(name: "name", value: .string("John Doe")),
    Feeder.Parameter(name: "order_number", value: .integer(12345654321)),
    Feeder.Parameter(name: "should_show_ad", value: .boolean(true))
]

```

### Filling a url template:

```
https://some.api.com/api/v$version/users/$user_id/items/?searchstring=$url_encoded("$search_string")

let params = [
    Feeder.Parameter(name: "version", value: .integer(3)),
    Feeder.Parameter(name: "user_id", value: .string("someUserId")),
    Feeder.Parameter(name: "search_string", value: .string("Bücher")),
    Feeder.Parameter(name: "url_encoded", value: .converter({ value in 
        guard let encoded = value.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
            throw SomeError()
        }
        return encoded
    })
]
```
