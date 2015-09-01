## Module Selenium.Combinators

#### `retry`

``` purescript
retry :: forall e o a. Int -> Selenium e o a -> Selenium e o a
```

Retry computation until it successed but not more then `n` times

#### `tryFind`

``` purescript
tryFind :: forall e o. String -> Selenium e o Element
```

Tries to find element by string checks: css, xpath, id, name and classname

#### `waitUntilJust`

``` purescript
waitUntilJust :: forall e o a. Selenium e o (Maybe a) -> Int -> Selenium e o a
```

#### `checker`

``` purescript
checker :: forall e o a. Selenium e o Boolean -> Selenium e o Boolean
```

#### `getElementByCss`

``` purescript
getElementByCss :: forall e o. String -> Selenium e o Element
```

#### `checkNotExistsByCss`

``` purescript
checkNotExistsByCss :: forall e o. String -> Selenium e o Unit
```

#### `contra`

``` purescript
contra :: forall e o a. Selenium e o a -> Selenium e o Unit
```

#### `waiter`

``` purescript
waiter :: forall e o a. Selenium e o a -> Int -> Selenium e o a
```

takes value and repeatedly tries to evaluate it for timeout of ms (second arg)
if it evaluates w/o error returns its value
else throws error 

#### `waitExistentCss`

``` purescript
waitExistentCss :: forall e o. String -> Int -> Selenium e o Element
```

#### `waitNotExistentCss`

``` purescript
waitNotExistentCss :: forall e o. String -> Int -> Selenium e o Unit
```

#### `await`

``` purescript
await :: forall e o. Int -> Selenium e o Boolean -> Selenium e o Unit
```

Repeatedly tries to evaluate check (third arg) for timeout ms (first arg)
finishes when check evaluates to true.
If there is an error during check or it constantly returns `false`
throws error with message (second arg)

#### `awaitUrlChanged`

``` purescript
awaitUrlChanged :: forall e o. String -> Selenium e o Boolean
```


