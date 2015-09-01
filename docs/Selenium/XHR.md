## Module Selenium.XHR

#### `startSpying`

``` purescript
startSpying :: forall e. Driver -> Aff (selenium :: SELENIUM | e) Unit
```

Start spy on xhrs. It defines global variable in browser
and put information about to it. 

#### `stopSpying`

``` purescript
stopSpying :: forall e. Driver -> Aff (selenium :: SELENIUM | e) Unit
```

Return xhr's method to initial. Will not raise an error if hasn't been initiated

#### `clearLog`

``` purescript
clearLog :: forall e. Driver -> Aff (selenium :: SELENIUM | e) Unit
```

Clean log. Will raise an error if spying hasn't been initiated

#### `getStats`

``` purescript
getStats :: forall e. Driver -> Aff (selenium :: SELENIUM | e) (Array XHRStats)
```

Get recorded xhr stats. If spying has not been set will raise an error


