#  A Rather Verbose Programming Language
## (Made up Entirely of English Words)

This is a programming language that only uses English words, without any other characters, including punctuation or even digits.

Numbers are spelled out, for example `one hundred seventy two`.

Variable and function names consist of one or more known English words, none of which can be a reserved keyword; for example `my first variable`.

The language is still evolving and might change incompatibly at any time. Also, the interpreter is not heavily tested and probably contains bugs.

The following program computes the factorial of five:

```text
set start to five

define function factorial with small as
    if small is equal to zero or small is equal to one then do
        return one
    done
    set slightly bigger to value of factorial with small as small minus one
    return slightly bigger times small
done

set big to value of factorial with small as start

print big
```

It produces the output:

```text
one hundred twenty
```

It is written in Swift and uses the [Citron](http://roopc.net/citron/) parser generator.
