# StringFeeder

This code will give strings the potential to hold small and simple placeholder scripts. 
You can use this for example if you want to give the user the possibility to define a template string that will then be filled and altered with given parameters and simple script like language.

For example your app can provide this parameters:

```
some_int: 12
some_boolean: true
some_string: "Hello World"
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

```
$some_var -> Will be replaced by the value of the variable. In case of bool it will be "true" or "false".
$some_bool("true text"; "false text") -> Only for booleans. Will place "true text" or "false text" in the string.
```

## How To

It's very simple:

```swift 
import StringFeeder

let feeder = Feeder() // or Feeder(parameterIndicator: "%") if you don't want to use "$" as the indicator.

let params = [
    Feeder.Parameter(name: "some_string", value: Feeder.Value.string("some string")),
    Feeder.Parameter(name: "some-integer", value: Feeder.Value.integer(5)),
    Feeder.Parameter(name: "some_boolean", value: Feeder.Value.boolean(true))
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
        "ye\";
        "no"
    )";
    "$some_other_bool(
        "secondYes"; 
        "secondNo"
    )"
).
```
