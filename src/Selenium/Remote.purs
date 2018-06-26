module Selenium.Remote where

import Effect (Effect)
import Selenium.Types

foreign import fileDetector ∷ Effect FileDetector
