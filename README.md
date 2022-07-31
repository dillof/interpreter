#  A Rather Verbose Programming Language
## (Made up Entirely of English Words)

This is a programming language that only uses english words, without any other characters, including puctuation or even digits.

Nubmers are spelled out, for example `one hundred seventy two`.

Variable and function names consist of one or more known english words, none of which can be a reserved keyword; for example `my first variable`.

The following program computes the factorial of five:

```text
set start to five

define function factorial with small as
    if small is equal to zero or small is equal to one then do
        return one
    done
    set slightly bigger to value of factorial with small as subtract one from small
    return multiply slightly bigger by small
done

set big to value of factorial with small as start

print big
```

It produces the output:

```text
one hundred twenty
```

It is written in Swift and uses the [Citron](http://roopc.net/citron/) parser generator.
