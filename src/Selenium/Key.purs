module Selenium.Key where

import Selenium.Types

-- TODO: port all `Key` enum
foreign import altKey :: ControlKey
foreign import controlKey :: ControlKey
foreign import shiftKey :: ControlKey
foreign import commandKey :: ControlKey
foreign import metaKey :: ControlKey
