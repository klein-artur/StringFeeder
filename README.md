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
    "some_string": Feeder.Value.string("some string"),
    "some-integer": Feeder.Value.integer(5),
    "some_boolean": Feeder.Value.boolean(true)
]

let result = feeder.feed(parameters: params, into: userString)

```

## Some Rules

Parameters are handled in the order they are provided. This way you can handle something like this:

```
This is some user string and the value is $some_bool("$true_string"; "$false_string")
```

The only condition is that the parameters `true_string` and `false_string` are before `some_bool` in the provided parameter dictionary.
