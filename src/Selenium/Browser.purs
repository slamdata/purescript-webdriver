module Selenium.Browser where

import Prelude
import Data.Maybe 

data Browser
  = PhantomJS
  | Chrome
  | FireFox
  | IE
  | Opera
  | Safari 


browser2str :: Browser -> String
browser2str PhantomJS = "phantomjs"
browser2str Chrome = "chrome"
browser2str FireFox = "firefox"
browser2str Opera = "opera"
browser2str Safari = "safari"
browser2str IE = "ie"

str2browser :: String -> Maybe Browser
str2browser "phantomjs" = pure PhantomJS
str2browser "chrome" = pure Chrome
str2browser "firefox" = pure FireFox
str2browser "ie" = pure IE
str2browser "opera" = pure Opera
str2browser "safari" = pure Safari
str2browser _ = Nothing
